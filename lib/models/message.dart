class MessageDetails {
  final String text;
  final DateTime date;
  bool isRead;

  MessageDetails({
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

  factory MessageDetails.fromJson(Map<String, dynamic> json) {
    return MessageDetails(
      text: json['text'],
      date: DateTime.parse(json['date']),
      isRead: json['isRead'] ?? false,
    );
  }

  static MessageDetails updateFireStore(msg) => MessageDetails(
        text: msg.body ?? '',
        date: DateTime.now(),
      );
}
