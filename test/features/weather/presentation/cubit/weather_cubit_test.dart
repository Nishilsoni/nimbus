import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nimbus/core/error/failures.dart';
import 'package:nimbus/core/utils/result.dart';
import 'package:nimbus/features/weather/domain/entities/city.dart';
import 'package:nimbus/features/weather/domain/entities/weather_report.dart';
import 'package:nimbus/features/weather/domain/repositories/location_repository.dart';
import 'package:nimbus/features/weather/domain/repositories/weather_repository.dart';
import 'package:nimbus/features/weather/presentation/cubit/weather_cubit.dart';
import 'package:nimbus/features/weather/presentation/cubit/weather_state.dart';

import '../../../../helpers/test_data.dart';

class _MockWeatherRepository extends Mock implements WeatherRepository {}

class _MockLocationRepository extends Mock implements LocationRepository {}

void main() {
  late _MockWeatherRepository weatherRepository;
  late _MockLocationRepository locationRepository;

  final cachedReport = TestData.report(at: DateTime(2026, 9, 24, 8));
  final liveReport = TestData.report();
  final londonReport = TestData.report(city: TestData.london);

  const noInternet = NoInternetFailure();
  const permissionDenied = LocationFailure(
    LocationFailureReason.permissionDenied,
  );

  final showingLive = WeatherState(
    status: WeatherStatus.success,
    report: liveReport,
  );

  setUpAll(() {
    registerFallbackValue(TestData.ahmedabad);
    registerFallbackValue(LocationFailureReason.unavailable);
  });

  setUp(() {
    weatherRepository = _MockWeatherRepository();
    locationRepository = _MockLocationRepository();
  });

  WeatherCubit buildCubit() => WeatherCubit(
    weatherRepository: weatherRepository,
    locationRepository: locationRepository,
  );

  void stubWeather(Result<WeatherReport> result, {City? forCity}) {
    when(
      () => weatherRepository.getWeather(forCity ?? any()),
    ).thenAnswer((_) async => result);
  }

  test('starts with nothing to show', () {
    expect(buildCubit().state, const WeatherState());
  });

  group('loadInitialWeather', () {
    blocTest<WeatherCubit, WeatherState>(
      'stays in the initial state when nothing is cached',
      setUp: () => when(
        () => weatherRepository.getLastReport(),
      ).thenAnswer((_) async => null),
      build: buildCubit,
      act: (cubit) => cubit.loadInitialWeather(),
      expect: () => <WeatherState>[],
      verify: (_) => verifyNever(() => weatherRepository.getWeather(any())),
    );

    blocTest<WeatherCubit, WeatherState>(
      'shows the cached report at once, then replaces it with live data',
      setUp: () {
        when(
          () => weatherRepository.getLastReport(),
        ).thenAnswer((_) async => cachedReport);
        stubWeather(Ok(liveReport));
      },
      build: buildCubit,
      act: (cubit) => cubit.loadInitialWeather(),
      expect: () => [
        WeatherState(
          status: WeatherStatus.success,
          report: cachedReport,
          isFromCache: true,
        ),
        WeatherState(
          status: WeatherStatus.success,
          report: cachedReport,
          isFromCache: true,
          isRefreshing: true,
        ),
        showingLive,
      ],
    );

    blocTest<WeatherCubit, WeatherState>(
      'keeps showing the cached report when opened offline',
      setUp: () {
        when(
          () => weatherRepository.getLastReport(),
        ).thenAnswer((_) async => cachedReport);
        stubWeather(const Err(noInternet));
      },
      build: buildCubit,
      act: (cubit) => cubit.loadInitialWeather(),
      skip: 2,
      expect: () => [
        WeatherState(
          status: WeatherStatus.success,
          report: cachedReport,
          isFromCache: true,
          failure: noInternet,
        ),
      ],
    );
  });

  group('selectCity without data on screen', () {
    blocTest<WeatherCubit, WeatherState>(
      'shows loading, then the weather',
      setUp: () => stubWeather(Ok(liveReport)),
      build: buildCubit,
      act: (cubit) => cubit.selectCity(TestData.ahmedabad),
      expect: () => [
        const WeatherState(status: WeatherStatus.loading),
        showingLive,
      ],
    );

    blocTest<WeatherCubit, WeatherState>(
      'shows loading, then a full-screen failure',
      setUp: () => stubWeather(const Err(noInternet)),
      build: buildCubit,
      act: (cubit) => cubit.selectCity(TestData.ahmedabad),
      expect: () => [
        const WeatherState(status: WeatherStatus.loading),
        const WeatherState(status: WeatherStatus.failure, failure: noInternet),
      ],
    );
  });

  group('refresh with data on screen', () {
    blocTest<WeatherCubit, WeatherState>(
      'keeps the previous data visible when the refresh fails',
      setUp: () => stubWeather(const Err(noInternet)),
      build: buildCubit,
      seed: () => showingLive,
      act: (cubit) => cubit.refresh(),
      expect: () => [
        showingLive.copyWith(isRefreshing: true),
        showingLive.copyWith(failure: noInternet),
      ],
    );

    blocTest<WeatherCubit, WeatherState>(
      'clears the previous failure when a new attempt starts and succeeds',
      setUp: () => stubWeather(Ok(liveReport)),
      build: buildCubit,
      seed: () => showingLive.copyWith(failure: noInternet),
      act: (cubit) => cubit.refresh(),
      expect: () => [showingLive.copyWith(isRefreshing: true), showingLive],
    );

    blocTest<WeatherCubit, WeatherState>(
      're-fetches the city that is on screen',
      setUp: () => stubWeather(Ok(liveReport)),
      build: buildCubit,
      seed: () => showingLive,
      act: (cubit) => cubit.refresh(),
      verify: (_) => verify(
        () => weatherRepository.getWeather(TestData.ahmedabad),
      ).called(1),
    );

    blocTest<WeatherCubit, WeatherState>(
      'joins a refresh that is already running instead of starting another',
      setUp: () => stubWeather(Ok(liveReport)),
      build: buildCubit,
      seed: () => showingLive,
      act: (cubit) async {
        final first = cubit.refresh();
        final second = cubit.refresh();
        expect(identical(first, second), isTrue);
        await first;
      },
      verify: (_) =>
          verify(() => weatherRepository.getWeather(any())).called(1),
    );

    blocTest<WeatherCubit, WeatherState>(
      'reports a failed city switch without losing the current city',
      setUp: () => stubWeather(const Err(noInternet), forCity: TestData.london),
      build: buildCubit,
      seed: () => showingLive,
      act: (cubit) => cubit.selectCity(TestData.london),
      expect: () => [
        showingLive.copyWith(isRefreshing: true),
        showingLive.copyWith(failure: noInternet),
      ],
    );
  });

  group('overlapping requests', () {
    blocTest<WeatherCubit, WeatherState>(
      'ignores a slow response that was superseded by a newer request',
      setUp: () {
        final slowLondon = Completer<Result<WeatherReport>>();
        when(() => weatherRepository.getWeather(TestData.london)).thenAnswer((
          _,
        ) {
          // London answers only after Ahmedabad has already been shown.
          Future<void>.delayed(
            const Duration(milliseconds: 20),
            () => slowLondon.complete(Ok(londonReport)),
          );
          return slowLondon.future;
        });
        stubWeather(Ok(liveReport), forCity: TestData.ahmedabad);
      },
      build: buildCubit,
      act: (cubit) async {
        unawaited(cubit.selectCity(TestData.london));
        await cubit.selectCity(TestData.ahmedabad);
      },
      wait: const Duration(milliseconds: 50),
      expect: () => [
        const WeatherState(status: WeatherStatus.loading),
        showingLive,
      ],
    );
  });

  group('useCurrentLocation', () {
    blocTest<WeatherCubit, WeatherState>(
      'fetches weather for the resolved position',
      setUp: () {
        when(
          () => locationRepository.getCurrentCity(),
        ).thenAnswer((_) async => const Ok(TestData.currentLocation));
        stubWeather(Ok(TestData.report(city: TestData.currentLocation)));
      },
      build: buildCubit,
      act: (cubit) => cubit.useCurrentLocation(),
      expect: () => [
        const WeatherState(status: WeatherStatus.loading),
        WeatherState(
          status: WeatherStatus.success,
          report: TestData.report(city: TestData.currentLocation),
        ),
      ],
    );

    blocTest<WeatherCubit, WeatherState>(
      'shows why the location could not be used',
      setUp: () => when(
        () => locationRepository.getCurrentCity(),
      ).thenAnswer((_) async => const Err(permissionDenied)),
      build: buildCubit,
      act: (cubit) => cubit.useCurrentLocation(),
      expect: () => [
        const WeatherState(status: WeatherStatus.loading),
        const WeatherState(
          status: WeatherStatus.failure,
          failure: permissionDenied,
        ),
      ],
      verify: (_) => verifyNever(() => weatherRepository.getWeather(any())),
    );

    blocTest<WeatherCubit, WeatherState>(
      'retries the location request when refreshing with no data yet',
      setUp: () => when(
        () => locationRepository.getCurrentCity(),
      ).thenAnswer((_) async => const Err(permissionDenied)),
      build: buildCubit,
      act: (cubit) async {
        await cubit.useCurrentLocation();
        await cubit.refresh();
      },
      verify: (_) =>
          verify(() => locationRepository.getCurrentCity()).called(2),
    );
  });

  blocTest<WeatherCubit, WeatherState>(
    'dismissFailure hides the failure but keeps the data',
    build: buildCubit,
    seed: () => showingLive.copyWith(failure: noInternet),
    act: (cubit) => cubit.dismissFailure(),
    expect: () => [showingLive],
  );

  blocTest<WeatherCubit, WeatherState>(
    'openLocationSettings opens the screen that fixes the current failure',
    setUp: () => when(
      () => locationRepository.openSettings(any()),
    ).thenAnswer((_) async {}),
    build: buildCubit,
    seed: () => const WeatherState(
      status: WeatherStatus.failure,
      failure: LocationFailure(LocationFailureReason.permissionDeniedForever),
    ),
    act: (cubit) => cubit.openLocationSettings(),
    verify: (_) => verify(
      () => locationRepository.openSettings(
        LocationFailureReason.permissionDeniedForever,
      ),
    ).called(1),
  );
}
