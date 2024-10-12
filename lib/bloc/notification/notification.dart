// import 'dart:convert';
// import 'dart:developer';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sms_forward_app/models/messages.dart';
//
const fcmServerUrl = 'https://fcm.googleapis.com/fcm/send';
const authorizationKey =
    'AAAAg2Ra7cE:APA91bHa6clWgpg3u8S66q9ZeMwV08sS_3T54pfi2A0XlgvxYANsgmc5QI7lDu7vHH20u96Gy_4Ywnt9Qdo3L2rcJPW2DmMbC-Tyxz6B44RM4tL8QM7gOKdaI9j2cnEJlsgpcMzbRcCw';
//
// Future<void> sendPushMessages(List<String> tokens, Messages messages) async {
//   print('-=-=--=-=-=-sdfsdfsdfdsfsdfdsf1');
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   final deviceToken = prefs.getString('device_token');
//   final headers = <String, String>{
//     'Content-Type': 'application/json',
//     'Authorization': 'key=$authorizationKey',
//   };
//   final messagePayload = jsonEncode({
//     'priority': 'high',
//     'data': {
//       'click_action': 'FLUTTER_NOTIFICATION_CLICK',
//       'status': 'done',
//       'body': messages.lastMessage,
//       'title': messages.title,
//     },
//     'notification': {
//       'title': messages.title,
//       'body': messages.lastMessage,
//     },
//   });
//   print('-=-=--=-=-=-sdfsdfsdfdsfsdfdsf2');
//   var sendFutures = <Future>[];
//
//   for (String token in tokens) {
//     print(tokens.length);
//     print(token);
//     print('-=-=--=-=-=-sdfsdfsdfdsfsdfdsf4');
//     // if (token != deviceToken) {
//     sendFutures.add(
//       http.post(
//         Uri.parse(fcmServerUrl),
//         headers: headers,
//         body: jsonEncode({
//           ...json.decode(messagePayload),
//           'to': token,
//         }),
//       ),
//     );
//     // }
//   }
//   print('-=-=--=-=-=-sdfsdfsdfdsfsdfdsf3');
//   try {
//     await Future.wait(sendFutures);
//   } catch (e) {
//     log("Произошла ошибка: $e");
//   }
// }
