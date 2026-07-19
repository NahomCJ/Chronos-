import '../entities/chat_response.dart';
import '../repositories/panther_ai_repository.dart';

class SendMessage {
  final PantherAiRepository repository;
  SendMessage(this.repository);
  Future<ChatResponse> call(
    String message, {
    List<Map<String, String>> history = const [],
  }) =>
      repository.sendMessage(message, history: history);
}
