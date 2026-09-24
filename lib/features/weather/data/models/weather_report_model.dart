import 'package:nimbus/core/utils/json_reader.dart';
import 'package:nimbus/features/weather/data/models/city_model.dart';
import 'package:nimbus/features/weather/data/models/weather_model.dart';
import 'package:nimbus/features/weather/domain/entities/weather_report.dart';

/// The envelope saved to local storage: which city, what the API said, and
/// when we asked.
class WeatherReportModel {
  const WeatherReportModel({
    required this.city,
    required this.weather,
    required this.fetchedAt,
  });

  factory WeatherReportModel.fromJson(Map<String, dynamic> json) =>
      WeatherReportModel(
        city: CityModel.fromJson(json.requireMap('city')),
        weather: WeatherModel.fromJson(json.requireMap('weather')),
        fetchedAt: json.requireDateTime('fetched_at'),
      );

  final CityModel city;
  final WeatherModel weather;
  final DateTime fetchedAt;

  Map<String, dynamic> toJson() => {
    'city': city.toJson(),
    'weather': weather.toJson(),
    'fetched_at': fetchedAt.toIso8601String(),
  };

  WeatherReport toEntity() => WeatherReport(
    city: city.toEntity(),
    weather: weather.toEntity(),
    fetchedAt: fetchedAt,
  );
}
