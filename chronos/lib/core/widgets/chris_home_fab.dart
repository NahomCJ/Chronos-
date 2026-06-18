import 'package:flutter/material.dart';
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
      duration: const Duration(milliseconds: 1200),
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
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Outer gradient ring
                gradient: const SweepGradient(
                  colors: [
                    Color(0xFFCCFFF8), // light teal / near white
                    Color(0xFF00D4B8), // teal
                    Color(0xFF005A4E), // dark teal
                    Color(0xFF021510), // near black
                    Color(0xFF08080F), // black
                    Color(0xFFCCFFF8), // close the loop
                  ],
                  stops: [0.0, 0.18, 0.45, 0.72, 0.88, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _teal.withValues(alpha: 0.22 + 0.38 * pulse),
                    blurRadius: 12.0 + 20.0 * pulse,
                    spreadRadius: 0.0 + 6.0 * pulse,
                  ),
                ],
              ),
              // Inner dark circle — creates the ring cutout
              child: Container(
                margin: const EdgeInsets.all(3.0),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF08080F),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
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
    final bottom = MediaQuery.of(context).viewInsets.bottom;
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
          SizedBox(height: bottom + 8),
        ],
      ),
    );
  }
}
