import 'package:nimbus/core/utils/json_reader.dart';
import 'package:nimbus/features/weather/data/mappers/wmo_code_mapper.dart';
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
    required this.maxTemperature,
    required this.minTemperature,
    required this.relativeHumidity,
    required this.windSpeed,
    required this.precipitation,
    required this.surfacePressure,
    required this.time,
    this.uvIndexMax,
    this.sunrise,
    this.sunset,
  });

  /// Throws [FormatException] if a required field is missing or mistyped.
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final current = json.requireMap('current');
    final daily = json.requireMap('daily');
    final sunrise = daily.firstOf<String>('sunrise');
    final sunset = daily.firstOf<String>('sunset');

    return WeatherModel(
      weatherCode: current.requireInt('weather_code'),
      isDay: current.requireInt('is_day') == 1,
      temperature: current.requireDouble('temperature_2m'),
      apparentTemperature: current.requireDouble('apparent_temperature'),
      relativeHumidity: current.requireInt('relative_humidity_2m'),
      windSpeed: current.requireDouble('wind_speed_10m'),
      precipitation: current.requireDouble('precipitation'),
      surfacePressure: current.requireDouble('surface_pressure'),
      time: current.requireDateTime('time'),
      maxTemperature: _requireFirst(daily, 'temperature_2m_max'),
      minTemperature: _requireFirst(daily, 'temperature_2m_min'),
      uvIndexMax: daily.firstOf<num>('uv_index_max')?.toDouble(),
      sunrise: sunrise == null ? null : DateTime.parse(sunrise),
      sunset: sunset == null ? null : DateTime.parse(sunset),
    );
  }

  final int weatherCode;
  final bool isDay;
  final double temperature;
  final double apparentTemperature;
  final double maxTemperature;
  final double minTemperature;
  final int relativeHumidity;
  final double windSpeed;
  final double precipitation;
  final double surfacePressure;
  final DateTime time;
  final double? uvIndexMax;
  final DateTime? sunrise;
  final DateTime? sunset;

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
    'daily': {
      'temperature_2m_max': [maxTemperature],
      'temperature_2m_min': [minTemperature],
      'uv_index_max': [uvIndexMax],
      'sunrise': [sunrise?.toIso8601String()],
      'sunset': [sunset?.toIso8601String()],
    },
  };

  Weather toEntity() => Weather(
    condition: WmoCodeMapper.toCondition(weatherCode),
    isDay: isDay,
    temperature: temperature,
    feelsLike: apparentTemperature,
    highTemperature: maxTemperature,
    lowTemperature: minTemperature,
    humidity: relativeHumidity,
    windSpeed: windSpeed,
    precipitation: precipitation,
    pressure: surfacePressure,
    observedAt: time,
    uvIndex: uvIndexMax,
    sunrise: sunrise,
    sunset: sunset,
  );

  static double _requireFirst(Map<String, dynamic> daily, String key) {
    final value = daily.firstOf<num>(key);
    if (value == null) throw FormatException('Missing "$key[0]"');
    return value.toDouble();
  }
}
