import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simply/models/conversation.dart';
import 'package:simply/repositories/messages_repository.dart';
import 'package:simply/utils/code_extractor.dart';

part 'messages_list_state.dart';

/// Categories the user can switch between with the chip row above the list.
///
/// The repository doesn't yet tag conversations, so [unread] and [withCode]
/// are computed locally and the named tags fall back to the [Conversation]
/// `category` field when present.
enum MessagesFilter { all, unread, banks, codes, delivery }

class MessagesListCubit extends Cubit<MessagesListState> {
  final MessagesRepository messagesRepository;
  StreamSubscription<List<Conversation>>? _conversationsSub;

  MessagesListCubit({required this.messagesRepository})
      : super(const MessagesListState()) {
    _bindConversations();
  }

  Future<void> refresh() => _bindConversations();

  Future<void> markConversationRead(String conversationId) {
    return messagesRepository.markConversationRead(conversationId);
  }

  void setFilter(MessagesFilter filter) {
    if (filter == state.filter) return;
    emit(state.copyWith(filter: filter));
  }

  void setQuery(String query) {
    final trimmed = query.trim();
    if (trimmed == state.query) return;
    emit(state.copyWith(query: trimmed));
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
