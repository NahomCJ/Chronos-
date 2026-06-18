import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../router/route_constants.dart';
import '../services/tts_service.dart';
import '../services/chris_action_service.dart';
import 'voice_confirmation_sheet.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
const _amber = Color(0xFFF59E0B);
const _teal = Color(0xFF14B8A6);
const _darkBase = Color(0xFF0A0A18);
const _darkCard = Color(0xFF12121E);

// ── Wave bars (shared) ────────────────────────────────────────────────────────
class _WaveBars extends StatefulWidget {
  final Color color;
  final double size;
  const _WaveBars({required this.color, required this.size});

  @override
  State<_WaveBars> createState() => _WaveBarsState();
}

class _WaveBarsState extends State<_WaveBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(5, (i) {
          final phase = (i / 4) * math.pi * 1.5;
          final t = _ctrl.value * 2 * math.pi + phase;
          final ratio = 0.30 + 0.70 * math.sin(t).abs();
          final maxH = widget.size * 0.44;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 1.6),
            width: math.max(widget.size * 0.05, 2.0),
            height: math.max(maxH * ratio, 3.0),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}

// ── Gradient-border input ─────────────────────────────────────────────────────
class _GradientBorderInput extends StatelessWidget {
  final TextEditingController controller;
  final bool voiceActive;
  final VoidCallback onVoiceTap;
  // null = use controller.text; non-null = use provided text directly
  final void Function(String?) onSend;

  const _GradientBorderInput({
    required this.controller,
    required this.voiceActive,
    required this.onVoiceTap,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.09),
            _amber.withValues(alpha: 0.40),
          ],
        ),
      ),
      padding: const EdgeInsets.all(1.5),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.5),
          color: _darkCard,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white, fontSize: 14.5),
                decoration: InputDecoration(
                  hintText: voiceActive ? 'Listening…' : 'Ask Chris anything…',
                  hintStyle: TextStyle(
                    color: voiceActive
                        ? _amber.withValues(alpha: 0.7)
                        : Colors.white.withValues(alpha: 0.28),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
                onSubmitted: (_) => onSend(null),
              ),
            ),
            GestureDetector(
              onTap: onVoiceTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 6, top: 6, bottom: 6),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: voiceActive
                      ? _amber.withValues(alpha: 0.18)
                      : Colors.white.withValues(alpha: 0.06),
                  border: Border.all(
                    color: voiceActive
                        ? _amber.withValues(alpha: 0.70)
                        : Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Icon(
                  voiceActive ? Icons.mic_rounded : Icons.mic_none_rounded,
                  color: voiceActive
                      ? _amber
                      : Colors.white.withValues(alpha: 0.45),
                  size: 17,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => onSend(null),
              child: Container(
                margin: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFBBF24), _amber],
                  ),
                ),
                child: const Icon(Icons.arrow_upward_rounded,
                    color: Colors.white, size: 17),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── FAB ───────────────────────────────────────────────────────────────────────
class ChrisHomeFab extends StatefulWidget {
  final VoidCallback? onTap;
  const ChrisHomeFab({super.key, this.onTap});

  @override
  State<ChrisHomeFab> createState() => _ChrisHomeFabState();
}

class _ChrisHomeFabState extends State<ChrisHomeFab>
    with SingleTickerProviderStateMixin {
  final _speech = stt.SpeechToText();
  bool _wakeActive = false;
  bool _wakeWordTriggered = false;
  Offset _offset = Offset.zero;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
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
            if (mounted) _openVoiceMode();
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

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _speech.stop();
    super.dispose();
  }

  void _openTextSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => _ChrisTextSheet(parentContext: context),
    );
  }

  void _openVoiceMode() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.82),
      transitionDuration: const Duration(milliseconds: 380),
      pageBuilder: (ctx, _, __) => _ChrisVoiceMode(parentContext: context),
      transitionBuilder: (ctx, anim, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.88, end: 1.0).animate(
            CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: _offset,
      child: GestureDetector(
        onTap: widget.onTap ?? _openTextSheet,
        onPanUpdate: (d) => setState(() => _offset += d.delta),
        child: AnimatedBuilder(
          animation: _pulseAnim,
          builder: (_, child) => Transform.scale(
            scale: _wakeActive ? _pulseAnim.value : 1.0,
            child: child,
          ),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E1E30), Color(0xFF0A0A18)],
              ),
              border: Border.all(
                color: _amber.withValues(alpha: _wakeActive ? 0.90 : 0.58),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _amber.withValues(alpha: _wakeActive ? 0.50 : 0.20),
                  blurRadius: _wakeActive ? 22 : 10,
                  spreadRadius: _wakeActive ? 3 : 0,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.55),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: _wakeActive
                  ? const _WaveBars(color: _amber, size: 28)
                  : const Text(
                      'C',
                      style: TextStyle(
                        color: _amber,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Text bottom sheet (tap mode) ──────────────────────────────────────────────
class _ChrisTextSheet extends StatefulWidget {
  final BuildContext parentContext;
  const _ChrisTextSheet({required this.parentContext});

  @override
  State<_ChrisTextSheet> createState() => _ChrisTextSheetState();
}

class _ChrisTextSheetState extends State<_ChrisTextSheet> {
  final _ctrl = TextEditingController();
  final _speech = stt.SpeechToText();
  bool _voiceActive = false;

  static const _chips = [
    'Show my balance',
    'Open LifeX',
    'Buy Bitcoin',
    'Exchange USD',
    'BlockHub',
  ];

  @override
  void dispose() {
    _ctrl.dispose();
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
    setState(() => _voiceActive = true);
    await _speech.listen(
      onResult: (r) {
        setState(() => _ctrl.text = r.recognizedWords);
        if (r.finalResult) {
          setState(() => _voiceActive = false);
          _speech.stop();
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
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: _darkBase.withValues(alpha: 0.96),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: _amber.withValues(alpha: 0.20)),
              left: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
              right: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 36,
                  height: 3.5,
                  decoration: BoxDecoration(
                    color: _amber.withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1E1E30), Color(0xFF0D0D1A)],
                      ),
                      border: Border.all(
                        color: _amber.withValues(alpha: 0.62),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _amber.withValues(alpha: 0.22),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'C',
                        style: TextStyle(
                          color: _amber,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chris',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Your Chronos AI assistant',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.38),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                        ),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white.withValues(alpha: 0.40),
                        size: 15,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Suggestion chips
              SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _chips.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () => _send(_chips[i]),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _amber.withValues(alpha: 0.32),
                        ),
                        color: _amber.withValues(alpha: 0.07),
                      ),
                      child: Text(
                        _chips[i],
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _GradientBorderInput(
                controller: _ctrl,
                voiceActive: _voiceActive,
                onVoiceTap: _toggleVoice,
                onSend: _send,
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Voice overlay (Hey Chris / Siri mode) ────────────────────────────────────
enum _VoiceState { greeting, listening, thinking, speaking, idle }

class _ChrisVoiceMode extends StatefulWidget {
  final BuildContext parentContext;
  const _ChrisVoiceMode({required this.parentContext});

  @override
  State<_ChrisVoiceMode> createState() => _ChrisVoiceModeState();
}

class _ChrisVoiceModeState extends State<_ChrisVoiceMode>
    with SingleTickerProviderStateMixin {
  final _speech = stt.SpeechToText();
  _VoiceState _state = _VoiceState.greeting;
  String _transcription = '';
  String _response = '';

  late final AnimationController _orbCtrl;
  late final Animation<double> _orbScale;
  late final Animation<double> _orbGlow;

  @override
  void initState() {
    super.initState();
    _orbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _orbScale = Tween<double>(begin: 1.0, end: 1.09).animate(
      CurvedAnimation(parent: _orbCtrl, curve: Curves.easeInOut),
    );
    _orbGlow = Tween<double>(begin: 0.28, end: 0.64).animate(
      CurvedAnimation(parent: _orbCtrl, curve: Curves.easeInOut),
    );
    _greet();
  }

  Future<void> _greet() async {
    await TtsService().speak('Hey! What can I do for you?');
    if (mounted) _startListening();
  }

  Future<void> _startListening() async {
    if (!mounted) return;
    setState(() {
      _state = _VoiceState.listening;
      _transcription = '';
    });

    final available = await _speech.initialize();
    if (!available || !mounted) return;

    await _speech.listen(
      onResult: (r) {
        if (!mounted) return;
        setState(() => _transcription = r.recognizedWords);
        if (r.finalResult && r.recognizedWords.isNotEmpty) {
          _speech.stop();
          _processCommand(r.recognizedWords);
        }
      },
      listenOptions: stt.SpeechListenOptions(
        cancelOnError: false,
        listenMode: stt.ListenMode.dictation,
        listenFor: const Duration(seconds: 25),
        pauseFor: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _processCommand(String text) async {
    if (!mounted) return;
    setState(() {
      _state = _VoiceState.thinking;
      _response = '';
    });
    HapticFeedback.lightImpact();

    final intent = ChrisActionService.parseIntent(text);
    if (intent.type != ChrisActionType.unknown) {
      final plan = await ChrisActionService.buildPlan(intent);
      if (plan != null && mounted) {
        if (plan.navigateTo != null) {
          final msg = 'Opening ${plan.title} for you.';
          setState(() {
            _state = _VoiceState.speaking;
            _response = msg;
          });
          await TtsService().speak(msg);
          if (mounted) Navigator.pop(context);
          widget.parentContext.push(plan.navigateTo!);
          return;
        }
        final msg = 'Got it! Setting up ${plan.title} for you.';
        setState(() {
          _state = _VoiceState.speaking;
          _response = msg;
        });
        await TtsService().speak(msg);
        if (mounted) Navigator.pop(context);
        await VoiceConfirmationSheet.show(widget.parentContext, plan);
        return;
      }
    }

    const msg =
        "I'm not sure about that. Let me open the AI chat for more help.";
    setState(() {
      _state = _VoiceState.speaking;
      _response = msg;
    });
    await TtsService().speak(msg);
    if (mounted) Navigator.pop(context);
    widget.parentContext.push(RouteConstants.pantherAiChat.toPath);
  }

  @override
  void dispose() {
    _speech.stop();
    TtsService().stop();
    _orbCtrl.dispose();
    super.dispose();
  }

  String get _stateLabel {
    switch (_state) {
      case _VoiceState.greeting:
        return 'Hey! What can I do for you?';
      case _VoiceState.listening:
        return _transcription.isEmpty ? 'Listening…' : _transcription;
      case _VoiceState.thinking:
        return 'Thinking…';
      case _VoiceState.speaking:
        return _response;
      case _VoiceState.idle:
        return 'Tap to speak';
    }
  }

  Color get _orbColor {
    switch (_state) {
      case _VoiceState.listening:
        return _amber;
      case _VoiceState.thinking:
        return _teal;
      case _VoiceState.speaking:
        return const Color(0xFF818CF8);
      default:
        return _amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: AnimatedBuilder(
        animation: _orbCtrl,
        builder: (_, __) => _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final color = _orbColor;
    final scale = _orbScale.value;
    final glowA = _orbGlow.value;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Centered orb + text
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOrb(color, scale, glowA),
              const SizedBox(height: 36),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 44),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _stateLabel,
                    key: ValueKey(_stateLabel),
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  _state == _VoiceState.listening ? 'Speak now' : '',
                  key: ValueKey(_state),
                  style: TextStyle(
                    color: color.withValues(alpha: 0.55),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Dismiss button (top-right)
        Positioned(
          top: 0,
          right: 20,
          child: SafeArea(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.14),
                  ),
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.white.withValues(alpha: 0.55),
                  size: 16,
                ),
              ),
            ),
          ),
        ),
        // Bottom mic / stop button
        if (_state == _VoiceState.idle || _state == _VoiceState.listening)
          Positioned(
            bottom: 56,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _state == _VoiceState.listening
                    ? () {
                        _speech.stop();
                        setState(() => _state = _VoiceState.idle);
                      }
                    : _startListening,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        color.withValues(alpha: 0.24),
                        color.withValues(alpha: 0.05),
                      ],
                    ),
                    border: Border.all(
                      color: color.withValues(alpha: 0.55),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    _state == _VoiceState.listening
                        ? Icons.stop_rounded
                        : Icons.mic_rounded,
                    color: color,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOrb(Color color, double scale, double glowA) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulsing glow
          Transform.scale(
            scale: scale,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color.withValues(alpha: glowA * 0.42),
                    color.withValues(alpha: glowA * 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Mid ring
          Container(
            width: 152,
            height: 152,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
          ),
          // Inner orb
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.4,
                colors: [
                  color.withValues(alpha: 0.22),
                  _darkBase.withValues(alpha: 0.97),
                ],
              ),
              border: Border.all(
                color: color.withValues(alpha: 0.58),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: glowA * 0.55),
                  blurRadius: 34,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Center(
              child: _state == _VoiceState.listening
                  ? _WaveBars(color: color, size: 52)
                  : _state == _VoiceState.thinking
                      ? SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            color: color,
                          ),
                        )
                      : Text(
                          'C',
                          style: TextStyle(
                            color: color,
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
