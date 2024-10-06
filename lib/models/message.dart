class MessageThread {
  final String text;
  final DateTime date;
  bool isRead;

  MessageThread({
    required this.text,
    required this.date,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'date': date.toIso8601String(),
      'is_read': isRead,
    };
  }

  factory MessageThread.fromJson(Map<String, dynamic> json) {
    return MessageThread(
      text: json['text'],
      date: DateTime.parse(json['date']),
      isRead: json['isRead'] ?? false,
    );
  }

  static MessageThread updateFireStore(msg) => MessageThread(
        text: msg.body ?? '',
        date: DateTime.now(),
      );
}
