import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../core/theme/text_theme.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/chris_voice_orb.dart';

class PantherAiChatPage extends StatefulWidget {
  const PantherAiChatPage({super.key});

  @override
  State<PantherAiChatPage> createState() => _PantherAiChatPageState();
}

class _PantherAiChatPageState extends State<PantherAiChatPage>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final ChatBloc _chatBloc;

  bool _isVoiceMode = false;

  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text: "Hello! I'm Chris, your AI financial advisor. What can I do for you today?",
      isUser: false,
      time: '',
    ),
  ];

  late AnimationController _dotController;
  late AnimationController _pulseController;
  OrbState _orbState = OrbState.idle;

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;
  bool _isListening = false;

  final List<String> _suggestions = [
    'Show my balance',
    'Why is my spending high?',
    'Rebalance portfolio',
    'Credit score tips',
  ];

  static const _bg = Color(0xFFF5F6FA);
  static const _cardBg = Colors.white;
  static const _textPrimary = Color(0xFF1A1A2E);
  static const _textSecondary = Color(0xFF6B7080);
  static const _purple = Color(0xFF7C6EF0);
  static const _borderColor = Color(0xFFE8EAF0);

  @override
  void initState() {
    super.initState();
    _chatBloc = GetIt.I<ChatBloc>();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _messages.first = _ChatMessage(
      text: _messages.first.text,
      isUser: false,
      time: _currentTime(),
    );
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onError: (_) => setState(() => _isListening = false),
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
    );
    if (mounted) setState(() {});
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable) return;
    if (_isListening) {
      await _speech.stop();
      setState(() {
        _isListening = false;
        _orbState = OrbState.idle;
      });
    } else {
      setState(() {
        _isListening = true;
        _orbState = OrbState.thinking;
      });
      await _speech.listen(
        onResult: (result) {
          if (_isVoiceMode) {
            if (result.finalResult && result.recognizedWords.isNotEmpty) {
              _sendMessage(result.recognizedWords);
            }
          } else {
            setState(() {
              _controller.text = result.recognizedWords;
              _controller.selection = TextSelection.fromPosition(
                TextPosition(offset: _controller.text.length),
              );
            });
            if (result.finalResult && result.recognizedWords.isNotEmpty) {
              _sendMessage(result.recognizedWords);
            }
          }
        },
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _chatBloc.close();
    _dotController.dispose();
    _pulseController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text: text.trim(), isUser: true, time: _currentTime()));
      _controller.clear();
      _orbState = OrbState.thinking;
      _isListening = false;
    });
    _scrollToBottom();
    _chatBloc.add(ChatMessageSent(text.trim()));
  }

  String _currentTime() {
    final now = DateTime.now();
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final m = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _chatBloc,
      child: BlocListener<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatThinking) {
            setState(() => _orbState = OrbState.thinking);
          } else if (state is ChatReplied) {
            setState(() {
              _orbState = OrbState.speaking;
              _messages.add(_ChatMessage(
                text: state.reply,
                isUser: false,
                time: _currentTime(),
              ));
            });
            _scrollToBottom();
            Future.delayed(const Duration(milliseconds: 2200), () {
              if (mounted) setState(() => _orbState = OrbState.idle);
            });
          } else if (state is ChatError) {
            setState(() {
              _orbState = OrbState.idle;
              _messages.add(_ChatMessage(
                text: 'Sorry, something went wrong. Please try again.',
                isUser: false,
                time: _currentTime(),
              ));
            });
            _scrollToBottom();
          }
        },
        child: Scaffold(
          backgroundColor: _bg,
          body: Stack(
            children: [
              Positioned.fill(child: Image.asset('assets/background.png', fit: BoxFit.cover)),
              Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.15))),
              SafeArea(
                child: _isVoiceMode ? _buildVoiceView() : _buildTextView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Text Chat View ──────────────────────────────────────────────────────────

  Widget _buildTextView() {
    return Column(
      children: [
        _buildHeader(),
        _buildOrbSection(),
        Expanded(
          child: BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              final isThinking = state is ChatThinking;
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _messages.length + (isThinking ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && isThinking) {
                    return _buildThinkingBubble();
                  }
                  return _buildMessageBubble(_messages[index]);
                },
              );
            },
          ),
        ),
        _buildSuggestions(),
        _buildInputBar(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _cardBg,
        border: Border(bottom: BorderSide(color: _borderColor)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF374151), size: 16),
            ),
          ),
          const Spacer(),
          _ModeToggle(
            isVoiceMode: _isVoiceMode,
            onTextTap: () {},
            onVoiceTap: () => setState(() {
              _isVoiceMode = true;
              _orbState = OrbState.idle;
            }),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.settings_outlined,
                color: Color(0xFF374151), size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildOrbSection() {
    final label = switch (_orbState) {
      OrbState.idle => 'Chris · AI Financial Advisor',
      OrbState.thinking => 'Thinking...',
      OrbState.speaking => 'Responding',
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      height: _orbState == OrbState.idle ? 130 : 150,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ChrisVoiceOrb(state: _orbState, size: 88),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              label,
              key: ValueKey(label),
              style: TextStyles.bodySmall.copyWith(
                color: _orbState == OrbState.idle
                    ? _textSecondary
                    : _orbState == OrbState.thinking
                        ? _purple
                        : const Color(0xFF22C55E),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: msg.isUser ? _purple : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(msg.isUser ? 18 : 4),
                  bottomRight: Radius.circular(msg.isUser ? 4 : 18),
                ),
                border: msg.isUser ? null : Border.all(color: _borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                msg.text,
                style: TextStyles.bodyMedium.copyWith(
                  color: msg.isUser ? Colors.white : _textPrimary,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ),
            if (msg.time.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                msg.time,
                style: TextStyles.bodySmall.copyWith(
                  color: _textSecondary.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildThinkingBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: _borderColor),
            ),
            child: _ThinkingDots(controller: _dotController),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _sendMessage(_suggestions[index]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: _borderColor),
              ),
              child: Text(
                _suggestions[index],
                style: TextStyles.bodySmall.copyWith(
                  color: _textPrimary,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: _purple.withValues(alpha: 0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: _purple.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.attach_file_outlined, color: _textSecondary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              style: TextStyles.bodyMedium.copyWith(
                color: _textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Ask Chris anything...',
                hintStyle: TextStyles.bodyMedium.copyWith(
                  color: _textSecondary,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _toggleListening,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none_outlined,
                key: ValueKey(_isListening),
                color: _isListening ? _purple : _textSecondary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _sendMessage(_controller.text),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: _purple,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // ── Voice Chat View ─────────────────────────────────────────────────────────

  Widget _buildVoiceView() {
    final statusText = switch (_orbState) {
      OrbState.idle => _isListening ? 'AI is listening...' : 'Tap mic to speak',
      OrbState.thinking => 'Chris is thinking...',
      OrbState.speaking => 'Chris is speaking...',
    };

    return Column(
      children: [
        _buildVoiceHeader(),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (_, child) {
                    final scale = _isListening
                        ? 1.0 + _pulseController.value * 0.10
                        : 1.0;
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: Container(
                    width: 216,
                    height: 216,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _purple.withValues(alpha: _isListening ? 0.22 : 0.10),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: ChrisVoiceOrb(state: _orbState, size: 185),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    statusText,
                    key: ValueKey(statusText),
                    style: TextStyles.titleMedium.copyWith(
                      color: _textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildVoiceControls(),
        const SizedBox(height: 36),
      ],
    );
  }

  Widget _buildVoiceHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _cardBg,
        border: Border(bottom: BorderSide(color: _borderColor)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF374151), size: 16),
            ),
          ),
          const Spacer(),
          _ModeToggle(
            isVoiceMode: _isVoiceMode,
            onTextTap: () => setState(() {
              _isVoiceMode = false;
              if (_isListening) {
                _speech.stop();
                _isListening = false;
                _orbState = OrbState.idle;
              }
            }),
            onVoiceTap: () {},
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.settings_outlined,
                color: Color(0xFF374151), size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _VoiceControlBtn(icon: Icons.volume_up_rounded, onTap: () {}),
          GestureDetector(
            onTap: _toggleListening,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) => Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _purple,
                  boxShadow: [
                    BoxShadow(
                      color: _purple.withValues(
                        alpha: _isListening
                            ? 0.35 + _pulseController.value * 0.2
                            : 0.2,
                      ),
                      blurRadius: _isListening ? 24 : 12,
                      spreadRadius: _isListening ? 4 : 0,
                    ),
                  ],
                ),
                child: Icon(
                  _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
          _VoiceControlBtn(
              icon: Icons.switch_access_shortcut_rounded, onTap: () {}),
        ],
      ),
    );
  }
}

// ── Shared widgets ─────────────────────────────────────────────────────────────

class _ModeToggle extends StatelessWidget {
  final bool isVoiceMode;
  final VoidCallback onTextTap;
  final VoidCallback onVoiceTap;

  const _ModeToggle({
    required this.isVoiceMode,
    required this.onTextTap,
    required this.onVoiceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ModeTab(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Text',
            isActive: !isVoiceMode,
            onTap: onTextTap,
          ),
          _ModeTab(
            icon: Icons.graphic_eq_rounded,
            label: 'Voice',
            isActive: isVoiceMode,
            onTap: onVoiceTap,
          ),
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeTab({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive
                  ? const Color(0xFF1A1A2E)
                  : const Color(0xFF6B7080),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? const Color(0xFF1A1A2E)
                    : const Color(0xFF6B7080),
                fontSize: 12,
                fontWeight:
                    isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoiceControlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _VoiceControlBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE8EAF0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF374151), size: 22),
      ),
    );
  }
}

class _ThinkingDots extends StatelessWidget {
  final AnimationController controller;
  const _ThinkingDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final progress =
                ((controller.value - delay) % 1.0).clamp(0.0, 1.0);
            final bounce =
                progress < 0.5 ? progress * 2 : (1.0 - progress) * 2;
            return Container(
              margin: const EdgeInsets.only(right: 5),
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: const Color(0xFF7C6EF0)
                    .withValues(alpha: 0.4 + bounce * 0.5),
                shape: BoxShape.circle,
              ),
              transform: Matrix4.translationValues(0, -4 * bounce, 0),
            );
          }),
        );
      },
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final String time;
  const _ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
  });
}
