import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String text;
  final DateTime date;

  Message({
    required this.text,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'date': Timestamp.fromDate(date.toUtc()),
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['text'],
      date: _readDate(json['date']),
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
