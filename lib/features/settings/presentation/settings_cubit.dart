import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nimbus/core/utils/temperature_unit.dart';
import 'package:nimbus/features/settings/domain/app_settings.dart';
import 'package:nimbus/features/settings/domain/settings_repository.dart';

/// Applies each change at once, then saves it for the next launch.
class SettingsCubit extends Cubit<AppSettings> {
  SettingsCubit(this._repository) : super(_repository.load());

  final SettingsRepository _repository;

  Future<void> setAppearance(AppearanceMode appearance) =>
      _update(state.copyWith(appearance: appearance));

  Future<void> setTemperatureUnit(TemperatureUnit unit) =>
      _update(state.copyWith(temperatureUnit: unit));

  /// `null` follows the device language.
  Future<void> setLanguage(String? languageCode) => _update(
    state.copyWith(
      languageCode: languageCode,
      useDeviceLanguage: languageCode == null,
    ),
  );

  Future<void> _update(AppSettings settings) async {
    if (settings == state) return;
    emit(settings);
    await _repository.save(settings);
  }
}

extension AppearanceThemeMode on AppearanceMode {
  /// The theme to show. In automatic mode it follows day or night at the
  /// city on screen ([isDay]), or the device setting while that's unknown.
  ThemeMode toThemeMode({required bool? isDay}) => switch (this) {
    AppearanceMode.light => ThemeMode.light,
    AppearanceMode.dark => ThemeMode.dark,
    AppearanceMode.automatic => switch (isDay) {
      null => ThemeMode.system,
      true => ThemeMode.light,
      false => ThemeMode.dark,
    },
  };
}
