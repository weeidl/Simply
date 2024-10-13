import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sms_forward_app/bloc/notification/background_message.dart';
import 'package:sms_forward_app/bloc/update_message_stream.dart';
import 'package:sms_forward_app/models/message.dart';
import 'package:sms_forward_app/models/messages.dart';
import 'package:sms_forward_app/repositories/messages_repository.dart';
import 'package:telephony/telephony.dart';
import 'package:workmanager/workmanager.dart';

part 'fcm_state.dart';

const fcmServerUrl = 'https://fcm.googleapis.com/fcm/send';

class FcmCubit extends Cubit<FcmState> {
  final telephony = Telephony.instance;
  final _messagesRepository = MessagesRepository();
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  FcmCubit() : super(FcmState());

  Future<void> init() async {
    if (Platform.isAndroid) {
      await telephony.requestPhoneAndSmsPermissions;
      telephony.listenIncomingSms(
        onNewMessage: onNewMessage,
        onBackgroundMessage: onBackgroundMessage,
        listenInBackground: true,
      );
      await _initNotifications();
      await FirebaseMessaging.instance.requestPermission();
      _scheduleBackgroundTask();
      _showNotification();
    }
  }

  Future<void> _initNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await flutterLocalNotificationsPlugin.initialize(initSettings);
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _scheduleBackgroundTask() {
    Workmanager().registerPeriodicTask(
      "1",
      "sendFirebaseMessageTask",
      frequency: const Duration(minutes: 15),
    );
  }

  Future<void> _showNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'foreground_channel_id',
      'Foreground Service',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
    );
    const platformDetails = NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Running in the background',
      'For the application to function stably, make sure it remains in the list of background running apps',
      platformDetails,
    );
  }

  Future<void> onNewMessage(SmsMessage msg) async {
    try {
      final messages = Messages.updateFireStore(msg);
      final MessageDetails messageTitle = MessageDetails.updateFireStore(msg);

      await _messagesRepository.sendMessageFirebase(
        messages: messages,
        messageTitle: messageTitle,
      );
      UpdateMessageStream.controller.add('');
    } catch (e) {
      debugPrint('Error handling new message: $e');
    }
  }
}
