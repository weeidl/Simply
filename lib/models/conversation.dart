import 'package:cloud_firestore/cloud_firestore.dart';

/// One thread of messages from a single sender, surfaced in the messages list.
///
/// [sourcePlatform] and [category] are optional — when present the UI shows
/// the platform badge on the avatar and a small category tag; when absent,
/// the row simply omits them.
class Conversation {
  final String id;
  final String title;
  final String lastMessage;
  final DateTime lastMessageDate;
  final int unreadMessagesCount;
  final String? sourcePlatform;
  final String? sourceDeviceId;
  final String? sourceDeviceName;
  final int? sourceSubscriptionId;
  final int? sourceSimSlot;
  final String? sourceCarrier;
  final String? category;

  Conversation({
    required this.id,
    required this.title,
    required this.lastMessage,
    this.unreadMessagesCount = 0,
    required this.lastMessageDate,
    this.sourcePlatform,
    this.sourceDeviceId,
    this.sourceDeviceName,
    this.sourceSubscriptionId,
    this.sourceSimSlot,
    this.sourceCarrier,
    this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'last_message': lastMessage,
      'last_message_date': Timestamp.fromDate(lastMessageDate.toUtc()),
      'createdAt': FieldValue.serverTimestamp(),
      if (sourcePlatform != null) 'source_platform': sourcePlatform,
      if (sourceDeviceId != null) 'source_device_id': sourceDeviceId,
      if (sourceDeviceName != null) 'source_device_name': sourceDeviceName,
      if (sourceSubscriptionId != null)
        'source_subscription_id': sourceSubscriptionId,
      if (sourceSimSlot != null) 'source_sim_slot': sourceSimSlot,
      if (sourceCarrier != null) 'source_carrier': sourceCarrier,
      if (category != null) 'category': category,
    };
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      lastMessage: json['last_message'] ?? '',
      lastMessageDate: _readDate(json['last_message_date']),
      unreadMessagesCount:
          (json['unread_messages_count'] as num?)?.toInt() ?? 0,
      sourcePlatform: json['source_platform'] as String?,
      sourceDeviceId: json['source_device_id'] as String?,
      sourceDeviceName: json['source_device_name'] as String?,
      sourceSubscriptionId: (json['source_subscription_id'] as num?)?.toInt(),
      sourceSimSlot: (json['source_sim_slot'] as num?)?.toInt(),
      sourceCarrier: json['source_carrier'] as String?,
      category: json['category'] as String?,
    );
  }

  static Conversation fromSms(dynamic sms) => Conversation(
        id: sms.address ?? '',
        title: sms.address ?? '',
        lastMessage: sms.body ?? '',
        lastMessageDate: DateTime.now(),
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
