part of 'messages_list_cubit.dart';

enum MessagesListStatus {
  loading,
  loaded,
  error,
}

@immutable
class MessagesListState extends Equatable {
  const MessagesListState({
    this.status = MessagesListStatus.loading,
    this.items = const [],
    this.errorMessage,
  });

  final MessagesListStatus status;
  final List<Conversation> items;
  final String? errorMessage;

  bool get isLoading => status == MessagesListStatus.loading;
  bool get isLoaded => status == MessagesListStatus.loaded;
  bool get hasError => status == MessagesListStatus.error;

  MessagesListState copyWith({
    MessagesListStatus? status,
    List<Conversation>? items,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MessagesListState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
