import 'package:flutter/material.dart';
import 'package:nimbus/core/constants/app_strings.dart';
import 'package:nimbus/features/weather/domain/entities/weather_condition.dart';

/// Labels and sky palettes for each [WeatherCondition].
extension ConditionVisuals on WeatherCondition {
  String get label => switch (this) {
    WeatherCondition.clear => AppStrings.conditionClear,
    WeatherCondition.partlyCloudy => AppStrings.conditionPartlyCloudy,
    WeatherCondition.cloudy => AppStrings.conditionCloudy,
    WeatherCondition.fog => AppStrings.conditionFog,
    WeatherCondition.drizzle => AppStrings.conditionDrizzle,
    WeatherCondition.rain => AppStrings.conditionRain,
    WeatherCondition.snow => AppStrings.conditionSnow,
    WeatherCondition.thunderstorm => AppStrings.conditionThunderstorm,
    WeatherCondition.unknown => AppStrings.conditionUnknown,
  };

  /// Top-to-bottom background gradient for this sky.
  List<Color> skyGradient({required bool isDay}) {
    final palette = switch (this) {
      WeatherCondition.clear ||
      WeatherCondition.partlyCloudy => _SkyPalette.clear,
      WeatherCondition.cloudy || WeatherCondition.unknown => _SkyPalette.cloudy,
      WeatherCondition.fog => _SkyPalette.fog,
      WeatherCondition.drizzle || WeatherCondition.rain => _SkyPalette.rain,
      WeatherCondition.snow => _SkyPalette.snow,
      WeatherCondition.thunderstorm => _SkyPalette.storm,
    };
    return isDay ? palette.day : palette.night;
  }
}

enum _SkyPalette {
  clear(
    day: [Color(0xFF1F6FEB), Color(0xFF4A9BFF), Color(0xFF86C3FF)],
    night: [Color(0xFF0A1330), Color(0xFF1A2A5C), Color(0xFF2E3F7A)],
  ),
  cloudy(
    day: [Color(0xFF46648C), Color(0xFF6F89AD), Color(0xFF97ACC7)],
    night: [Color(0xFF161E2E), Color(0xFF283349), Color(0xFF3A4760)],
  ),
  fog(
    day: [Color(0xFF5D6E80), Color(0xFF7D8D9D), Color(0xFF9DAAB7)],
    night: [Color(0xFF1F262E), Color(0xFF323B45), Color(0xFF454F5A)],
  ),
  rain(
    day: [Color(0xFF2F435B), Color(0xFF4A627F), Color(0xFF6A819E)],
    night: [Color(0xFF101826), Color(0xFF1D293B), Color(0xFF2B3950)],
  ),
  snow(
    day: [Color(0xFF4F7299), Color(0xFF7090B4), Color(0xFF95AFCC)],
    night: [Color(0xFF1A273C), Color(0xFF2C3F5C), Color(0xFF41577A)],
  ),
  storm(
    day: [Color(0xFF231F35), Color(0xFF3A3456), Color(0xFF524A70)],
    night: [Color(0xFF120F1E), Color(0xFF231E36), Color(0xFF362F50)],
  );

  const _SkyPalette({required this.day, required this.night});

  final List<Color> day;
  final List<Color> night;
}
