import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:sms_forward_app/key.dart';
import 'package:sms_forward_app/models/messages.dart';

const fcmServerUrl = 'https://fcm.googleapis.com/fcm/send';

Future<void> sendPushMessages(List<String> tokens, Messages messages) async {
  final headers = <String, String>{
    'Content-Type': 'application/json',
    'Authorization': 'key=$authorizationKey',
  };
  final messagePayload = jsonEncode({
    'priority': 'high',
    'data': {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'status': 'done',
      'body': messages.lastMessage,
      'title': messages.title,
    },
    'notification': {
      'title': messages.title,
      'body': messages.lastMessage,
    },
  });
  var sendFutures = <Future>[];

  for (String token in tokens) {
    // if (token != deviceToken) {
    sendFutures.add(
      http.post(
        Uri.parse(fcmServerUrl),
        headers: headers,
        body: jsonEncode({
          ...json.decode(messagePayload),
          'to': token,
        }),
      ),
    );
    // }
  }
  try {
    await Future.wait(sendFutures);
  } catch (e) {
    log("Произошла ошибка: $e");
  }
}
