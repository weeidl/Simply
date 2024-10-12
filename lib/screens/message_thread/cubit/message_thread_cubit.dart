import 'package:sms_forward_app/models/message.dart';
import 'package:sms_forward_app/repositories/messages_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sms_forward_app/screens/common/standard_list_cubit.dart';

class MessageThreadCubit extends StandardListCubit<MessageThread> {
  final MessagesRepository messagesRepository;
  final String id;

  MessageThreadCubit({
    required this.messagesRepository,
    required this.id,
  }) : super(
          fetch: ({DocumentSnapshot? startAfter}) =>
              messagesRepository.fetchMessage(
            id,
            limit: 20,
            startAfter: startAfter,
          ),
        ) {
    fetch();
  }
}
