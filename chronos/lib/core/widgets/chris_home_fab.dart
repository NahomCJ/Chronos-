import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../router/route_constants.dart';

class ChrisHomeFab extends StatefulWidget {
  const ChrisHomeFab({super.key});

  @override
  State<ChrisHomeFab> createState() => _ChrisHomeFabState();
}

class _ChrisHomeFabState extends State<ChrisHomeFab> {
  final _speech = stt.SpeechToText();
  bool _wakeActive = false;

  @override
  void initState() {
    super.initState();
    _initWakeWord();
  }

  Future<void> _initWakeWord() async {
    try {
      final available = await _speech.initialize(
        onStatus: (s) {
          if ((s == 'done' || s == 'notListening') && mounted) {
            setState(() => _wakeActive = false);
            Future.delayed(const Duration(seconds: 3), _startListening);
          }
        },
        onError: (_) {
          if (mounted) {
            setState(() => _wakeActive = false);
            Future.delayed(const Duration(seconds: 5), _startListening);
          }
        },
      );
      if (available) _startListening();
    } catch (_) {}
  }

  Future<void> _startListening() async {
    if (!mounted || _wakeActive || !_speech.isAvailable) return;
    try {
      setState(() => _wakeActive = true);
      await _speech.listen(
        onResult: (r) {
          if (r.recognizedWords.toLowerCase().contains('chris')) {
            _speech.stop();
            if (mounted) _openSheet();
          }
        },
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 6),
        cancelOnError: false,
        listenMode: stt.ListenMode.dictation,
      );
    } catch (_) {
      if (mounted) setState(() => _wakeActive = false);
    }
  }

  @override
  void dispose() {
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
    return GestureDetector(
      onTap: _openSheet,
      child: Container(
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
            color: const Color(0xFF00D4B8).withValues(alpha: 0.60),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00D4B8).withValues(alpha: 0.40),
              blurRadius: 22,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: const Color(0xFF00D4B8).withValues(alpha: 0.12),
              blurRadius: 44,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [Color(0xFF00D4B8), Color(0xFF80FFE8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
            // Mic active dot
            if (_wakeActive)
              Positioned(
                bottom: 6,
                right: 6,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00D4B8),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Command sheet ─────────────────────────────────────────────────────────────

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

  static const _teal = Color(0xFF00D4B8);
  static const _bg = Color(0xFF0D0D1A);

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
        if (r.finalResult) {
          setState(() {
            _ctrl.text = r.recognizedWords;
            _voiceActive = false;
          });
          _speech.stop();
        } else {
          setState(() => _ctrl.text = r.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 4),
    );
  }

  void _navigate(RouteConstants route) {
    Navigator.pop(context);
    final ctx = widget.parentContext;
    if (route == RouteConstants.addMoney) {
      ctx.push(route.toPath);
    } else {
      ctx.go(route.toPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: const BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Header
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF062B25), Color(0xFF021510)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: _teal.withValues(alpha: 0.55), width: 1.2),
                    ),
                    child: Center(
                      child: ShaderMask(
                        shaderCallback: (b) => const LinearGradient(
                          colors: [_teal, Color(0xFF80FFE8)],
                        ).createShader(b),
                        child: const Text(
                          'C',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            height: 1,
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
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Your Chronos AI assistant',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close_rounded,
                          color: Colors.white.withValues(alpha: 0.5), size: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Services grid
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'QUICK ACTIONS',
                  style: TextStyle(
                    color: Color(0xFF00D4B8),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 8,
                childAspectRatio: 0.78,
                children: _services.map((s) => _serviceItem(s.$2, s.$1, s.$3)).toList(),
              ),
              const SizedBox(height: 20),

              // Text input + voice + send
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12), width: 0.8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Ask Chris anything...',
                          hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.35),
                              fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        onSubmitted: (v) {
                          if (v.trim().isNotEmpty) {
                            Navigator.pop(context);
                            widget.parentContext
                                .push(RouteConstants.pantherAiChat.toPath);
                          }
                        },
                      ),
                    ),
                    // Voice button
                    GestureDetector(
                      onTap: _toggleVoice,
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: _voiceActive
                              ? _teal.withValues(alpha: 0.25)
                              : Colors.white.withValues(alpha: 0.06),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _voiceActive
                                ? _teal.withValues(alpha: 0.7)
                                : Colors.white.withValues(alpha: 0.12),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          _voiceActive ? Icons.mic_rounded : Icons.mic_none_rounded,
                          color: _voiceActive ? _teal : Colors.white.withValues(alpha: 0.5),
                          size: 18,
                        ),
                      ),
                    ),
                    // Send button
                    GestureDetector(
                      onTap: () {
                        if (_ctrl.text.trim().isNotEmpty) {
                          Navigator.pop(context);
                          widget.parentContext
                              .push(RouteConstants.pantherAiChat.toPath);
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00D4B8), Color(0xFF009E8A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              Text(
                'Say "Chris" anytime to open  •  Hold mic to speak',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.28),
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                  height: MediaQuery.of(context).viewInsets.bottom + 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _serviceItem(String label, IconData icon, RouteConstants route) {
    return GestureDetector(
      onTap: () => _navigate(route),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _teal.withValues(alpha: 0.10),
              shape: BoxShape.circle,
              border: Border.all(
                  color: _teal.withValues(alpha: 0.25), width: 0.8),
            ),
            child: Icon(icon, color: _teal, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
