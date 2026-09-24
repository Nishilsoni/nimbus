import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus/core/utils/temperature_unit.dart';
import 'package:nimbus/features/settings/data/settings_repository_impl.dart';
import 'package:nimbus/features/settings/domain/app_settings.dart';
import 'package:nimbus/features/settings/domain/settings_repository.dart';
import 'package:nimbus/features/settings/presentation/settings_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeRepository implements SettingsRepository {
  AppSettings saved = const AppSettings();

  @override
  AppSettings load() => saved;

  @override
  Future<void> save(AppSettings settings) async => saved = settings;
}

void main() {
  Future<SettingsRepositoryImpl> repositoryWith(
    Map<String, Object> saved,
  ) async {
    SharedPreferences.setMockInitialValues(saved);
    return SettingsRepositoryImpl(await SharedPreferences.getInstance());
  }

  group('SettingsRepositoryImpl', () {
    test('defaults to automatic, Celsius and the device language', () async {
      final repository = await repositoryWith({});

      expect(repository.load(), const AppSettings());
    });

    test('reads back what it saved', () async {
      final repository = await repositoryWith({});
      const settings = AppSettings(
        appearance: AppearanceMode.dark,
        temperatureUnit: TemperatureUnit.fahrenheit,
        languageCode: 'gu',
      );

      await repository.save(settings);

      expect(repository.load(), settings);
    });

    test('forgets the language when set back to the device', () async {
      final repository = await repositoryWith({});
      await repository.save(const AppSettings(languageCode: 'hi'));

      await repository.save(const AppSettings());

      expect(repository.load().languageCode, isNull);
    });

    test('ignores unknown saved values', () async {
      final repository = await repositoryWith({
        SettingsRepositoryImpl.appearanceKey: 'sepia',
        SettingsRepositoryImpl.temperatureUnitKey: 'kelvin',
      });

      expect(repository.load(), const AppSettings());
    });
  });

  group('SettingsCubit', () {
    blocTest<SettingsCubit, AppSettings>(
      'applies each change at once',
      build: () => SettingsCubit(_FakeRepository()),
      act: (cubit) async {
        await cubit.setAppearance(AppearanceMode.light);
        await cubit.setTemperatureUnit(TemperatureUnit.fahrenheit);
        await cubit.setLanguage('hi');
        await cubit.setLanguage(null);
      },
      expect: () => const [
        AppSettings(appearance: AppearanceMode.light),
        AppSettings(
          appearance: AppearanceMode.light,
          temperatureUnit: TemperatureUnit.fahrenheit,
        ),
        AppSettings(
          appearance: AppearanceMode.light,
          temperatureUnit: TemperatureUnit.fahrenheit,
          languageCode: 'hi',
        ),
        AppSettings(
          appearance: AppearanceMode.light,
          temperatureUnit: TemperatureUnit.fahrenheit,
        ),
      ],
    );

    test('saves every change for the next launch', () async {
      final repository = _FakeRepository();
      final cubit = SettingsCubit(repository);

      await cubit.setTemperatureUnit(TemperatureUnit.fahrenheit);

      expect(repository.saved.temperatureUnit, TemperatureUnit.fahrenheit);
    });
  });

  group('toThemeMode', () {
    test('light and dark ignore the time of day', () {
      expect(AppearanceMode.light.toThemeMode(isDay: false), ThemeMode.light);
      expect(AppearanceMode.dark.toThemeMode(isDay: true), ThemeMode.dark);
    });

    test('automatic follows day and night at the city on screen', () {
      const mode = AppearanceMode.automatic;
      expect(mode.toThemeMode(isDay: true), ThemeMode.light);
      expect(mode.toThemeMode(isDay: false), ThemeMode.dark);
      expect(mode.toThemeMode(isDay: null), ThemeMode.system);
    });
  });

  test('Fahrenheit converts from Celsius', () {
    expect(TemperatureUnit.fahrenheit.fromCelsius(0), 32);
    expect(TemperatureUnit.fahrenheit.fromCelsius(100), 212);
    expect(TemperatureUnit.celsius.fromCelsius(21.5), 21.5);
  });
}
