import 'package:nimbus/core/utils/json_reader.dart';
import 'package:nimbus/features/weather/data/mappers/wmo_code_mapper.dart';
import 'package:nimbus/features/weather/domain/entities/forecast.dart';

/// Open-Meteo sends forecasts as columns (`time: [...]`,
/// `temperature_2m: [...]`). These models turn one row of those columns into
/// an object, and back again for the cache.

class HourlyModel {
  const HourlyModel({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.isDay,
    this.precipitationProbability,
  });

  final DateTime time;
  final double temperature;
  final int weatherCode;
  final bool isDay;
  final int? precipitationProbability;

  /// Throws [FormatException] if a column is missing, a required value is
  /// null, or the columns have different lengths.
  static List<HourlyModel> listFromJson(Map<String, dynamic> columns) {
    final times = columns.listOf<String>('time');
    final temperatures = _column<num>(columns, 'temperature_2m', times.length);
    final codes = _column<num>(columns, 'weather_code', times.length);
    final isDay = _column<num>(columns, 'is_day', times.length);
    final chances = _column<num>(
      columns,
      'precipitation_probability',
      times.length,
    );

    return [
      for (var i = 0; i < times.length; i++)
        HourlyModel(
          time: DateTime.parse(_required(times[i], 'time', i)),
          temperature: _required(
            temperatures[i],
            'temperature_2m',
            i,
          ).toDouble(),
          weatherCode: _required(codes[i], 'weather_code', i).toInt(),
          isDay: _required(isDay[i], 'is_day', i) == 1,
          precipitationProbability: chances[i]?.toInt(),
        ),
    ];
  }

  static Map<String, dynamic> listToJson(List<HourlyModel> hours) => {
    'time': [for (final h in hours) h.time.toIso8601String()],
    'temperature_2m': [for (final h in hours) h.temperature],
    'weather_code': [for (final h in hours) h.weatherCode],
    'precipitation_probability': [
      for (final h in hours) h.precipitationProbability,
    ],
    'is_day': [for (final h in hours) h.isDay ? 1 : 0],
  };

  HourlyForecast toEntity() => HourlyForecast(
    time: time,
    temperature: temperature,
    condition: WmoCodeMapper.toCondition(weatherCode),
    isDay: isDay,
    precipitationChance: precipitationProbability,
  );
}

class DailyModel {
  const DailyModel({
    required this.date,
    required this.weatherCode,
    required this.maxTemperature,
    required this.minTemperature,
    this.precipitationProbability,
    this.uvIndexMax,
    this.sunrise,
    this.sunset,
  });

  final DateTime date;
  final int weatherCode;
  final double maxTemperature;
  final double minTemperature;
  final int? precipitationProbability;

  // Not reported everywhere (e.g. polar regions), hence nullable.
  final double? uvIndexMax;
  final DateTime? sunrise;
  final DateTime? sunset;

  /// Throws [FormatException] like [HourlyModel.listFromJson].
  static List<DailyModel> listFromJson(Map<String, dynamic> columns) {
    final dates = columns.listOf<String>('time');
    final n = dates.length;
    final codes = _column<num>(columns, 'weather_code', n);
    final highs = _column<num>(columns, 'temperature_2m_max', n);
    final lows = _column<num>(columns, 'temperature_2m_min', n);
    final chances = _column<num>(columns, 'precipitation_probability_max', n);
    final uv = _column<num>(columns, 'uv_index_max', n);
    final sunrises = _column<String>(columns, 'sunrise', n);
    final sunsets = _column<String>(columns, 'sunset', n);

    return [
      for (var i = 0; i < n; i++)
        DailyModel(
          date: DateTime.parse(_required(dates[i], 'time', i)),
          weatherCode: _required(codes[i], 'weather_code', i).toInt(),
          maxTemperature: _required(
            highs[i],
            'temperature_2m_max',
            i,
          ).toDouble(),
          minTemperature: _required(
            lows[i],
            'temperature_2m_min',
            i,
          ).toDouble(),
          precipitationProbability: chances[i]?.toInt(),
          uvIndexMax: uv[i]?.toDouble(),
          sunrise: _parseOptionalDate(sunrises[i]),
          sunset: _parseOptionalDate(sunsets[i]),
        ),
    ];
  }

  static Map<String, dynamic> listToJson(List<DailyModel> days) => {
    'time': [for (final d in days) _dateOnly(d.date)],
    'weather_code': [for (final d in days) d.weatherCode],
    'temperature_2m_max': [for (final d in days) d.maxTemperature],
    'temperature_2m_min': [for (final d in days) d.minTemperature],
    'precipitation_probability_max': [
      for (final d in days) d.precipitationProbability,
    ],
    'uv_index_max': [for (final d in days) d.uvIndexMax],
    'sunrise': [for (final d in days) d.sunrise?.toIso8601String()],
    'sunset': [for (final d in days) d.sunset?.toIso8601String()],
  };

  DailyForecast toEntity() => DailyForecast(
    date: date,
    condition: WmoCodeMapper.toCondition(weatherCode),
    high: maxTemperature,
    low: minTemperature,
    precipitationChance: precipitationProbability,
  );

  static String _dateOnly(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

/// Reads a column and checks it lines up with the `time` column.
List<T?> _column<T>(Map<String, dynamic> columns, String key, int length) {
  final values = columns.listOf<T>(key);
  if (values.length != length) {
    throw FormatException(
      'Expected "$key" to have $length entries, got ${values.length}',
    );
  }
  return values;
}

T _required<T>(T? value, String key, int index) {
  if (value == null) throw FormatException('Missing "$key[$index]"');
  return value;
}

DateTime? _parseOptionalDate(String? value) =>
    value == null ? null : DateTime.parse(value);
