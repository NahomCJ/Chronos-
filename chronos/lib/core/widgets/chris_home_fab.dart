import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../router/route_constants.dart';
import '../services/chris_action_service.dart';
import 'voice_confirmation_sheet.dart';

const _teal = Color(0xFF00D4B8);
const _sheetBg = Color(0xFF0D0D22);

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
  final _speech = stt.SpeechToText();
  bool _wakeActive = false;
  bool _wakeWordTriggered = false;
  bool _respondingMode = false; // true while Chris is "answering" (fast strands)
  Offset _offset = Offset.zero;
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;
  final _timeNotifier = ValueNotifier<double>(0);
  late final Ticker _timeTicker;

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
    try {
      final available = await _speech.initialize(
        onStatus: (s) {
          if ((s == 'done' || s == 'notListening') && mounted) {
            setState(() {
              _wakeActive = false;
              _wakeWordTriggered = false;
            });
            Future.delayed(const Duration(seconds: 3), _startListening);
          }
        },
        onError: (_) {
          if (mounted) {
            setState(() {
              _wakeActive = false;
              _wakeWordTriggered = false;
            });
            Future.delayed(const Duration(seconds: 5), _startListening);
          }
        },
      );
      if (available) _startListening();
    } catch (_) {}
  }

  Future<void> _startListening() async {
    if (!mounted || _wakeActive || !_speech.isAvailable) return;
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
            _speech.stop();
            HapticFeedback.mediumImpact();
            if (mounted) {
              setState(() => _respondingMode = true);
              _listenForCommand();
            }
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

  // After "Hey Chris" is heard, capture the follow-up command directly —
  // the strands keep animating fast (_respondingMode) as the only feedback,
  // no sheet or overlay pops up. Resolved intents execute or show the
  // confirmation sheet; anything unresolved falls back to full chat.
  Future<void> _listenForCommand() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    try {
      await _speech.listen(
        onResult: (r) async {
          if (!r.finalResult) return;
          final text = r.recognizedWords.trim();
          await _speech.stop();
          if (text.isEmpty) {
            if (mounted) setState(() => _respondingMode = false);
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
      if (mounted) setState(() => _respondingMode = false);
    }
  }

  Future<void> _handleCommand(String text) async {
    final intent = ChrisActionService.parseIntent(text);
    ChrisActionPlan? plan;
    if (intent.type != ChrisActionType.unknown) {
      plan = await ChrisActionService.buildPlan(intent);
    }
    if (!mounted) return;
    setState(() => _respondingMode = false);
    if (plan != null) {
      if (plan.navigateTo != null) {
        context.push(plan.navigateTo!);
      } else {
        await VoiceConfirmationSheet.show(context, plan);
      }
    } else {
      context.push(RouteConstants.pantherAiChat.toPath);
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

  void _openSheet() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => _ChrisSheet(parentContext: context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: _offset,
      child: GestureDetector(
        onTap: widget.onTap ?? _openSheet,
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
                  speed: _respondingMode ? 0.15 : 0.02,
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

// ── Chris Chat Sheet ──────────────────────────────────────────────────────────
class _ChrisSheet extends StatefulWidget {
  final BuildContext parentContext;
  const _ChrisSheet({required this.parentContext});

  @override
  State<_ChrisSheet> createState() => _ChrisSheetState();
}

class _ChrisSheetState extends State<_ChrisSheet> {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();
  final _speech = stt.SpeechToText();
  bool _voiceActive = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      final has = _ctrl.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _toggleVoice() async {
    if (_voiceActive) {
      await _speech.stop();
      setState(() => _voiceActive = false);
      return;
    }
    final available = await _speech.initialize();
    if (!available) return;
    setState(() {
      _voiceActive = true;
      _ctrl.clear();
    });
    await _speech.listen(
      onResult: (r) {
        setState(() => _ctrl.text = r.recognizedWords);
        if (r.finalResult && r.recognizedWords.trim().isNotEmpty) {
          setState(() => _voiceActive = false);
          _speech.stop();
          _send(null);
        }
      },
      listenOptions: stt.SpeechListenOptions(
        cancelOnError: false,
        listenMode: stt.ListenMode.dictation,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 4),
      ),
    );
  }

  void _send(String? override) async {
    final text = (override ?? _ctrl.text).trim();
    if (text.isEmpty) return;

    final intent = ChrisActionService.parseIntent(text);
    if (intent.type != ChrisActionType.unknown) {
      final plan = await ChrisActionService.buildPlan(intent);
      if (plan != null && mounted) {
        Navigator.pop(context);
        if (plan.navigateTo != null) {
          widget.parentContext.push(plan.navigateTo!);
          return;
        }
        await VoiceConfirmationSheet.show(widget.parentContext, plan);
        return;
      }
    }

    Navigator.pop(context);
    widget.parentContext.push(RouteConstants.pantherAiChat.toPath);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final keyboard = mq.viewInsets.bottom;
    // When keyboard is hidden, clear the custom pill nav bar (~70px) plus
    // the system safe-area inset so nothing is hidden behind it.
    final bottomPad = keyboard > 0
        ? keyboard + 8.0
        : mq.padding.bottom + 90.0;
    return Container(
      color: _sheetBg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Voice listening indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _voiceActive ? 48 : 0,
            child: _voiceActive
                ? Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: _teal,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Listening…',
                          style: TextStyle(
                            color: _teal.withValues(alpha: 0.85),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          // Input row
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 48),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131325),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _voiceActive
                            ? _teal.withValues(alpha: 0.55)
                            : Colors.white.withValues(alpha: 0.09),
                      ),
                    ),
                    child: TextField(
                      controller: _ctrl,
                      focusNode: _focusNode,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.4),
                      decoration: InputDecoration(
                        hintText: _voiceActive
                            ? 'Speak now…'
                            : 'Message Chris…',
                        hintStyle: TextStyle(
                          color: _voiceActive
                              ? _teal.withValues(alpha: 0.60)
                              : Colors.white.withValues(alpha: 0.28),
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 13),
                      ),
                      maxLines: 5,
                      minLines: 1,
                      onSubmitted: (_) => _send(null),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Mic → Send toggle
                GestureDetector(
                  onTap: _hasText ? () => _send(null) : _toggleVoice,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _hasText
                          ? _teal
                          : (_voiceActive
                              ? _teal.withValues(alpha: 0.18)
                              : const Color(0xFF1A1A30)),
                      border: _hasText
                          ? null
                          : Border.all(
                              color: _voiceActive
                                  ? _teal.withValues(alpha: 0.65)
                                  : Colors.white.withValues(alpha: 0.12),
                            ),
                      boxShadow: _hasText
                          ? [
                              BoxShadow(
                                color: _teal.withValues(alpha: 0.35),
                                blurRadius: 12,
                                spreadRadius: 1,
                              )
                            ]
                          : null,
                    ),
                    child: Icon(
                      _hasText
                          ? Icons.arrow_upward_rounded
                          : (_voiceActive
                              ? Icons.mic_rounded
                              : Icons.mic_none_rounded),
                      color: _hasText
                          ? Colors.white
                          : (_voiceActive
                              ? _teal
                              : Colors.white.withValues(alpha: 0.45)),
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: bottomPad),
        ],
      ),
    );
  }
}
