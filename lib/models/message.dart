import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String text;
  final DateTime date;
  final String? sourceDeviceId;
  final String? sourceDeviceName;
  final String? sourcePlatform;
  final int? sourceSubscriptionId;
  final int? sourceSimSlot;
  final String? sourceCarrier;

  Message({
    required this.text,
    required this.date,
    this.sourceDeviceId,
    this.sourceDeviceName,
    this.sourcePlatform,
    this.sourceSubscriptionId,
    this.sourceSimSlot,
    this.sourceCarrier,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'date': Timestamp.fromDate(date.toUtc()),
      if (sourceDeviceId != null) 'source_device_id': sourceDeviceId,
      if (sourceDeviceName != null) 'source_device_name': sourceDeviceName,
      if (sourcePlatform != null) 'source_platform': sourcePlatform,
      if (sourceSubscriptionId != null)
        'source_subscription_id': sourceSubscriptionId,
      if (sourceSimSlot != null) 'source_sim_slot': sourceSimSlot,
      if (sourceCarrier != null) 'source_carrier': sourceCarrier,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['text'],
      date: _readDate(json['date']),
      sourceDeviceId: json['source_device_id'] as String?,
      sourceDeviceName: json['source_device_name'] as String?,
      sourcePlatform: json['source_platform'] as String?,
      sourceSubscriptionId: (json['source_subscription_id'] as num?)?.toInt(),
      sourceSimSlot: (json['source_sim_slot'] as num?)?.toInt(),
      sourceCarrier: json['source_carrier'] as String?,
    );
  }

  static Message fromSms(dynamic sms) => Message(
        text: sms.body ?? '',
        date: DateTime.now(),
      );

  static DateTime _readDate(dynamic rawValue) {
    if (rawValue is Timestamp) {
      return rawValue.toDate();
    }
    if (rawValue is DateTime) {
      return rawValue;
    }
    if (rawValue is String) {
      return DateTime.tryParse(rawValue) ??
          DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
