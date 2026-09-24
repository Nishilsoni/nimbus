import 'dart:convert';

import 'package:nimbus/features/weather/data/models/weather_report_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the last successful report so the app has something useful to
/// show when it opens offline.
///
/// Only one small record is stored, so key-value storage is enough; a
/// database would be overkill.
class WeatherLocalDataSource {
  const WeatherLocalDataSource(this._preferences);

  static const lastReportKey = 'last_weather_report';

  final SharedPreferences _preferences;

  Future<void> saveReport(WeatherReportModel report) =>
      _preferences.setString(lastReportKey, jsonEncode(report.toJson()));

  /// Returns `null` when nothing is saved. A corrupt entry (for example from
  /// an older app version) is deleted rather than crashing the app.
  Future<WeatherReportModel?> readLastReport() async {
    final raw = _preferences.getString(lastReportKey);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) throw const FormatException();
      return WeatherReportModel.fromJson(json);
    } on FormatException {
      await _preferences.remove(lastReportKey);
      return null;
    }
  }
}
