part of 'message_thread_cubit.dart';

abstract class MessageThreadState {}

class MessageThreadInitial extends MessageThreadState {}

class MessageThreadLoading extends MessageThreadState {}

class MessageThreadLoaded extends MessageThreadState {
  final List<MessageThread> _items;

  MessageThreadLoaded({
    required List<MessageThread> items,
  }) : _items = items;

  List<MessageThread> get items => _items;

  MessageThreadLoaded copyWith({
    List<MessageThread>? items,
  }) {
    return MessageThreadLoaded(
      items: items ?? _items,
    );
  }
}

class MessageError extends MessageThreadState {
  final String message;

  MessageError({required this.message});
}
