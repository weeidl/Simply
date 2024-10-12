import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sms_forward_app/bloc/update_message_stream.dart';
import 'package:sms_forward_app/models/messages.dart';
import 'package:sms_forward_app/repositories/messages_repository.dart';
import 'package:sms_forward_app/screens/common/standard_list_cubit.dart';
import 'package:sms_forward_app/screens/common/status.dart';

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
}
