import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../router/route_constants.dart';
import '../services/chris_action_service.dart';
import 'voice_confirmation_sheet.dart';

const _teal = Color(0xFF00D4B8);
const _tealBright = Color(0xFF80FFE8);
const _darkCard = Color(0xFF0D0D22);

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
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
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
            if (mounted) _openSheet();
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
    _glowCtrl.dispose();
    _speech.stop();
    super.dispose();
  }

  void _openSheet() {
    showModalBottomSheet(
      context: context,
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
          animation: _glowAnim,
          builder: (_, __) {
            final pulse = _wakeActive ? _glowAnim.value : 0.0;
            return Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF062B25), Color(0xFF021510)],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _teal.withValues(alpha: _wakeActive ? 0.90 : 0.60),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _teal.withValues(alpha: 0.40 + 0.38 * pulse),
                    blurRadius: 22.0 + 18.0 * pulse,
                    spreadRadius: 1.0 + 7.0 * pulse,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: _teal.withValues(alpha: 0.12 + 0.10 * pulse),
                    blurRadius: 44,
                    spreadRadius: 10.0 + 6.0 * pulse,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: [_teal, _tealBright],
                    ).createShader(b),
                    child: const Text(
                      'C',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ),
                  if (_wakeActive)
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: _teal,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Chris Sheet ───────────────────────────────────────────────────────────────
class _ChrisSheet extends StatefulWidget {
  final BuildContext parentContext;
  const _ChrisSheet({required this.parentContext});

  @override
  State<_ChrisSheet> createState() => _ChrisSheetState();
}

class _ChrisSheetState extends State<_ChrisSheet> {
  final _ctrl = TextEditingController();
  final _speech = stt.SpeechToText();
  bool _voiceActive = false;

  static const _services = [
    (Icons.arrow_upward_rounded, 'Transfer', RouteConstants.transfer),
    (Icons.add_rounded, 'Add Money', RouteConstants.addMoney),
    (Icons.swap_horiz_rounded, 'Exchange', RouteConstants.exchange),
    (Icons.wallet_rounded, 'Wallet', RouteConstants.wallet),
    (Icons.confirmation_number_rounded, 'TickPay', RouteConstants.tickpayDashboard),
    (Icons.hub_outlined, 'BlockHub', RouteConstants.blockHub),
    (Icons.pie_chart_outline_rounded, 'Portfolio', RouteConstants.blockHub),
    (Icons.candlestick_chart_outlined, 'Markets', RouteConstants.blockHub),
    (Icons.psychology_outlined, 'Panther AI', RouteConstants.pantherAi),
    (Icons.send_rounded, 'Send Money', RouteConstants.transfer),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    _speech.stop();
    super.dispose();
  }

  void _navigate(RouteConstants route) {
    Navigator.pop(context);
    widget.parentContext.push(route.toPath);
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
    return Container(
      decoration: BoxDecoration(
        color: _darkCard,
        border: Border(
          top: BorderSide(color: _teal.withValues(alpha: 0.30), width: 1),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF062B25), Color(0xFF021510)],
                  ),
                  border: Border.all(
                    color: _teal.withValues(alpha: 0.60),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _teal.withValues(alpha: 0.25),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Center(
                  child: ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: [_teal, _tealBright],
                    ).createShader(b),
                    child: const Text(
                      'C',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
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
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 10,
              childAspectRatio: 0.82,
            ),
            itemCount: _services.length,
            itemBuilder: (_, i) {
              final (icon, label, route) = _services[i];
              return GestureDetector(
                onTap: () => _navigate(route),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _teal.withValues(alpha: 0.10),
                        border: Border.all(
                          color: _teal.withValues(alpha: 0.30),
                        ),
                      ),
                      child: Icon(icon, color: _teal, size: 20),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.70),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _TealInput(
            controller: _ctrl,
            voiceActive: _voiceActive,
            onVoiceTap: _toggleVoice,
            onSend: _send,
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 28),
        ],
      ),
    );
  }
}

// ── Teal input bar ────────────────────────────────────────────────────────────
class _TealInput extends StatelessWidget {
  final TextEditingController controller;
  final bool voiceActive;
  final VoidCallback onVoiceTap;
  final void Function(String?) onSend;

  const _TealInput({
    required this.controller,
    required this.voiceActive,
    required this.onVoiceTap,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.06),
            _teal.withValues(alpha: 0.22),
          ],
        ),
      ),
      padding: const EdgeInsets.all(1.5),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.5),
          color: const Color(0xFF0A0A1A),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white, fontSize: 14.5),
                decoration: InputDecoration(
                  hintText:
                      voiceActive ? 'Listening…' : 'Ask Chris anything…',
                  hintStyle: TextStyle(
                    color: voiceActive
                        ? _teal.withValues(alpha: 0.7)
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
                      ? _teal.withValues(alpha: 0.18)
                      : Colors.white.withValues(alpha: 0.06),
                  border: Border.all(
                    color: voiceActive
                        ? _teal.withValues(alpha: 0.70)
                        : Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Icon(
                  voiceActive ? Icons.mic_rounded : Icons.mic_none_rounded,
                  color: voiceActive
                      ? _teal
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
                    colors: [_tealBright, _teal],
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
