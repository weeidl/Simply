part of 'messages_list_cubit.dart';

enum MessagesListStatus { loading, loaded, error }

@immutable
class MessagesListState extends Equatable {
  const MessagesListState({
    this.status = MessagesListStatus.loading,
    this.items = const [],
    this.filter = MessagesFilter.all,
    this.query = '',
    this.errorMessage,
  });

  final MessagesListStatus status;
  final List<Conversation> items;
  final MessagesFilter filter;
  final String query;
  final String? errorMessage;

  bool get isLoading => status == MessagesListStatus.loading;
  bool get isLoaded => status == MessagesListStatus.loaded;
  bool get hasError => status == MessagesListStatus.error;

  /// Items after applying the current chip filter and search query.
  List<Conversation> get filteredItems {
    Iterable<Conversation> list = items;
    switch (filter) {
      case MessagesFilter.all:
        break;
      case MessagesFilter.unread:
        list = list.where((c) => c.unreadMessagesCount > 0);
        break;
      case MessagesFilter.codes:
        list = list.where((c) => CodeExtractor.hasCode(c.lastMessage));
        break;
      case MessagesFilter.banks:
        list = list.where((c) =>
            (c.category ?? '').toLowerCase().contains('bank') ||
            (c.category ?? '').toLowerCase().contains('банк'));
        break;
      case MessagesFilter.delivery:
        list = list.where((c) =>
            (c.category ?? '').toLowerCase().contains('delivery') ||
            (c.category ?? '').toLowerCase().contains('достав'));
        break;
    }
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      list = list.where((c) =>
          c.title.toLowerCase().contains(q) ||
          c.lastMessage.toLowerCase().contains(q));
    }
    return list.toList(growable: false);
  }

  int get unreadCount =>
      items.where((c) => c.unreadMessagesCount > 0).length;

  int get totalCount => items.length;

  MessagesListState copyWith({
    MessagesListStatus? status,
    List<Conversation>? items,
    MessagesFilter? filter,
    String? query,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MessagesListState(
      status: status ?? this.status,
      items: items ?? this.items,
      filter: filter ?? this.filter,
      query: query ?? this.query,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [status, items, filter, query, errorMessage];
}
