import 'package:cloud_firestore/cloud_firestore.dart';

class Messages {
  final String id;
  final String title;
  final String lastMessage;
  final DateTime lastMessageDate;
  final int unreadMessagesCount;

  Messages({
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
      'last_message_date': lastMessageDate.toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory Messages.fromJson(Map<String, dynamic> json) {
    return Messages(
      id: json['id'],
      title: json['title'],
      lastMessage: json['last_message'],
      lastMessageDate: DateTime.parse(json['last_message_date']),
      unreadMessagesCount: json['unread_messages_count'] ?? 0,
    );
  }

  static Messages updateFireStore(msg) => Messages(
        id: msg.address ?? '',
        title: msg.address ?? '',
        lastMessage: msg.body ?? '',
        lastMessageDate: DateTime.now(),
      );
}
