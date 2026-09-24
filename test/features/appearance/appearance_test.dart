import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus/features/appearance/data/appearance_repository_impl.dart';
import 'package:nimbus/features/appearance/domain/appearance_mode.dart';
import 'package:nimbus/features/appearance/domain/appearance_repository.dart';
import 'package:nimbus/features/appearance/presentation/appearance_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<AppearanceRepositoryImpl> repositoryWith(
    Map<String, Object> saved,
  ) async {
    SharedPreferences.setMockInitialValues(saved);
    return AppearanceRepositoryImpl(await SharedPreferences.getInstance());
  }

  group('AppearanceRepositoryImpl', () {
    test('defaults to automatic when nothing is saved', () async {
      final repository = await repositoryWith({});

      expect(repository.load(), AppearanceMode.automatic);
    });

    test('reads back the saved mode', () async {
      final repository = await repositoryWith({});

      await repository.save(AppearanceMode.dark);

      expect(repository.load(), AppearanceMode.dark);
    });

    test('ignores an unknown saved value', () async {
      final repository = await repositoryWith({
        AppearanceRepositoryImpl.storageKey: 'sepia',
      });

      expect(repository.load(), AppearanceMode.automatic);
    });
  });

  group('AppearanceCubit', () {
    blocTest<AppearanceCubit, AppearanceMode>(
      'starts from the saved mode',
      build: () =>
          AppearanceCubit(_FakeRepository(saved: AppearanceMode.light)),
      verify: (cubit) => expect(cubit.state, AppearanceMode.light),
    );

    blocTest<AppearanceCubit, AppearanceMode>(
      'cycles automatic → light → dark → automatic',
      build: () => AppearanceCubit(_FakeRepository()),
      act: (cubit) async {
        await cubit.cycle();
        await cubit.cycle();
        await cubit.cycle();
      },
      expect: () => const [
        AppearanceMode.light,
        AppearanceMode.dark,
        AppearanceMode.automatic,
      ],
    );

    test('saves every change for the next launch', () async {
      final repository = _FakeRepository();
      final cubit = AppearanceCubit(repository);

      await cubit.select(AppearanceMode.dark);

      expect(repository.saved, AppearanceMode.dark);
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
}

class _FakeRepository implements AppearanceRepository {
  _FakeRepository({this.saved = AppearanceMode.automatic});

  AppearanceMode saved;

  @override
  AppearanceMode load() => saved;

  @override
  Future<void> save(AppearanceMode mode) async => saved = mode;
}
