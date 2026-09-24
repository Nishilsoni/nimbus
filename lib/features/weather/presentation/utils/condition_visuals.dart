import 'package:flutter/material.dart';
import 'package:nimbus/core/l10n/l10n.dart';
import 'package:nimbus/core/theme/app_colors.dart';
import 'package:nimbus/features/weather/domain/entities/weather_condition.dart';

/// Labels and accent colours for each [WeatherCondition].
extension ConditionVisuals on WeatherCondition {
  String label(AppLocalizations l10n) => switch (this) {
    WeatherCondition.clear => l10n.conditionClear,
    WeatherCondition.partlyCloudy => l10n.conditionPartlyCloudy,
    WeatherCondition.cloudy => l10n.conditionCloudy,
    WeatherCondition.fog => l10n.conditionFog,
    WeatherCondition.drizzle => l10n.conditionDrizzle,
    WeatherCondition.rain => l10n.conditionRain,
    WeatherCondition.snow => l10n.conditionSnow,
    WeatherCondition.thunderstorm => l10n.conditionThunderstorm,
    WeatherCondition.unknown => l10n.conditionUnknown,
  };

  /// The accent that sets the screen's mood: warm for sun, blue for rain,
  /// violet for storms. It also faintly tints the whole surface.
  ///
  /// Light variants are deep enough for white text on an accent button;
  /// dark variants are bright enough to read on the night surface.
  Color accent({required bool isDark}) {
    final mood = switch (this) {
      WeatherCondition.clear || WeatherCondition.partlyCloudy => _Mood.sunny,
      WeatherCondition.cloudy || WeatherCondition.unknown => _Mood.overcast,
      WeatherCondition.fog => _Mood.misty,
      WeatherCondition.drizzle || WeatherCondition.rain => _Mood.rainy,
      WeatherCondition.snow => _Mood.snowy,
      WeatherCondition.thunderstorm => _Mood.stormy,
    };
    return isDark ? mood.dark : mood.light;
  }
}

/// Accent to use before any weather has loaded.
Color brandAccent({required bool isDark}) =>
    isDark ? AppColors.brandDark : AppColors.brandLight;

enum _Mood {
  sunny(light: Color(0xFFC8620C), dark: Color(0xFFFFB35C)),
  overcast(light: Color(0xFF56688A), dark: Color(0xFFA9B9D3)),
  misty(light: Color(0xFF5E6B7D), dark: Color(0xFFB4BECC)),
  rainy(light: Color(0xFF2A72C9), dark: Color(0xFF6DB3FF)),
  snowy(light: Color(0xFF2380B5), dark: Color(0xFF7FD3FF)),
  stormy(light: Color(0xFF6247D6), dark: Color(0xFFA792FF));

  const _Mood({required this.light, required this.dark});

  final Color light;
  final Color dark;
}
