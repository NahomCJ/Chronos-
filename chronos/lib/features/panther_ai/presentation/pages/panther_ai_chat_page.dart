import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
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

  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text: "Hello! I'm Chris, your AI financial advisor. What can I do for you today?",
      isUser: false,
      time: '',
    ),
  ];

  late AnimationController _dotController;
  OrbState _orbState = OrbState.idle;

  // ── Voice input ──────────────────────────────────────────────────────────
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;
  bool _isListening = false;

  final List<String> _suggestions = [
    'Show my balance',
    'Why is my spending high?',
    'Rebalance portfolio',
    'Credit score tips',
  ];

  @override
  void initState() {
    super.initState();
    _chatBloc = GetIt.I<ChatBloc>();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
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
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _controller.text = result.recognizedWords;
            _controller.selection = TextSelection.fromPosition(
              TextPosition(offset: _controller.text.length),
            );
          });
          if (result.finalResult && result.recognizedWords.isNotEmpty) {
            _sendMessage(result.recognizedWords);
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
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(
        _ChatMessage(text: text.trim(), isUser: true, time: _currentTime()),
      );
      _controller.clear();
      _orbState = OrbState.thinking;
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
            // Return to idle after speaking animation
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
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset('assets/background.png', fit: BoxFit.cover),
              ),
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(context),
                    _buildOrbSection(),
                    Expanded(
                      child: BlocBuilder<ChatBloc, ChatState>(
                        builder: (context, state) {
                          final isThinking = state is ChatThinking;
                          return ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount:
                                _messages.length + (isThinking ? 1 : 0),
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
                ),
              ),
            ],
          ),
        ),
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
      height: _orbState == OrbState.idle ? 150 : 170,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ChrisVoiceOrb(state: _orbState, size: 110),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              label,
              key: ValueKey(label),
              style: TextStyles.bodySmall.copyWith(
                color: _orbState == OrbState.idle
                    ? Colors.white.withValues(alpha: 0.45)
                    : _orbState == OrbState.thinking
                        ? const Color(0xFF8AAAFF).withValues(alpha: 0.85)
                        : const Color(0xFFDC8F4A).withValues(alpha: 0.90),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 38,
                  height: 38,
                  child: ChrisVoiceOrb(state: _orbState, size: 38),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chronos',
                      style: TextStyles.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Active',
                      style: TextStyles.bodySmall.copyWith(
                        color: const Color(0xFF22C55E),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.settings_outlined,
              color: Colors.white.withValues(alpha: 0.7),
              size: 22,
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: msg.isUser
                    ? Colors.white.withValues(alpha: 0.18)
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(msg.isUser ? 18 : 4),
                  bottomRight: Radius.circular(msg.isUser ? 4 : 18),
                ),
              ),
              child: Text(
                msg.text,
                style: TextStyles.bodyMedium.copyWith(
                  color: Colors.white,
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
                  color: Colors.white.withValues(alpha: 0.35),
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
          _ThinkingDots(controller: _dotController),
          const SizedBox(width: 10),
          Text(
            'Thinking',
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 13,
            ),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Text(
                _suggestions[index],
                style: TextStyles.bodySmall.copyWith(
                  color: Colors.white,
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
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.attach_file_outlined,
            color: Colors.white.withValues(alpha: 0.45),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              style: TextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Ask Chris anything...',
                hintStyle: TextStyles.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.35),
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
                color: _isListening
                    ? const Color(0xFFDC8F4A)
                    : Colors.white.withValues(alpha: 0.45),
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
                color: Color(0xFFDC8F4A),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
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
                color: Colors.white
                    .withValues(alpha: 0.3 + bounce * 0.5),
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
