import 'dart:io';
import 'package:another_telephony/telephony.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    hide Message;
import 'package:simply/bloc/notification/background_message.dart';
import 'package:simply/models/conversation.dart';
import 'package:simply/models/message.dart';
import 'package:simply/repositories/messages_repository.dart';

part 'fcm_state.dart';

const fcmServerUrl = 'https://fcm.googleapis.com/fcm/send';

class FcmCubit extends Cubit<FcmState> {
  final telephony = Telephony.instance;
  final _messagesRepository = MessagesRepository();
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  FcmCubit() : super(FcmState());

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    if (Platform.isAndroid) {
      await telephony.requestPhoneAndSmsPermissions;
      telephony.listenIncomingSms(
        onNewMessage: onNewMessage,
        onBackgroundMessage: onBackgroundMessage,
        listenInBackground: true,
      );
      await _initNotifications();
      await FirebaseMessaging.instance.requestPermission();
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
      await _messagesRepository.saveIncomingMessage(
        conversation: Conversation.fromSms(msg),
        message: Message.fromSms(msg),
      );
    } catch (e) {
      debugPrint('Error handling new message: $e');
    }
  }

  @override
  Future<void> close() async {
    await flutterLocalNotificationsPlugin.cancel(0);
    return super.close();
  }
}
