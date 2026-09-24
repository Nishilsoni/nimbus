import 'package:equatable/equatable.dart';
import 'package:nimbus/features/weather/domain/entities/weather_condition.dart';

/// One hour of the forecast. Times are the location's local time.
class HourlyForecast extends Equatable {
  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.condition,
    required this.isDay,
    this.precipitationChance,
  });

  final DateTime time;
  final double temperature;
  final WeatherCondition condition;
  final bool isDay;

  /// 0–100, when the API reports it.
  final int? precipitationChance;

  @override
  List<Object?> get props => [
    time,
    temperature,
    condition,
    isDay,
    precipitationChance,
  ];
}

/// One day of the forecast.
class DailyForecast extends Equatable {
  const DailyForecast({
    required this.date,
    required this.condition,
    required this.high,
    required this.low,
    this.precipitationChance,
  });

  final DateTime date;
  final WeatherCondition condition;
  final double high;
  final double low;

  /// 0–100, when the API reports it.
  final int? precipitationChance;

  @override
  List<Object?> get props => [date, condition, high, low, precipitationChance];
}
