import 'package:intl/intl.dart';

extension DateTimeFormat on DateTime {
  String formatDateTime() {
    final now = DateTime.now();

    bool isToday = year == now.year && month == now.month && day == now.day;

    final difference = now.difference(this);

    if (isToday && difference.inMinutes < 60) {
      if (difference.inMinutes < 1) {
        return 'Только что';
      } else {
        return '${difference.inMinutes} минут назад';
      }
    } else if (isToday) {
      return DateFormat('HH:mm').format(this);
    } else if (difference.inDays < 7) {
      return DateFormat('EEE HH:mm').format(this);
    } else {
      return DateFormat('EEE HH:mm').format(this);
    }
  }
}
