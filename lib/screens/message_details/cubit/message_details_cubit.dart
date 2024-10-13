import 'package:simply/models/message.dart';
import 'package:simply/repositories/messages_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simply/screens/common/standard_list_cubit.dart';

class MessageDetailsCubit extends StandardListCubit<MessageDetails> {
  final MessagesRepository messagesRepository;
  final String id;

  MessageDetailsCubit({
    required this.messagesRepository,
    required this.id,
  }) : super(
          fetch: ({DocumentSnapshot? startAfter}) {
            return messagesRepository.fetchMessage(
              id,
              startAfter: startAfter,
            );
          },
        ) {
    fetch();
  }
}
