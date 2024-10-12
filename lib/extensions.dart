import 'package:intl/intl.dart';

extension DateTimeFormat on DateTime {
  String formatDateTime() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${DateFormat('HH:mm').format(this)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 365) {
      return DateFormat('MMM d').format(this);
    } else {
      return DateFormat('MMM d, yyyy').format(this);
    }
  }

  String formatFullDateTime() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${DateFormat('HH:mm').format(this)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago, ${DateFormat('EEEE, HH:mm').format(this)}';
    } else if (difference.inDays < 365) {
      return DateFormat('MMM d, HH:mm').format(this);
    } else {
      return DateFormat('MMM d, yyyy at HH:mm').format(this);
    }
  }
}
