import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sms_forward_app/bloc/notification/background_message.dart';
import 'package:sms_forward_app/bloc/notification/notification.dart';
import 'package:sms_forward_app/bloc/update_message_stream.dart';
import 'package:sms_forward_app/models/message.dart';
import 'package:sms_forward_app/models/messages.dart';
import 'package:sms_forward_app/repositories/device_repository.dart';
import 'package:sms_forward_app/repositories/messages_repository.dart';
import 'package:telephony/telephony.dart';

part 'fcm_state.dart';

class FcmCubit extends Cubit<FcmState> {
  final Telephony telephony = Telephony.instance;
  final DeviceRepository _deviceRepository = DeviceRepository();
  final MessagesRepository _messagesRepository = MessagesRepository();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  FcmCubit() : super(FcmState());

  Future<void> init() async {
    if (Platform.isAndroid) telephony.requestPhoneAndSmsPermissions;

    if (Platform.isAndroid) {
      telephony.listenIncomingSms(
        onNewMessage: onNewMessage,
        onBackgroundMessage: onBackgroundMessage,
        listenInBackground: true,
      );
    }

    initInfo();
    requestPermission();
  }

  Future<void> onNewMessage(SmsMessage msg) async {
    List<String> token;
    Messages messages = Messages.updateFireStore(msg);
    MessageThread messageTitle = MessageThread.updateFireStore(msg);

    token = await _deviceRepository.getTokensForAllDevices(
      _deviceRepository.id,
    );

    sendPushMessages(token, messages);

    _messagesRepository.sendMessageFirebase(
      messages: messages,
      messageTitle: messageTitle,
    );

    UpdateMessageStream.controller.add('');
  }

  initInfo() {
    var androidInitialize =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var ioSInitialize = const DarwinInitializationSettings();
    var initializationsSettings =
        InitializationSettings(android: androidInitialize, iOS: ioSInitialize);
    flutterLocalNotificationsPlugin.initialize(
      initializationsSettings,
      //     onSelectNotification: (String? payload) async {
      //   try {
      //     if (payload != null && payload.isNotEmpty) {
      //     } else {}
      //   } catch (e) {}
      //   return;
      // });
    );
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        message.notification!.body.toString(),
        htmlFormatBigText: true,
        contentTitle: message.notification!.title.toString(),
        htmlFormatContentTitle: true,
      );
      AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'defood', 'Ibfood', importance: Importance.max,
        styleInformation: bigTextStyleInformation, priority: Priority.max,
        playSound: true,
// sound: RawResourceAndroidNotificationSound ('notification'),
      );
      NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        // iOS: IOSNotificationDetails(),
      );
      await flutterLocalNotificationsPlugin.show(0, message.notification?.title,
          message.notification?.body, platformChannelSpecifics,
          payload: message.data['body']);
    });
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User grandet permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User grandet provisional permission');
    } else {
      print('User decloned');
    }
  }
}
