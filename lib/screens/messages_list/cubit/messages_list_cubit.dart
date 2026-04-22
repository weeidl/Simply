import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simply/models/conversation.dart';
import 'package:simply/repositories/messages_repository.dart';

part 'messages_list_state.dart';

class MessagesListCubit extends Cubit<MessagesListState> {
  final MessagesRepository messagesRepository;
  StreamSubscription<List<Conversation>>? _conversationsSub;

  MessagesListCubit({required this.messagesRepository})
      : super(const MessagesListState()) {
    _bindConversations();
  }

  Future<void> refresh() async {
    await _bindConversations();
  }

  Future<void> markConversationRead(String conversationId) {
    return messagesRepository.markConversationRead(conversationId);
  }

  Future<void> _bindConversations() async {
    emit(state.copyWith(
      status: MessagesListStatus.loading,
      clearError: true,
    ));

    await _conversationsSub?.cancel();
    _conversationsSub = messagesRepository.watchConversations().listen(
      (items) {
        emit(state.copyWith(
          status: MessagesListStatus.loaded,
          items: items,
          clearError: true,
        ));
      },
      onError: (Object error, StackTrace stackTrace) {
        emit(state.copyWith(
          status: MessagesListStatus.error,
          errorMessage: error.toString(),
        ));
      },
    );
  }

  @override
  Future<void> close() async {
    await _conversationsSub?.cancel();
    return super.close();
  }
}
