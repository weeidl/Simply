import 'dart:convert';

import 'package:another_telephony/telephony.dart';
import 'package:simply/models/conversation.dart';
import 'package:simply/models/message.dart';

class IncomingSmsPayload {
  final String address;
  final String body;
  final DateTime receivedAt;

  const IncomingSmsPayload({
    required this.address,
    required this.body,
    required this.receivedAt,
  });

  factory IncomingSmsPayload.fromSmsMessage(SmsMessage message) {
    final timestamp = message.date != null
        ? DateTime.fromMillisecondsSinceEpoch(message.date!)
        : DateTime.now();

    return IncomingSmsPayload(
      address: message.address ?? '',
      body: message.body ?? '',
      receivedAt: timestamp,
    );
  }

  factory IncomingSmsPayload.fromJson(Map<String, dynamic> json) {
    return IncomingSmsPayload(
      address: json['address']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      receivedAt: DateTime.tryParse(json['received_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
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
    );
  }

  Message toMessage() {
    return Message(
      text: body,
      date: receivedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'body': body,
      'received_at': receivedAt.toUtc().toIso8601String(),
    };
  }
}
