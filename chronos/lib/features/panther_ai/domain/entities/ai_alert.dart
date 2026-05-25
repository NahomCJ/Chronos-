class AiAlert {
  final String id;
  final String type;
  final String domain;
  final String title;
  final String message;
  final bool dismissed;
  final DateTime createdAt;

  const AiAlert({
    required this.id,
    required this.type,
    required this.domain,
    required this.title,
    required this.message,
    required this.dismissed,
    required this.createdAt,
  });
}
