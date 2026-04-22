import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  final String id;
  final String title;
  final String lastMessage;
  final DateTime lastMessageDate;
  final int unreadMessagesCount;

  Conversation({
    required this.id,
    required this.title,
    required this.lastMessage,
    this.unreadMessagesCount = 0,
    required this.lastMessageDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'last_message': lastMessage,
      'last_message_date': Timestamp.fromDate(lastMessageDate.toUtc()),
      'createdAt': FieldValue.serverTimestamp(),
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
