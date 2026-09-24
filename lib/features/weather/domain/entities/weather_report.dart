import 'package:equatable/equatable.dart';

import 'package:nimbus/features/weather/domain/entities/city.dart';
import 'package:nimbus/features/weather/domain/entities/weather.dart';

/// Weather for a city, stamped with when we fetched it.
///
/// [fetchedAt] is device time and drives the "Updated 5 min ago" label.
class WeatherReport extends Equatable {
  const WeatherReport({
    required this.city,
    required this.weather,
    required this.fetchedAt,
  });

  final City city;
  final Weather weather;
  final DateTime fetchedAt;

  @override
  List<Object?> get props => [city, weather, fetchedAt];
}
