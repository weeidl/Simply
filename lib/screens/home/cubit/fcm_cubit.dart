import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_forward_app/bloc/notification/background_message.dart';
import 'package:sms_forward_app/bloc/update_message_stream.dart';
import 'package:sms_forward_app/models/message.dart';
import 'package:sms_forward_app/models/messages.dart';
import 'package:sms_forward_app/repositories/device_repository.dart';
import 'package:sms_forward_app/repositories/messages_repository.dart';
import 'package:telephony/telephony.dart';

part 'fcm_state.dart';

const fcmServerUrl = 'https://fcm.googleapis.com/fcm/send';
const authorizationKey =
    'AAAAg2Ra7cE:APA91bHa6clWgpg3u8S66q9ZeMwV08sS_3T54pfi2A0XlgvxYANsgmc5QI7lDu7vHH20u96Gy_4Ywnt9Qdo3L2rcJPW2DmMbC-Tyxz6B44RM4tL8QM7gOKdaI9j2cnEJlsgpcMzbRcCw';

class FcmCubit extends Cubit<FcmState> {
  final Telephony telephony = Telephony.instance;
  final DeviceRepository _deviceRepository = DeviceRepository();
  final MessagesRepository _messagesRepository = MessagesRepository();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  FcmCubit() : super(FcmState());

  Future<void> init() async {
    if (Platform.isAndroid) {
      await telephony.requestPhoneAndSmsPermissions;
      telephony.listenIncomingSms(
        onNewMessage: onNewMessage,
        onBackgroundMessage: onBackgroundMessage,
        listenInBackground: true,
      );
    }

    await initLocalNotifications();
    await requestPermission();
  }

  Future<void> requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }

  Future<void> onNewMessage(SmsMessage msg) async {
    try {
      final List<String> tokens =
          await _deviceRepository.getTokensForAllDevices(
        _deviceRepository.id,
      );
      final Messages messages = Messages.updateFireStore(msg);
      final MessageDetails messageTitle = MessageDetails.updateFireStore(msg);

      await sendPushMessages(tokens, messages);
      await _messagesRepository.sendMessageFirebase(
        messages: messages,
        messageTitle: messageTitle,
      );
      UpdateMessageStream.controller.add('');
    } catch (e) {
      debugPrint('Error handling new message: $e');
    }
  }

  Future<void> initLocalNotifications() async {
    const AndroidInitializationSettings androidInitialize =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInitialize =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitialize,
      iOS: iosInitialize,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification opened: ${message.messageId}');
    });

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('Initial message received: ${message.messageId}');
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      _showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      _showNotification(message);
    });
  }

  Future<void> _showNotification(RemoteMessage message) async {
    try {
      final BigTextStyleInformation bigTextStyleInformation =
          BigTextStyleInformation(
        message.notification?.body ?? '',
        htmlFormatBigText: true,
        contentTitle: message.notification?.title ?? '',
        htmlFormatContentTitle: true,
      );
      final AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'sms_forward_channel',
        'SMS Forward Notifications',
        importance: Importance.max,
        priority: Priority.high,
        styleInformation: bigTextStyleInformation,
        playSound: true,
      );
      final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );
      await flutterLocalNotificationsPlugin.show(
        0,
        message.notification?.title,
        message.notification?.body,
        platformChannelSpecifics,
        payload: message.data['body'],
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  Future<void> sendPushMessages(List<String> tokens, Messages messages) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final deviceToken = prefs.getString('device_token');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$authorizationKey',
      };
      final messagePayload = jsonEncode({
        'priority': 'high',
        'content_available': true,
        'apns': {
          'headers': {
            'apns-priority': '10',
          },
          'payload': {
            'aps': {
              'alert': {
                'title': messages.title,
                'body': messages.lastMessage,
              },
              'sound': 'default',
            },
          },
        },
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
        if (token != deviceToken) {
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
        }
      }

      await Future.wait(sendFutures);
    } catch (e) {
      log("Error sending push messages: $e");
    }
  }
}
