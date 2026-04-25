import 'package:intl/intl.dart';
import 'package:simply/l10n/app_localizations.dart';

extension DateTimeFormat on DateTime {
  /// Compact relative time used in the messages list ("13 min", "yesterday",
  /// "5 Oct").
  String formatRelativeShort(AppLocalizations l10n) {
    final now = DateTime.now();
    final diff = now.difference(this);
    final locale = l10n.localeName;

    if (diff.inMinutes < 1) return l10n.justNow;
    if (diff.inMinutes < 60) return l10n.minutesShort(diff.inMinutes);
    if (diff.inHours < 24) return l10n.hoursShort(diff.inHours);
    if (diff.inDays == 1) return l10n.yesterdayLowercase;
    if (diff.inDays < 7) return DateFormat('EEE', locale).format(this);
    if (diff.inDays < 365) return DateFormat('d MMM', locale).format(this);
    return DateFormat('d MMM yyyy', locale).format(this);
  }

  /// Full date label for chat dividers ("Today · 14:32", "Yesterday · 09:01").
  String formatChatDivider(AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(year, month, day);
    final time = DateFormat('HH:mm').format(this);
    if (that == today) return l10n.todayAtTime(time);
    if (that == today.subtract(const Duration(days: 1))) {
      return l10n.yesterdayAtTime(time);
    }
    return l10n.dateAtTime(DateFormat('d MMM', l10n.localeName).format(this), time);
  }

  String formatTime() => DateFormat('HH:mm').format(this);

  // Legacy formatters kept so the rest of the app keeps working until those
  // call sites get rewritten.
  String formatDateTime(AppLocalizations l10n) => formatRelativeShort(l10n);
  String formatFullDateTime(AppLocalizations l10n) => formatChatDivider(l10n);
}
