import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simply/models/message.dart';
import 'package:simply/repositories/messages_repository.dart';

part 'message_details_state.dart';

class MessageDetailsCubit extends Cubit<MessageDetailsState> {
  final MessagesRepository messagesRepository;
  final String conversationId;
  StreamSubscription<List<Message>>? _messagesSub;

  MessageDetailsCubit({
    required this.messagesRepository,
    required this.conversationId,
  }) : super(const MessageDetailsState()) {
    _bindMessages();
  }

  Future<void> refresh() async {
    await _bindMessages();
  }

  Future<void> _bindMessages() async {
    emit(state.copyWith(
      status: MessageDetailsStatus.loading,
      clearError: true,
    ));

    await _messagesSub?.cancel();
    _messagesSub = messagesRepository.watchMessages(conversationId).listen(
      (items) {
        emit(state.copyWith(
          status: MessageDetailsStatus.loaded,
          items: items,
          clearError: true,
        ));
      },
      onError: (Object error, StackTrace stackTrace) {
        emit(state.copyWith(
          status: MessageDetailsStatus.error,
          errorMessage: error.toString(),
        ));
      },
    );
  }

  @override
  Future<void> close() async {
    await _messagesSub?.cancel();
    return super.close();
  }
}
