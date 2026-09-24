import 'package:nimbus/core/utils/temperature_unit.dart';
import 'package:nimbus/features/settings/domain/app_settings.dart';
import 'package:nimbus/features/settings/domain/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._preferences);

  static const appearanceKey = 'appearance_mode';
  static const temperatureUnitKey = 'temperature_unit';
  static const languageKey = 'language_code';

  final SharedPreferences _preferences;

  /// Synchronous: preferences are already in memory at startup, so the
  /// first frame uses the right theme and language instead of flashing the
  /// wrong ones. Unknown saved values fall back to the defaults.
  @override
  AppSettings load() => AppSettings(
    appearance: _enumValue(
      AppearanceMode.values,
      appearanceKey,
      AppearanceMode.automatic,
    ),
    temperatureUnit: _enumValue(
      TemperatureUnit.values,
      temperatureUnitKey,
      TemperatureUnit.celsius,
    ),
    languageCode: _preferences.getString(languageKey),
  );

  @override
  Future<void> save(AppSettings settings) async {
    await _preferences.setString(appearanceKey, settings.appearance.name);
    await _preferences.setString(
      temperatureUnitKey,
      settings.temperatureUnit.name,
    );
    final languageCode = settings.languageCode;
    if (languageCode == null) {
      await _preferences.remove(languageKey);
    } else {
      await _preferences.setString(languageKey, languageCode);
    }
  }

  T _enumValue<T extends Enum>(List<T> values, String key, T fallback) {
    final saved = _preferences.getString(key);
    return values.firstWhere(
      (value) => value.name == saved,
      orElse: () => fallback,
    );
  }
}
