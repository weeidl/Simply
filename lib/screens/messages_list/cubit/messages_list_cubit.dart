import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simply/bloc/update_message_stream.dart';
import 'package:simply/models/messages.dart';
import 'package:simply/repositories/messages_repository.dart';
import 'package:simply/screens/common/standard_list_cubit.dart';
import 'package:simply/screens/common/status.dart';

class MessagesListCubit extends StandardListCubit<Messages> {
  final MessagesRepository messagesRepository;

  MessagesListCubit({required this.messagesRepository})
      : super(
          fetch: ({DocumentSnapshot? startAfter}) {
            return messagesRepository.fetchMessages(startAfter: startAfter);
          },
        ) {
    fetch();
    initStream();
  }

  void initStream() {
    UpdateMessageStream.stream.listen((event) async {
      final response = await messagesRepository.fetchMessages();
      emit(state.copyWith(
        items: [...state.items, ...response.items],
        lastDocument: response.lastDocument,
        status: StandardStatus.loaded,
      ));
    });
  }

  Future<void> updatedUnreadMessagesCount(Messages message) async {
    await messagesRepository.update(message.id, message.title);
  }
}
