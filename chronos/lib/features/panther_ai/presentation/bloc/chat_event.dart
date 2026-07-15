abstract class ChatEvent {
  const ChatEvent();
}

class ChatMessageSent extends ChatEvent {
  final String message;
  final List<Map<String, String>> history;
  const ChatMessageSent(this.message, {this.history = const []});
}
