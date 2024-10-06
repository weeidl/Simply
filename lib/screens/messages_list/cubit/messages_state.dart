part of 'messages_cubit.dart';

abstract class MessagesState {}

class MessagesInitial extends MessagesState {}

class MessagesLoading extends MessagesState {}

class MessagesLoaded extends MessagesState {
  final List<Messages> _items;

  MessagesLoaded({
    required List<Messages> items,
  }) : _items = items;

  List<Messages> get items => _items;

  MessagesLoaded copyWith({
    List<Messages>? items,
  }) {
    return MessagesLoaded(
      items: items ?? _items,
    );
  }
}

class MessagesError extends MessagesState {
  final String message;

  MessagesError({required this.message});
}
