import 'package:intl/intl.dart';

import 'package:nimbus/core/constants/app_strings.dart';

abstract final class DateFormatter {
  static final _time = DateFormat.jm();
  static final _dayAndTime = DateFormat('d MMM, h:mm a');

  /// "just now", "5 min ago", "3 h ago", or a date for anything older than a
  /// day. [now] is injectable so the output is testable.
  static String relative(DateTime time, {DateTime? now}) {
    final elapsed = (now ?? DateTime.now()).difference(time);
    if (elapsed.inMinutes < 1) return AppStrings.justNow;
    if (elapsed.inHours < 1) return AppStrings.minutesAgo(elapsed.inMinutes);
    if (elapsed.inDays < 1) return AppStrings.hoursAgo(elapsed.inHours);
    return _dayAndTime.format(time);
  }

  /// A clock time such as "6:28 AM".
  static String time(DateTime time) => _time.format(time);
}
