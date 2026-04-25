import 'dart:io';
import 'package:another_telephony/telephony.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    hide Message;
import 'package:simply/bloc/notification/background_message.dart';
import 'package:simply/bloc/notification/incoming_sms_sync_service.dart';
import 'package:simply/models/incoming_sms_payload.dart';
import 'package:simply/screens/home/foreground_runtime_notice.dart';
import 'package:simply/services/device_heartbeat_service.dart';
import 'package:simply/themes/colors.dart';

part 'fcm_state.dart';

const fcmServerUrl = 'https://fcm.googleapis.com/fcm/send';

class FcmCubit extends Cubit<FcmState> {
  final telephony = Telephony.instance;
  final IncomingSmsSyncService _incomingSmsSyncService;
  final DeviceHeartbeatService _deviceHeartbeatService;
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  bool _notificationsInitialized = false;

  FcmCubit({
    IncomingSmsSyncService? incomingSmsSyncService,
    DeviceHeartbeatService? deviceHeartbeatService,
  })  : _incomingSmsSyncService =
            incomingSmsSyncService ?? IncomingSmsSyncService(),
        _deviceHeartbeatService =
            deviceHeartbeatService ?? DeviceHeartbeatService(),
        super(FcmState());

  Future<void> init() async {
    if (!Platform.isAndroid) return;

    if (!_isInitialized) {
      _isInitialized = true;
      await _initNotifications();
      await FirebaseMessaging.instance.requestPermission();
    }

    await _registerSmsRuntime();
    await _incomingSmsSyncService.flushPending();
    await _showNotification();
    _deviceHeartbeatService.start();
  }

  Future<void> refreshRuntime() async {
    if (!Platform.isAndroid) return;
    await _registerSmsRuntime();
    await _incomingSmsSyncService.flushPending();
    await _deviceHeartbeatService.beatNow();
  }

  Future<void> _initNotifications() async {
    if (_notificationsInitialized) return;
    _notificationsInitialized = true;

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

  Future<void> _registerSmsRuntime() async {
    await telephony.requestPhoneAndSmsPermissions;
    telephony.listenIncomingSms(
      onNewMessage: onNewMessage,
      onBackgroundMessage: onBackgroundMessage,
      listenInBackground: true,
    );
  }

  Future<void> _showNotification() async {
    final androidDetails = AndroidNotificationDetails(
      ForegroundRuntimeNotice.channelId,
      ForegroundRuntimeNotice.channelName,
      channelDescription: ForegroundRuntimeNotice.channelDescription,
      icon: ForegroundRuntimeNotice.smallIcon,
      largeIcon:
          DrawableResourceAndroidBitmap(ForegroundRuntimeNotice.largeIcon),
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      color: AppColor.accentDeep,
    );
    final platformDetails = NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(
      0,
      ForegroundRuntimeNotice.title,
      ForegroundRuntimeNotice.body,
      platformDetails,
    );
  }

  Future<void> onNewMessage(SmsMessage msg) async {
    try {
      await _incomingSmsSyncService.handleIncomingSms(
        IncomingSmsPayload.fromSmsMessage(msg),
      );
    } catch (e) {
      debugPrint('Error handling new message: $e');
    }
  }

  @override
  Future<void> close() async {
    _deviceHeartbeatService.stop();
    await flutterLocalNotificationsPlugin.cancel(0);
    return super.close();
  }
}
