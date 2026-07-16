import 'chat_visual.dart';

abstract class ChatState {
  const ChatState();
}

class ChatIdle extends ChatState {
  const ChatIdle();
}

class ChatThinking extends ChatState {
  const ChatThinking();
}

class ChatReplied extends ChatState {
  final String reply;
  final String domain;
  final ChatVisual? visual;
  const ChatReplied({required this.reply, required this.domain, this.visual});
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);
}
