import 'package:another_telephony/telephony.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:simply/bloc/notification/incoming_sms_sync_service.dart';
import 'package:simply/models/incoming_sms_payload.dart';

@pragma('vm:entry-point')
Future<void> onBackgroundMessage(SmsMessage msg) async {
  await Firebase.initializeApp();
  final syncService = IncomingSmsSyncService();

  try {
    await syncService.handleIncomingSms(
      IncomingSmsPayload.fromSmsMessage(msg),
    );
  } catch (e, stack) {
    debugPrint('[BackgroundSms] failed to process incoming SMS: $e\n$stack');
  }
}
