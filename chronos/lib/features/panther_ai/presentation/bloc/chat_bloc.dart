import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/send_message.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendMessage sendMessage;

  ChatBloc({required this.sendMessage}) : super(const ChatIdle()) {
    on<ChatMessageSent>(_onMessageSent);
  }

  Future<void> _onMessageSent(
      ChatMessageSent event, Emitter<ChatState> emit) async {
    emit(const ChatThinking());
    try {
      final response = await sendMessage(event.message);
      emit(ChatReplied(reply: response.reply, domain: response.domain));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }
}
