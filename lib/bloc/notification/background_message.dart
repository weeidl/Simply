import 'package:firebase_core/firebase_core.dart';
import 'package:sms_forward_app/bloc/notification/notification.dart';
import 'package:sms_forward_app/bloc/update_message_stream.dart';
import 'package:sms_forward_app/models/message.dart';
import 'package:sms_forward_app/models/messages.dart';
import 'package:sms_forward_app/repositories/device_repository.dart';
import 'package:sms_forward_app/repositories/messages_repository.dart';
import 'package:telephony/telephony.dart';

void onBackgroundMessage(SmsMessage msg) async {
  await Firebase.initializeApp();
  Messages messages = Messages.updateFireStore(msg);
  MessageDetails messageTitle = MessageDetails.updateFireStore(msg);

  getTokenBackground(messages);
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

void getTokenBackground(Messages messages) async {
  List<String> token;
  final DeviceRepository deviceRepository = DeviceRepository();

  token = await deviceRepository.getTokensForAllDevices(
    deviceRepository.id,
  );

  sendPushMessages(token, messages);
}
