import 'package:nimbus/core/constants/api_constants.dart';
import 'package:nimbus/core/utils/json_reader.dart';
import 'package:nimbus/features/weather/data/mappers/wmo_code_mapper.dart';
import 'package:nimbus/features/weather/data/models/forecast_models.dart';
import 'package:nimbus/features/weather/domain/entities/weather.dart';

/// The Open-Meteo forecast response, reduced to the fields we request.
///
/// [toJson] writes the same shape [WeatherModel.fromJson] reads, so the cache
/// stores exactly what the API returned and one parser handles both.
class WeatherModel {
  const WeatherModel({
    required this.weatherCode,
    required this.isDay,
    required this.temperature,
    required this.apparentTemperature,
    required this.relativeHumidity,
    required this.windSpeed,
    required this.precipitation,
    required this.surfacePressure,
    required this.time,
    required this.hourly,
    required this.daily,
  });

  /// Throws [FormatException] if a required field is missing or mistyped.
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final current = json.requireMap('current');
    final time = current.requireDateTime('time');
    final daily = DailyModel.listFromJson(json.requireMap('daily'));
    if (daily.isEmpty) throw const FormatException('Missing daily forecast');

    // The first hourly slot can be the hour that has already started;
    // keep the forecast strictly from the current hour onwards.
    final currentHour = DateTime(time.year, time.month, time.day, time.hour);
    final hourly = HourlyModel.listFromJson(json.requireMap('hourly'))
        .where((hour) => !hour.time.isBefore(currentHour))
        .take(ApiConstants.hoursShown)
        .toList(growable: false);

    return WeatherModel(
      weatherCode: current.requireInt('weather_code'),
      isDay: current.requireInt('is_day') == 1,
      temperature: current.requireDouble('temperature_2m'),
      apparentTemperature: current.requireDouble('apparent_temperature'),
      relativeHumidity: current.requireInt('relative_humidity_2m'),
      windSpeed: current.requireDouble('wind_speed_10m'),
      precipitation: current.requireDouble('precipitation'),
      surfacePressure: current.requireDouble('surface_pressure'),
      time: time,
      hourly: hourly,
      daily: daily,
    );
  }

  final int weatherCode;
  final bool isDay;
  final double temperature;
  final double apparentTemperature;
  final int relativeHumidity;
  final double windSpeed;
  final double precipitation;
  final double surfacePressure;
  final DateTime time;
  final List<HourlyModel> hourly;

  /// Seven days; the first is today and provides today's highs and lows.
  final List<DailyModel> daily;

  Map<String, dynamic> toJson() => {
    'current': {
      'time': time.toIso8601String(),
      'temperature_2m': temperature,
      'apparent_temperature': apparentTemperature,
      'relative_humidity_2m': relativeHumidity,
      'weather_code': weatherCode,
      'wind_speed_10m': windSpeed,
      'precipitation': precipitation,
      'surface_pressure': surfacePressure,
      'is_day': isDay ? 1 : 0,
    },
    'hourly': HourlyModel.listToJson(hourly),
    'daily': DailyModel.listToJson(daily),
  };

  Weather toEntity() {
    final today = daily.first;
    return Weather(
      condition: WmoCodeMapper.toCondition(weatherCode),
      isDay: isDay,
      temperature: temperature,
      feelsLike: apparentTemperature,
      highTemperature: today.maxTemperature,
      lowTemperature: today.minTemperature,
      humidity: relativeHumidity,
      windSpeed: windSpeed,
      precipitation: precipitation,
      pressure: surfacePressure,
      observedAt: time,
      uvIndex: today.uvIndexMax,
      sunrise: today.sunrise,
      sunset: today.sunset,
      hourly: [for (final hour in hourly) hour.toEntity()],
      daily: [for (final day in daily) day.toEntity()],
    );
  }
}
