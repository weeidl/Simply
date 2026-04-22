part of 'message_details_cubit.dart';

enum MessageDetailsStatus {
  loading,
  loaded,
  error,
}

@immutable
class MessageDetailsState extends Equatable {
  const MessageDetailsState({
    this.status = MessageDetailsStatus.loading,
    this.items = const [],
    this.errorMessage,
  });

  final MessageDetailsStatus status;
  final List<Message> items;
  final String? errorMessage;

  bool get isLoading => status == MessageDetailsStatus.loading;
  bool get isLoaded => status == MessageDetailsStatus.loaded;
  bool get hasError => status == MessageDetailsStatus.error;

  MessageDetailsState copyWith({
    MessageDetailsStatus? status,
    List<Message>? items,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MessageDetailsState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
