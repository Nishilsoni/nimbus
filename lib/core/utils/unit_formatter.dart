import 'package:nimbus/core/constants/app_strings.dart';

/// Formats measurements for display. Metric units throughout.
abstract final class UnitFormatter {
  static String temperature(double celsius) => '${celsius.round()}°';

  static String percent(int value) => '$value%';

  static String windSpeed(double kmh) => '${kmh.round()} km/h';

  static String precipitation(double mm) => '${_oneDecimal(mm)} mm';

  static String pressure(double hpa) => '${hpa.round()} hPa';

  static String uvIndex(double? index) =>
      index == null ? AppStrings.notAvailable : _oneDecimal(index);

  /// WHO UV index categories.
  static String? uvLevel(double? index) => switch (index) {
    null => null,
    < 3 => AppStrings.uvLow,
    < 6 => AppStrings.uvModerate,
    < 8 => AppStrings.uvHigh,
    < 11 => AppStrings.uvVeryHigh,
    _ => AppStrings.uvExtreme,
  };

  /// "3" instead of "3.0", but "2.4" stays "2.4".
  static String _oneDecimal(double value) {
    final rounded = (value * 10).round() / 10;
    return rounded == rounded.roundToDouble()
        ? rounded.toInt().toString()
        : rounded.toStringAsFixed(1);
  }
}
