import 'package:intl/intl.dart';
import 'package:nimbus/core/l10n/l10n.dart';

/// Date and time text in the app's current language.
abstract final class DateFormatter {
  /// "just now", "5 min ago", "3 h ago", or a date for anything older than
  /// a day. [now] is injectable so the output is testable.
  static String relative(
    DateTime time,
    AppLocalizations l10n, {
    DateTime? now,
  }) {
    final elapsed = (now ?? DateTime.now()).difference(time);
    if (elapsed.inMinutes < 1) return l10n.justNow;
    if (elapsed.inHours < 1) return l10n.minutesAgo(elapsed.inMinutes);
    if (elapsed.inDays < 1) return l10n.hoursAgo(elapsed.inHours);
    final locale = l10n.localeName;
    return '${DateFormat('d MMM', locale).format(time)}, '
        '${DateFormat.jm(locale).format(time)}';
  }

  /// A clock time such as "6:28 AM".
  static String time(DateTime time, String locale) =>
      DateFormat.jm(locale).format(time);

  /// An hour such as "9 PM", for the hourly forecast.
  static String hour(DateTime time, String locale) =>
      DateFormat.j(locale).format(time);

  /// A short weekday such as "Tue", for the daily forecast.
  static String weekday(DateTime date, String locale) =>
      DateFormat.E(locale).format(date);
}
