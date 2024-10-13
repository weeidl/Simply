// import 'dart:convert';
// import 'dart:developer';
// import 'package:http/http.dart' as http;
// import 'package:sms_forward_app/key.dart';
// import 'package:sms_forward_app/models/messages.dart';
//
// const fcmServerUrl = 'https://fcm.googleapis.com/fcm/send';
//
// Future<void> sendPushMessages(List<String> tokens, Messages messages) async {
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
//   var sendFutures = <Future>[];
//
//   for (String token in tokens) {
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
//   try {
//     await Future.wait(sendFutures);
//   } catch (e) {
//     log("Произошла ошибка: $e");
//   }
// }

// Future<void> initLocalNotifications() async {
//   const AndroidInitializationSettings androidInitialize =
//   AndroidInitializationSettings('@mipmap/ic_launcher');
//   const DarwinInitializationSettings iosInitialize =
//   DarwinInitializationSettings();
//   const InitializationSettings initializationSettings =
//   InitializationSettings(
//     android: androidInitialize,
//     iOS: iosInitialize,
//   );
//
//   await flutterLocalNotificationsPlugin.initialize(
//     initializationSettings,
//   );
//
//   await FirebaseMessaging.instance
//       .setForegroundNotificationPresentationOptions(
//     alert: true,
//     badge: true,
//     sound: true,
//   );
//
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     debugPrint('Notification opened: ${message.messageId}');
//   });
//
//   FirebaseMessaging.instance
//       .getInitialMessage()
//       .then((RemoteMessage? message) {
//     if (message != null) {
//       debugPrint('Initial message received: ${message.messageId}');
//     }
//   });
//
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//     _showNotification(message);
//   });
//
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
//     _showNotification(message);
//   });
// }
//
// Future<void> _showNotification(RemoteMessage message) async {
//   try {
//     final BigTextStyleInformation bigTextStyleInformation =
//     BigTextStyleInformation(
//       message.notification?.body ?? '',
//       htmlFormatBigText: true,
//       contentTitle: message.notification?.title ?? '',
//       htmlFormatContentTitle: true,
//     );
//     final AndroidNotificationDetails androidPlatformChannelSpecifics =
//     AndroidNotificationDetails(
//       'sms_forward_channel',
//       'SMS Forward Notifications',
//       importance: Importance.max,
//       priority: Priority.high,
//       styleInformation: bigTextStyleInformation,
//       playSound: true,
//     );
//     final NotificationDetails platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//     );
//     await flutterLocalNotificationsPlugin.show(
//       0,
//       message.notification?.title,
//       message.notification?.body,
//       platformChannelSpecifics,
//       payload: message.data['body'],
//     );
//   } catch (e) {
//     debugPrint('Error showing notification: $e');
//   }
// }
