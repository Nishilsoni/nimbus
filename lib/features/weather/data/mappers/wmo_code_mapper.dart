import 'package:nimbus/features/weather/domain/entities/weather_condition.dart';

/// Maps WMO weather interpretation codes (used by Open-Meteo) onto the
/// app's [WeatherCondition]s.
///
/// Reference: https://open-meteo.com/en/docs ("WMO Weather interpretation
/// codes").
abstract final class WmoCodeMapper {
  static WeatherCondition toCondition(int code) => switch (code) {
    0 => WeatherCondition.clear,
    1 || 2 => WeatherCondition.partlyCloudy,
    3 => WeatherCondition.cloudy,
    45 || 48 => WeatherCondition.fog,
    51 || 53 || 55 || 56 || 57 => WeatherCondition.drizzle,
    61 || 63 || 65 || 66 || 67 || 80 || 81 || 82 => WeatherCondition.rain,
    71 || 73 || 75 || 77 || 85 || 86 => WeatherCondition.snow,
    95 || 96 || 99 => WeatherCondition.thunderstorm,
    _ => WeatherCondition.unknown,
  };
}
