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

const defaultMessagesFilters = <MessagesFilter>{
  MessagesFilter.all,
  MessagesFilter.unread,
  MessagesFilter.codes,
  MessagesFilter.banks,
  MessagesFilter.delivery,
};

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

  Future<void> deleteConversation(String conversationId) async {
    await messagesRepository.deleteConversation(conversationId);
    if (state.selectedConversationIds.contains(conversationId)) {
      final next = Set<String>.from(state.selectedConversationIds)
        ..remove(conversationId);
      emit(state.copyWith(selectedConversationIds: next));
    }
  }

  Future<void> deleteSelectedConversations() async {
    final selected = state.selectedConversationIds.toList(growable: false);
    for (final conversationId in selected) {
      await messagesRepository.deleteConversation(conversationId);
    }
    emit(state.copyWith(clearSelectedConversations: true));
  }

  Future<void> markSelectedRead() async {
    final selected = state.selectedConversationIds.toList(growable: false);
    for (final conversationId in selected) {
      await messagesRepository.markConversationRead(conversationId);
    }
    emit(state.copyWith(clearSelectedConversations: true));
  }

  void selectConversation(String conversationId) {
    if (state.selectedConversationIds.contains(conversationId)) return;
    emit(
      state.copyWith(
        selectedConversationIds: {
          ...state.selectedConversationIds,
          conversationId,
        },
      ),
    );
  }

  void toggleConversationSelection(String conversationId) {
    final next = Set<String>.from(state.selectedConversationIds);
    if (!next.add(conversationId)) {
      next.remove(conversationId);
    }
    emit(state.copyWith(selectedConversationIds: next));
  }

  void clearSelection() {
    if (!state.isSelectionMode) return;
    emit(state.copyWith(clearSelectedConversations: true));
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

  void setFilterEnabled(MessagesFilter filter, bool enabled) {
    if (filter == MessagesFilter.all) return;
    final next = Set<MessagesFilter>.from(state.enabledFilters);
    if (enabled) {
      next.add(filter);
    } else {
      next.remove(filter);
    }
    if (next.length == state.enabledFilters.length &&
        next.containsAll(state.enabledFilters)) {
      return;
    }
    emit(
      state.copyWith(
        enabledFilters: next,
        filter: next.contains(state.filter) ? state.filter : MessagesFilter.all,
      ),
    );
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
