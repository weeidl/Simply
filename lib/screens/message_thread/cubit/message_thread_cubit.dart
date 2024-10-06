import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:sms_forward_app/models/message.dart';
import 'package:sms_forward_app/repositories/messages_repository.dart';

part 'message_thread_state.dart';

class MessageThreadCubit extends Cubit<MessageThreadState> {
  final MessagesRepository messagesRepository;

  MessageThreadCubit({required this.messagesRepository})
      : super(MessageThreadInitial());

  Future<void> fetch(String id, String title) async {
    emit(MessageThreadLoading());

    try {
      final response = await messagesRepository.fetchMessage(id);
      await messagesRepository.fetchMessage(id);
      await messagesRepository.update(id, title);
      emit(MessageThreadLoaded(items: response));
    } catch (e) {
      emit(MessageError(message: e.toString()));
    }
  }
}
