import 'package:equatable/equatable.dart';

import 'package:nimbus/features/weather/domain/entities/weather_condition.dart';

/// Current conditions plus today's highs and lows.
///
/// Units are metric: °C, km/h, mm and hPa. Times are the location's local
/// wall-clock time.
class Weather extends Equatable {
  const Weather({
    required this.condition,
    required this.isDay,
    required this.temperature,
    required this.feelsLike,
    required this.highTemperature,
    required this.lowTemperature,
    required this.humidity,
    required this.windSpeed,
    required this.precipitation,
    required this.pressure,
    required this.observedAt,
    this.uvIndex,
    this.sunrise,
    this.sunset,
  });

  final WeatherCondition condition;
  final bool isDay;
  final double temperature;
  final double feelsLike;
  final double highTemperature;
  final double lowTemperature;
  final int humidity;
  final double windSpeed;
  final double precipitation;
  final double pressure;
  final DateTime observedAt;

  // Not reported everywhere (e.g. polar regions), hence nullable.
  final double? uvIndex;
  final DateTime? sunrise;
  final DateTime? sunset;

  @override
  List<Object?> get props => [
    condition,
    isDay,
    temperature,
    feelsLike,
    highTemperature,
    lowTemperature,
    humidity,
    windSpeed,
    precipitation,
    pressure,
    observedAt,
    uvIndex,
    sunrise,
    sunset,
  ];
}
