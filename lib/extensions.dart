import 'package:intl/intl.dart';

extension DateTimeFormat on DateTime {
  /// Compact relative time used in the messages list ("13 мин", "вчера",
  /// "5 окт").
  String formatRelativeShort() {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inMinutes < 1) return 'сейчас';
    if (diff.inMinutes < 60) return '${diff.inMinutes} мин';
    if (diff.inHours < 24) return '${diff.inHours} ч';
    if (diff.inDays == 1) return 'вчера';
    if (diff.inDays < 7) return DateFormat('EEE', 'ru').format(this);
    if (diff.inDays < 365) return DateFormat('d MMM', 'ru').format(this);
    return DateFormat('d MMM yyyy', 'ru').format(this);
  }

  /// Full date label for chat dividers ("Сегодня · 14:32", "Вчера · 09:01").
  String formatChatDivider() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(year, month, day);
    final time = DateFormat('HH:mm').format(this);
    if (that == today) return 'Сегодня · $time';
    if (that == today.subtract(const Duration(days: 1))) {
      return 'Вчера · $time';
    }
    return '${DateFormat('d MMM', 'ru').format(this)} · $time';
  }

  String formatTime() => DateFormat('HH:mm').format(this);

  // Legacy formatters kept so the rest of the app keeps working until those
  // call sites get rewritten.
  String formatDateTime() => formatRelativeShort();
  String formatFullDateTime() => formatChatDivider();
}
