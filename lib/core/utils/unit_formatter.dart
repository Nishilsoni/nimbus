import 'package:nimbus/core/l10n/l10n.dart';
import 'package:nimbus/core/utils/temperature_unit.dart';

/// Formats measurements for display. Values arrive in metric units;
/// temperatures are converted to the user's chosen unit here.
abstract final class UnitFormatter {
  static String temperature(double celsius, TemperatureUnit unit) =>
      '${unit.fromCelsius(celsius).round()}°';

  static String percent(int value) => '$value%';

  static String windSpeed(double kmh) => '${kmh.round()} km/h';

  static String precipitation(double mm) => '${_oneDecimal(mm)} mm';

  static String pressure(double hpa) => '${hpa.round()} hPa';

  static String uvIndex(double? index, AppLocalizations l10n) =>
      index == null ? l10n.notAvailable : _oneDecimal(index);

  /// WHO UV index categories.
  static String? uvLevel(double? index, AppLocalizations l10n) =>
      switch (index) {
        null => null,
        < 3 => l10n.uvLow,
        < 6 => l10n.uvModerate,
        < 8 => l10n.uvHigh,
        < 11 => l10n.uvVeryHigh,
        _ => l10n.uvExtreme,
      };

  /// "3" instead of "3.0", but "2.4" stays "2.4".
  static String _oneDecimal(double value) {
    final rounded = (value * 10).round() / 10;
    return rounded == rounded.roundToDouble()
        ? rounded.toInt().toString()
        : rounded.toStringAsFixed(1);
  }
}
