class MessageDetails {
  final String text;
  final DateTime date;

  MessageDetails({
    required this.text,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'date': date.toIso8601String(),
    };
  }

  factory MessageDetails.fromJson(Map<String, dynamic> json) {
    return MessageDetails(
      text: json['text'],
      date: DateTime.parse(json['date']),
    );
  }

  static MessageDetails updateFireStore(msg) => MessageDetails(
        text: msg.body ?? '',
        date: DateTime.now(),
      );
}
