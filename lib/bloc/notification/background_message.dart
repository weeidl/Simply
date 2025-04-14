import 'package:another_telephony/telephony.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:simply/bloc/update_message_stream.dart';
import 'package:simply/models/message.dart';
import 'package:simply/models/messages.dart';
import 'package:simply/repositories/messages_repository.dart';

void onBackgroundMessage(SmsMessage msg) async {
  await Firebase.initializeApp();
  Messages messages = Messages.updateFireStore(msg);
  MessageDetails messageTitle = MessageDetails.updateFireStore(msg);
  addMessagesBackground(messages: messages, messageTitle: messageTitle);
  UpdateMessageStream.controller.add('');
}

void addMessagesBackground({
  required Messages messages,
  required MessageDetails messageTitle,
}) async {
  final MessagesRepository messagesRepository = MessagesRepository();

  messagesRepository.sendMessageFirebase(
    messages: messages,
    messageTitle: messageTitle,
  );
}
