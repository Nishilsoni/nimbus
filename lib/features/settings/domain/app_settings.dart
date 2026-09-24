import 'package:equatable/equatable.dart';
import 'package:nimbus/core/utils/temperature_unit.dart';

/// How the app chooses between its light and dark looks.
enum AppearanceMode {
  /// Light by day and dark by night at the city on screen. Before any
  /// weather has loaded, follows the device's light/dark setting.
  automatic,
  light,
  dark,
}

/// Everything the user can choose in the settings sheet.
class AppSettings extends Equatable {
  const AppSettings({
    this.appearance = AppearanceMode.automatic,
    this.temperatureUnit = TemperatureUnit.celsius,
    this.languageCode,
  });

  final AppearanceMode appearance;
  final TemperatureUnit temperatureUnit;

  /// A supported language such as "hi", or `null` to follow the device.
  final String? languageCode;

  AppSettings copyWith({
    AppearanceMode? appearance,
    TemperatureUnit? temperatureUnit,
    String? languageCode,
    bool useDeviceLanguage = false,
  }) {
    return AppSettings(
      appearance: appearance ?? this.appearance,
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      languageCode: useDeviceLanguage
          ? null
          : languageCode ?? this.languageCode,
    );
  }

  @override
  List<Object?> get props => [appearance, temperatureUnit, languageCode];
}
