import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simply/bloc/update_message_stream.dart';
import 'package:simply/models/messages.dart';
import 'package:simply/repositories/messages_repository.dart';
import 'package:simply/screens/common/standard_list_cubit.dart';
import 'package:simply/screens/common/status.dart';

class MessagesListCubit extends StandardListCubit<Messages> {
  final MessagesRepository messagesRepository;
  StreamSubscription<String>? _incomingSub;

  MessagesListCubit({required this.messagesRepository})
      : super(
          fetch: ({DocumentSnapshot? startAfter}) {
            return messagesRepository.fetchMessages(startAfter: startAfter);
          },
        ) {
    fetch();
    _incomingSub = UpdateMessageStream.stream.listen((_) async {
      final response = await messagesRepository.fetchMessages();
      emit(state.copyWith(
        items: response.items,
        lastDocument: response.lastDocument,
        status: StandardStatus.loaded,
        hasNext: response.items.isNotEmpty,
      ));
    });
  }

  Future<void> updatedUnreadMessagesCount(Messages message) async {
    await messagesRepository.markConversationRead(message.title);
  }

  @override
  Future<void> close() {
    _incomingSub?.cancel();
    return super.close();
  }
}
