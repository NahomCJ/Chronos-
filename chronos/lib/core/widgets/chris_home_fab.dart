import 'dart:async';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
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
import '../services/chris_wake_word.dart';
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
  final _chimePlayer = AudioPlayer();
  bool _wakeActive = false;
  bool _wakeWordTriggered = false;
  _ChrisState _state = _ChrisState.idle;
  bool _micAvailable = true;
  bool _micPermissionWarned = false;
  bool _voiceErrorWarned = false;
  int _followUpTurns = 0;
  int _commandGeneration = 0;
  final List<Map<String, String>> _history = [];

  // Tracks an in-flight command-capture listen session so onStatus/onError
  // (below) can resolve it with whatever was heard even if finalResult
  // never fires — unreliable on some platforms with ListenMode.dictation.
  String _pendingTranscript = '';
  Completer<String>? _commandCompleter;

  Offset _offset = Offset.zero;
  Offset _dragStartPointer = Offset.zero;
  Offset _dragStartOffset = Offset.zero;
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
    // Linear triangle wave (0→1→0 over 1200ms), matching the reference
    // component's hand-rolled `t < 0.5 ? t*2 : (1-t)*2` ramp exactly —
    // no easing.
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_glowCtrl);
    _timeTicker = createTicker((elapsed) {
      _timeNotifier.value = elapsed.inMicroseconds / 1e6;
    })..start();
    TtsService().onError = _warnVoiceError;
    _initWakeWord();
  }

  // Chris's premium (ElevenLabs) voice used to fail silently, downgrading to
  // the on-device fallback with no visible sign anything was wrong — this
  // makes the real reason (missing/invalid key, exhausted quota, network
  // error) visible instead of indistinguishable guesswork.
  void _warnVoiceError(String message) {
    if (_voiceErrorWarned || !mounted) return;
    _voiceErrorWarned = true;
    debugPrint('Chris voice unavailable: $message');
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text(
          "Chris's premium voice is unavailable right now (using the "
          'built-in voice instead). Reason: $message',
        ),
        duration: const Duration(seconds: 6),
      ),
    );
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
          if (s == 'done' || s == 'notListening') {
            // A command-capture session (see _listenForCommand) may end
            // without ever firing finalResult — resolve it with whatever
            // partial transcript was heard instead of hanging forever,
            // which used to look like Chris only ever responding to the
            // wake phrase itself and going silent on everything after.
            if (_commandCompleter != null && !_commandCompleter!.isCompleted) {
              _commandCompleter!.complete(_pendingTranscript);
            }
            if (mounted) {
              setState(() => _wakeActive = false);
              // Only resume passive "Hey Chris" listening once the whole
              // interaction has settled back to idle — otherwise this races
              // with the deliberate listen sessions inside a conversation.
              if (!_isBusy) {
                _wakeWordTriggered = false;
                Future.delayed(const Duration(seconds: 3), _startListening);
              }
            }
          }
        },
        onError: (e) {
          debugPrint('Chris speech recognition error: ${e.errorMsg}');
          if (_commandCompleter != null && !_commandCompleter!.isCompleted) {
            _commandCompleter!.complete(_pendingTranscript);
          }
          if (mounted) {
            setState(() => _wakeActive = false);
            if (!_isBusy) {
              _wakeWordTriggered = false;
              Future.delayed(const Duration(seconds: 5), _startListening);
            }
          }
        },
      );
    } catch (e) {
      debugPrint('Chris speech engine failed to initialize: $e');
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
          final wake = ChrisWakeWord.parse(r.recognizedWords);
          if (wake.triggered) {
            _wakeWordTriggered = true;
            _engage(initialCommand: wake.command);
          }
        },
        listenOptions: stt.SpeechListenOptions(
          cancelOnError: false,
          listenMode: stt.ListenMode.dictation,
          listenFor: const Duration(seconds: 60),
          pauseFor: const Duration(seconds: 6),
        ),
      );
    } catch (e) {
      debugPrint('Chris wake-word listen() failed: $e');
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

  Future<void> _playWakeChime() async {
    try {
      await _chimePlayer.play(AssetSource('sounds/chris_wake.wav'));
    } catch (e) {
      debugPrint('Chris wake chime failed to play: $e');
    }
  }

  // Shared entry point for "Hey Chris", a tap while idle, or a tap that
  // interrupts Chris mid-response. No sheet or overlay pops up; the strands
  // are the only visual feedback (their speed reflects the current state).
  Future<void> _engage({String? initialCommand}) async {
    final interrupting = _isBusy;
    _speech.stop();
    await TtsService().stop();
    HapticFeedback.mediumImpact();
    // Cue the start of a fresh conversation with a short chime — mirrors the
    // "Hey Siri" ding. Skipped on an interrupt (the user's already mid-turn,
    // a chime there would just be noise), and the FAB itself grows and
    // circles faster the moment _state leaves idle (see build() below).
    if (!interrupting) unawaited(_playWakeChime());
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

    final spokenCommand = initialCommand?.trim() ?? '';
    if (spokenCommand.isNotEmpty) {
      _commandGeneration++;
      await _handleCommand(spokenCommand);
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

    _pendingTranscript = '';
    final completer = Completer<String>();
    _commandCompleter = completer;

    try {
      await _speech.listen(
        onResult: (r) {
          _pendingTranscript = r.recognizedWords.trim();
          if (r.finalResult && !completer.isCompleted) {
            completer.complete(_pendingTranscript);
            _speech.stop();
          }
        },
        listenOptions: stt.SpeechListenOptions(
          cancelOnError: false,
          listenMode: stt.ListenMode.dictation,
          listenFor: const Duration(seconds: 15),
          pauseFor: const Duration(seconds: 3),
        ),
      );
    } catch (_) {
      if (!completer.isCompleted) completer.complete(_pendingTranscript);
    }

    // Belt-and-suspenders: some platforms never fire finalResult and rely
    // on the onStatus 'done'/'notListening' callback instead (handled in
    // _initSpeechEngine above). If neither shows up in time, fall back to
    // whatever partial transcript was captured rather than hanging in
    // "listening" state forever.
    final text = await completer.future.timeout(
      const Duration(seconds: 18),
      onTimeout: () => _pendingTranscript,
    );
    if (identical(_commandCompleter, completer)) _commandCompleter = null;
    if (!mounted) return;

    if (text.isEmpty) {
      _endConversation();
      return;
    }
    await _handleCommand(text);
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
    _chimePlayer.dispose();
    super.dispose();
  }

  // Binary idle/responding speed, matching the reference component's
  // `respondingMode ? 0.45 : 0.07` exactly — any non-idle state reads as
  // "responding" for animation purposes, same as its 3-second post-wake flag.
  double get _painterSpeed => _isBusy ? 0.45 : 0.07;

  // Mirrors the reference component's onPointerDown/Move/Up: drag follows
  // the pointer via a translated offset, and only a sub-5px total movement
  // counts as a tap (opens/engages) rather than a drag.
  void _onPanDown(DragDownDetails d) {
    _dragStartPointer = d.globalPosition;
    _dragStartOffset = _offset;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    setState(() {
      _offset = _dragStartOffset + (d.globalPosition - _dragStartPointer);
    });
  }

  void _onPanEnd(DragEndDetails d) {
    final moved = _offset - _dragStartOffset;
    if (moved.dx.abs() < 5 && moved.dy.abs() < 5) {
      (widget.onTap ?? () => _engage())();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: _offset,
      child: GestureDetector(
        onPanDown: _onPanDown,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        // Grows to 2x and (via the strands painter's own speed/pulse below)
        // circles noticeably faster the instant "Hey Chris" is heard or the
        // FAB is tapped — settles back to its resting size once the
        // conversation ends and _state returns to idle.
        child: AnimatedScale(
          scale: _isBusy ? 2.0 : 1.0,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutBack,
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
  static const _colors = [
    Color(0xFF3B82F6),
    Color(0xFF7C3AED),
    Color(0xFF100820),
  ];
  static const _count = 4;
  static const _amplitude = 1.3;
  static const _waviness = 2.0;
  static const _thickness = 1.0;
  static const _glow = 2.1;
  static const _taper = 0.5;
  static const _spread = 0.7;
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
          ..color = color.withValues(alpha: 0.20)
          ..strokeWidth = baseStroke * 7 * _glow * pulseBoost
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );

      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.55)
          ..strokeWidth = baseStroke * 2.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );

      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.88)
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
