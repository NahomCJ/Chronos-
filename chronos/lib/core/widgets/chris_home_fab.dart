import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../router/route_constants.dart';
import '../services/tts_service.dart';
import '../services/chris_action_service.dart';
import 'voice_confirmation_sheet.dart';

class ChrisHomeFab extends StatefulWidget {
  final VoidCallback? onTap;
  const ChrisHomeFab({super.key, this.onTap});

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
          final words = r.recognizedWords.toLowerCase();
          if (words.contains('hey chris') || (words.startsWith('hey') && words.contains('chris'))) {
            _speech.stop();
            HapticFeedback.mediumImpact();
            TtsService().speak('Hey, what can I do for you?');
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
        onTap: widget.onTap ?? _openSheet,
        onPanUpdate: (d) => setState(() => _offset += d.delta),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFBBBBBB).withValues(alpha: 0.50),
                    const Color(0xFF999999).withValues(alpha: 0.35),
                  ],
                ),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.18),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: _wakeActive
                      ? Center(
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
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

  static const _bg = Color(0xFF0D0D1A);
  static const _teal = Color(0xFF14B8A6);

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

  void _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    // Parse intent
    final intent = ChrisActionService.parseIntent(text);
    if (intent.type != ChrisActionType.unknown) {
      // Build a plan
      final plan = await ChrisActionService.buildPlan(intent);
      if (plan != null && mounted) {
        Navigator.pop(context);
        // Navigation intents: go directly without confirmation sheet
        if (plan.navigateTo != null) {
          widget.parentContext.push(plan.navigateTo!);
          return;
        }
        // Transactional intents: show confirmation
        await VoiceConfirmationSheet.show(widget.parentContext, plan);
        return;
      }
    }

    // Fallback: open chat page
    Navigator.pop(context);
    widget.parentContext.push(RouteConstants.pantherAiChat.toPath);
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
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF232330), Color(0xFF0E0E18)],
                      ),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.22), width: 1.5),
                    ),
                    child: Center(
                      child: Container(
                        width: 27, height: 27,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.10), width: 1),
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
              const SizedBox(height: 20),
              // ChatGPT-style input bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14), width: 0.8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: _voiceActive
                              ? 'Listening...'
                              : 'Order anything in Chronos, I\'ll get it done',
                          hintStyle: TextStyle(
                              color: _voiceActive
                                  ? _teal.withValues(alpha: 0.7)
                                  : Colors.white.withValues(alpha: 0.28),
                              fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 14),
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    // Mic button
                    GestureDetector(
                      onTap: _toggleVoice,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 6, top: 6, bottom: 6),
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _voiceActive
                              ? _teal.withValues(alpha: 0.22)
                              : Colors.white.withValues(alpha: 0.06),
                          border: Border.all(
                            color: _voiceActive
                                ? _teal.withValues(alpha: 0.7)
                                : Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Icon(
                          _voiceActive ? Icons.mic_rounded : Icons.mic_none_rounded,
                          color: _voiceActive ? _teal : Colors.white.withValues(alpha: 0.5),
                          size: 17,
                        ),
                      ),
                    ),
                    // Send button
                    GestureDetector(
                      onTap: _send,
                      child: Container(
                        margin: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
                        width: 36, height: 36,
                        decoration: const BoxDecoration(
                          color: _teal,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_upward_rounded,
                            color: Colors.white, size: 17),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 80),
            ],
          ),
        ),
      ),
    );
  }
}
