abstract class ChatEvent {
  const ChatEvent();
}

class ChatMessageSent extends ChatEvent {
  final String message;
  const ChatMessageSent(this.message);
}
