import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../features/auth/data/services/token_storage_service.dart';
import '../../features/panther_ai/domain/usecases/send_message.dart';
import '../router/route_constants.dart';
import '../services/chris_action_service.dart';
import '../services/tts_service.dart';
import 'voice_confirmation_sheet.dart';

const _teal = Color(0xFF00D4B8);

enum _ChrisState { idle, listening, thinking, speaking }

// ── FAB ───────────────────────────────────────────────────────────────────────
class ChrisHomeFab extends StatefulWidget {
  final VoidCallback? onTap;
  final double size;
  const ChrisHomeFab({super.key, this.onTap, this.size = 56});

  @override
  State<ChrisHomeFab> createState() => _ChrisHomeFabState();
}

class _ChrisHomeFabState extends State<ChrisHomeFab>
    with TickerProviderStateMixin {
  static const _maxFollowUpTurns = 4;

  final _speech = stt.SpeechToText();
  bool _wakeActive = false;
  bool _wakeWordTriggered = false;
  _ChrisState _state = _ChrisState.idle;
  bool _micAvailable = true;
  bool _micPermissionWarned = false;
  int _followUpTurns = 0;
  int _commandGeneration = 0;
  final List<Map<String, String>> _history = [];

  Offset _offset = Offset.zero;
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;
  final _timeNotifier = ValueNotifier<double>(0);
  late final Ticker _timeTicker;

  bool get _isBusy => _state != _ChrisState.idle;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );
    _timeTicker = createTicker((elapsed) {
      _timeNotifier.value = elapsed.inMicroseconds / 1e6;
    })..start();
    _initWakeWord();
  }

  Future<void> _initWakeWord() async {
    _micAvailable = await _initSpeechEngine();
    // Background wake-word polling relies on silently restarting the mic
    // every few seconds, which browsers block outside a direct user
    // gesture. On web, only tap-to-talk works.
    if (_micAvailable && !kIsWeb) _startListening();
  }

  // Registers the status/error handlers exactly once per successful call —
  // reused both at startup and when lazily re-checking mic permission later,
  // so a permission granted mid-session doesn't leave the wake-word restart
  // chain unwired.
  Future<bool> _initSpeechEngine() async {
    try {
      return await _speech.initialize(
        onStatus: (s) {
          if ((s == 'done' || s == 'notListening') && mounted) {
            setState(() => _wakeActive = false);
            // Only resume passive "Hey Chris" listening once the whole
            // interaction has settled back to idle — otherwise this races
            // with the deliberate listen sessions inside a conversation.
            if (!_isBusy) {
              _wakeWordTriggered = false;
              Future.delayed(const Duration(seconds: 3), _startListening);
            }
          }
        },
        onError: (_) {
          if (mounted) {
            setState(() => _wakeActive = false);
            if (!_isBusy) {
              _wakeWordTriggered = false;
              Future.delayed(const Duration(seconds: 5), _startListening);
            }
          }
        },
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> _startListening() async {
    if (!mounted || _wakeActive || _isBusy || !_speech.isAvailable) return;
    _wakeWordTriggered = false;
    try {
      setState(() => _wakeActive = true);
      await _speech.listen(
        onResult: (r) {
          if (_wakeWordTriggered) return;
          final words = r.recognizedWords.toLowerCase();
          if (words.contains('hey chris') ||
              (words.startsWith('hey') && words.contains('chris'))) {
            _wakeWordTriggered = true;
            _engage();
          }
        },
        listenOptions: stt.SpeechListenOptions(
          cancelOnError: false,
          listenMode: stt.ListenMode.dictation,
          listenFor: const Duration(seconds: 60),
          pauseFor: const Duration(seconds: 6),
        ),
      );
    } catch (_) {
      if (mounted) setState(() => _wakeActive = false);
    }
  }

  String get _userFirstName {
    try {
      final name = GetIt.instance<TokenStorageService>().firstName;
      return (name != null && name.isNotEmpty) ? name : 'there';
    } catch (_) {
      return 'there';
    }
  }

  void _setChrisState(_ChrisState s) {
    if (mounted) setState(() => _state = s);
  }

  void _warnMicUnavailable() {
    if (_micPermissionWarned || !mounted) return;
    _micPermissionWarned = true;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(
        content: Text(
          'Microphone access is needed for voice commands. '
          'Enable it in your device settings.',
        ),
      ),
    );
  }

  // Shared entry point for "Hey Chris", a tap while idle, or a tap that
  // interrupts Chris mid-response. No sheet or overlay pops up; the strands
  // are the only visual feedback (their speed reflects the current state).
  Future<void> _engage() async {
    final interrupting = _isBusy;
    _speech.stop();
    await TtsService().stop();
    HapticFeedback.mediumImpact();
    if (!mounted) return;

    // Always start from a clean slate — if this is an interrupt, the
    // in-flight turn may not have gotten an assistant reply appended,
    // and sending an orphaned "user" entry would break the strict
    // user/assistant alternation Anthropic's API requires.
    _history.clear();
    _followUpTurns = 0;

    if (!_micAvailable) {
      // Just re-check permission — don't start the background wake-word
      // loop here, since we're about to greet-and-listen ourselves below.
      _micAvailable = await _initSpeechEngine();
    }
    if (!_micAvailable) {
      _endConversation();
      _warnMicUnavailable();
      return;
    }

    if (interrupting) {
      // The user already knows what's up — skip straight to listening.
      _listenForCommand();
      return;
    }

    _setChrisState(_ChrisState.speaking);
    await TtsService().speak('Hey $_userFirstName, what would you like to do?');
    if (!mounted) return;
    _listenForCommand();
  }

  // After the greeting (or an interrupt), capture the follow-up command.
  // Resolved intents execute or show the confirmation sheet; anything
  // unresolved gets a real spoken reply from Chris chat, and — up to a
  // few turns — the conversation keeps going without repeating "Hey Chris".
  Future<void> _listenForCommand() async {
    _commandGeneration++; // invalidate any earlier in-flight _handleCommand
    _setChrisState(_ChrisState.listening);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    try {
      await _speech.listen(
        onResult: (r) async {
          if (!r.finalResult) return;
          final text = r.recognizedWords.trim();
          await _speech.stop();
          if (text.isEmpty) {
            _endConversation();
            return;
          }
          await _handleCommand(text);
        },
        listenOptions: stt.SpeechListenOptions(
          cancelOnError: false,
          listenMode: stt.ListenMode.dictation,
          listenFor: const Duration(seconds: 15),
          pauseFor: const Duration(seconds: 3),
        ),
      );
    } catch (_) {
      _endConversation();
    }
  }

  void _endConversation() {
    if (!mounted) return;
    setState(() => _state = _ChrisState.idle);
    _followUpTurns = 0;
    _history.clear();
    if (!kIsWeb) Future.delayed(const Duration(seconds: 1), _startListening);
  }

  Future<void> _handleCommand(String text) async {
    final myGen = _commandGeneration;
    _setChrisState(_ChrisState.thinking);
    final intent = ChrisActionService.parseIntent(text);
    ChrisActionPlan? plan;
    if (intent.type != ChrisActionType.unknown) {
      plan = await ChrisActionService.buildPlan(intent);
    }
    if (!mounted || myGen != _commandGeneration) return;

    if (plan != null) {
      if (plan.navigateTo != null) {
        _setChrisState(_ChrisState.speaking);
        await TtsService().speak(plan.subtitle);
        if (myGen != _commandGeneration) return;
        _endConversation();
        if (mounted) context.push(plan.navigateTo!);
      } else {
        _endConversation();
        await VoiceConfirmationSheet.show(context, plan);
      }
      return;
    }

    // Unresolved intent — keep the conversation going with a real reply
    // from Chris chat instead of silently jumping to the chat page.
    _history.add({'role': 'user', 'content': text});
    try {
      final response = await GetIt.instance<SendMessage>()
          .call(text, history: List.of(_history));
      if (!mounted || myGen != _commandGeneration) return;
      _history.add({'role': 'assistant', 'content': response.reply});
      _setChrisState(_ChrisState.speaking);
      await TtsService().speak(response.reply);
      if (!mounted || myGen != _commandGeneration) return;
      if (_followUpTurns < _maxFollowUpTurns) {
        _followUpTurns++;
        _listenForCommand();
      } else {
        _endConversation();
      }
    } catch (_) {
      if (!mounted || myGen != _commandGeneration) return;
      _setChrisState(_ChrisState.speaking);
      await TtsService()
          .speak('Sorry, I couldn\'t reach the server. Let\'s continue in chat.');
      _endConversation();
      if (mounted) context.push(RouteConstants.pantherAiChat.toPath);
    }
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _timeTicker.dispose();
    _timeNotifier.dispose();
    _speech.stop();
    super.dispose();
  }

  double get _painterSpeed {
    switch (_state) {
      case _ChrisState.listening:
        return 0.10;
      case _ChrisState.thinking:
        return 0.12;
      case _ChrisState.speaking:
        return 0.18;
      case _ChrisState.idle:
        return 0.02;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: _offset,
      child: GestureDetector(
        onTap: widget.onTap ?? _engage,
        onPanUpdate: (d) => setState(() => _offset += d.delta),
        child: AnimatedBuilder(
          animation: Listenable.merge([_timeNotifier, _glowAnim]),
          builder: (_, __) {
            final pulse = _wakeActive ? _glowAnim.value : 0.0;
            return SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: _StrandsPainter(
                  time: _timeNotifier.value,
                  pulseValue: pulse,
                  speed: _painterSpeed,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Strands Painter ────────────────────────────────────────────────────────────
// Port of the Strands WebGL shader to Flutter CustomPainter.
// Matches the shader math: uv-space sinusoidal strands with per-pixel glow.
class _StrandsPainter extends CustomPainter {
  final double time;
  final double pulseValue;
  final double speed;

  const _StrandsPainter({
    required this.time,
    this.pulseValue = 0.0,
    this.speed = 0.02,
  });
  static const _colors = [Color(0xFF7C3AED), Color(0xFF06B6D4)];
  static const _count = 4;
  static const _amplitude = 1.9;
  static const _waviness = 2.0;
  static const _thickness = 1.1;
  static const _glow = 2.1;
  static const _taper = 0.5;
  static const _spread = 1.05;
  static const _scale = 1.5;
  static const _intensity = 0.6;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy);

    canvas.save();
    final circleRect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    canvas.clipPath(Path()..addOval(circleRect));

    // tt mirrors `float tt = uTime * uSpeed` in the shader.
    final tt = time * speed;

    for (int i = 0; i < _count; i++) {
      final fi = i.toDouble();
      // Strand-specific parameters — same formulas as the fragment shader.
      final ph = fi * 1.7 * _spread;
      final freq = (2.0 + fi * 0.35) * _waviness;
      final spd = 1.4 + fi * 1.2;
      final color = _colors[i % _colors.length];

      final path = Path();

      for (int step = 0; step <= 80; step++) {
        final t = step / 80;
        // uvx: normalised by resolution.y then divided by scale, same as shader.
        final uvx = (t - 0.5) / _scale;

        // Envelope: cos-based taper that fades strands toward the horizontal edges.
        final envRaw = math.cos(uvx * math.pi * 1.3);
        final env = envRaw > 0 ? math.pow(envRaw, _taper).toDouble() : 0.0;

        // Two-term sine sum — matches FRAG shader `w` calculation.
        final w = math.sin(uvx * freq + tt * spd + ph) * 0.60
                + math.sin(uvx * freq * 1.1 - tt * spd * 0.7 + ph * 1.7) * 0.40;

        final amp = (0.1 + 0.02 * _intensity) * env * _amplitude;

        // Screen mapping: x spans full canvas; y displacement scales with
        // size.height * scale (mirroring how the shader maps uv back to pixels).
        final screenX = t * size.width;
        final screenY = cy + w * amp * size.height * _scale;

        if (step == 0) {
          path.moveTo(screenX, screenY);
        } else {
          path.lineTo(screenX, screenY);
        }
      }

      final baseStroke = _thickness * r * 0.07;
      final pulseBoost = 1.0 + pulseValue * 0.5;

      // Three-layer glow: outer bloom → inner halo → bright core.
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.22)
          ..strokeWidth = baseStroke * 7 * _glow * pulseBoost
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );

      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.60)
          ..strokeWidth = baseStroke * 2.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );

      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.90)
          ..strokeWidth = baseStroke
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }

    canvas.restore();

    // Teal pulse ring when wake-word is active.
    if (pulseValue > 0) {
      canvas.drawCircle(
        Offset(cx, cy),
        r - 1,
        Paint()
          ..color = _teal.withValues(alpha: 0.20 + 0.40 * pulseValue)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 + 8 * pulseValue),
      );
    }
  }

  @override
  bool shouldRepaint(_StrandsPainter old) =>
      old.time != time || old.pulseValue != pulseValue || old.speed != speed;
}
