import 'dart:convert';

import 'package:another_telephony/telephony.dart';
import 'package:simply/models/conversation.dart';
import 'package:simply/models/message.dart';

class IncomingSmsPayload {
  final String address;
  final String body;
  final DateTime receivedAt;
  final String? sourceDeviceId;
  final String? sourceDeviceName;
  final String? sourcePlatform;
  final int? sourceSubscriptionId;
  final int? sourceSimSlot;
  final String? sourceCarrier;

  const IncomingSmsPayload({
    required this.address,
    required this.body,
    required this.receivedAt,
    this.sourceDeviceId,
    this.sourceDeviceName,
    this.sourcePlatform,
    this.sourceSubscriptionId,
    this.sourceSimSlot,
    this.sourceCarrier,
  });

  factory IncomingSmsPayload.fromSmsMessage(SmsMessage message) {
    final timestamp = message.date != null
        ? DateTime.fromMillisecondsSinceEpoch(message.date!)
        : DateTime.now();

    return IncomingSmsPayload(
      address: message.address ?? '',
      body: message.body ?? '',
      receivedAt: timestamp,
      sourceSubscriptionId: message.subscriptionId,
    );
  }

  factory IncomingSmsPayload.fromJson(Map<String, dynamic> json) {
    return IncomingSmsPayload(
      address: json['address']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      receivedAt: DateTime.tryParse(json['received_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      sourceDeviceId: json['source_device_id']?.toString(),
      sourceDeviceName: json['source_device_name']?.toString(),
      sourcePlatform: json['source_platform']?.toString(),
      sourceSubscriptionId: (json['source_subscription_id'] as num?)?.toInt(),
      sourceSimSlot: (json['source_sim_slot'] as num?)?.toInt(),
      sourceCarrier: json['source_carrier']?.toString(),
    );
  }

  IncomingSmsPayload copyWith({
    String? address,
    String? body,
    DateTime? receivedAt,
    String? sourceDeviceId,
    String? sourceDeviceName,
    String? sourcePlatform,
    int? sourceSubscriptionId,
    int? sourceSimSlot,
    String? sourceCarrier,
  }) {
    return IncomingSmsPayload(
      address: address ?? this.address,
      body: body ?? this.body,
      receivedAt: receivedAt ?? this.receivedAt,
      sourceDeviceId: sourceDeviceId ?? this.sourceDeviceId,
      sourceDeviceName: sourceDeviceName ?? this.sourceDeviceName,
      sourcePlatform: sourcePlatform ?? this.sourcePlatform,
      sourceSubscriptionId: sourceSubscriptionId ?? this.sourceSubscriptionId,
      sourceSimSlot: sourceSimSlot ?? this.sourceSimSlot,
      sourceCarrier: sourceCarrier ?? this.sourceCarrier,
    );
  }

  String get dedupeKey {
    final raw = '$address|${receivedAt.toUtc().toIso8601String()}|$body';
    return base64Url.encode(utf8.encode(raw));
  }

  Conversation toConversation() {
    return Conversation(
      id: address,
      title: address,
      lastMessage: body,
      lastMessageDate: receivedAt,
      sourcePlatform: sourcePlatform,
      sourceDeviceId: sourceDeviceId,
      sourceDeviceName: sourceDeviceName,
      sourceSubscriptionId: sourceSubscriptionId,
      sourceSimSlot: sourceSimSlot,
      sourceCarrier: sourceCarrier,
    );
  }

  Message toMessage() {
    return Message(
      text: body,
      date: receivedAt,
      sourceDeviceId: sourceDeviceId,
      sourceDeviceName: sourceDeviceName,
      sourcePlatform: sourcePlatform,
      sourceSubscriptionId: sourceSubscriptionId,
      sourceSimSlot: sourceSimSlot,
      sourceCarrier: sourceCarrier,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'body': body,
      'received_at': receivedAt.toUtc().toIso8601String(),
      'source_device_id': sourceDeviceId,
      'source_device_name': sourceDeviceName,
      'source_platform': sourcePlatform,
      'source_subscription_id': sourceSubscriptionId,
      'source_sim_slot': sourceSimSlot,
      'source_carrier': sourceCarrier,
    };
  }
}
