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
  Offset _offset = Offset.zero;

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
        onTap: _openSheet,
        onPanUpdate: (d) => setState(() => _offset += d.delta),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1C2A28).withValues(alpha: 0.88),
                    const Color(0xFF091412).withValues(alpha: 0.94),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFF14B8A6).withValues(alpha: 0.60),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Container(
                  width: 33,
                  height: 33,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF14B8A6).withValues(alpha: 0.28),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: _wakeActive
                        ? Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF14B8A6),
                              shape: BoxShape.circle,
                            ),
                          )
                        : const Text(
                            'C',
                            style: TextStyle(
                              color: Color(0xFF14B8A6),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
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

  static const _teal = Color(0xFF14B8A6);
  static const _bg = Color(0xFF0D0D1A);

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
      listenOptions: stt.SpeechListenOptions(
        cancelOnError: false,
        listenMode: stt.ListenMode.dictation,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 4),
      ),
    );
  }

  void _send() {
    if (_ctrl.text.trim().isNotEmpty) {
      Navigator.pop(context);
      widget.parentContext.push(RouteConstants.pantherAiChat.toPath);
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
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Header
              Row(
                children: [
                  // Double ring logo
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1C2A28).withValues(alpha: 0.9),
                          const Color(0xFF091412).withValues(alpha: 0.95),
                        ],
                      ),
                      border: Border.all(color: _teal.withValues(alpha: 0.55), width: 1.5),
                    ),
                    child: Center(
                      child: Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: _teal.withValues(alpha: 0.28), width: 1),
                        ),
                        child: const Center(
                          child: Text('C',
                              style: TextStyle(
                                  color: _teal, fontSize: 13, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Chris',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700)),
                      Text('Your Chronos AI assistant',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 12)),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 30, height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.07),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close_rounded,
                          color: Colors.white.withValues(alpha: 0.45), size: 15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Voice button — centered, large
              GestureDetector(
                onTap: _toggleVoice,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _voiceActive
                        ? _teal.withValues(alpha: 0.18)
                        : Colors.white.withValues(alpha: 0.05),
                    border: Border.all(
                      color: _voiceActive
                          ? _teal.withValues(alpha: 0.8)
                          : Colors.white.withValues(alpha: 0.15),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    _voiceActive ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: _voiceActive ? _teal : Colors.white.withValues(alpha: 0.5),
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _voiceActive ? 'Listening...' : 'Tap mic or type below',
                style: TextStyle(
                  color: _voiceActive ? _teal : Colors.white.withValues(alpha: 0.35),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
              // Text input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1), width: 0.8),
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
                              color: Colors.white.withValues(alpha: 0.3),
                              fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    GestureDetector(
                      onTap: _send,
                      child: Container(
                        margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                        width: 36, height: 36,
                        decoration: const BoxDecoration(
                          color: _teal,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 17),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
            ],
          ),
        ),
      ),
    );
  }
}
