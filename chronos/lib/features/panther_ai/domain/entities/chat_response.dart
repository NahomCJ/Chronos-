class ChatResponse {
  final String reply;
  final String domain;
  final String userLevel;
  final DateTime timestamp;

  const ChatResponse({
    required this.reply,
    required this.domain,
    required this.userLevel,
    required this.timestamp,
  });
}
