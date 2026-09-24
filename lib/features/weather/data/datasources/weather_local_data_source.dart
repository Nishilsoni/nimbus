import 'dart:async';
import 'dart:convert';

import 'package:nimbus/features/weather/data/models/weather_report_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps the last successful report for each place, so every page has
/// something useful to show when the app opens offline.
///
/// A handful of small records, so key-value storage is enough; a database
/// would be overkill.
class WeatherLocalDataSource {
  const WeatherLocalDataSource(this._preferences);

  static const _keyPrefix = 'weather_report:';

  final SharedPreferences _preferences;

  static String keyFor(String placeId) => '$_keyPrefix$placeId';

  Future<void> saveReport(String placeId, WeatherReportModel report) =>
      _preferences.setString(keyFor(placeId), jsonEncode(report.toJson()));

  /// Returns `null` when nothing is saved. A corrupt entry (for example from
  /// an older app version) is deleted rather than crashing the app.
  ///
  /// Synchronous: preferences are loaded into memory at startup.
  WeatherReportModel? readReport(String placeId) {
    final key = keyFor(placeId);
    final raw = _preferences.getString(key);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) throw const FormatException();
      return WeatherReportModel.fromJson(json);
    } on FormatException {
      unawaited(_preferences.remove(key));
      return null;
    }
  }
}
