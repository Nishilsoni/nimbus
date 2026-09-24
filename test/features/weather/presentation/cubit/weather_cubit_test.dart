import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nimbus/core/error/failures.dart';
import 'package:nimbus/core/utils/result.dart';
import 'package:nimbus/features/weather/domain/entities/place.dart';
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

  const ahmedabadPage = CityPlace(TestData.ahmedabad);
  const locationPage = CurrentLocationPlace();

  final cachedReport = TestData.report(at: DateTime(2026, 9, 24, 8));
  final liveReport = TestData.report();

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
    registerFallbackValue(ahmedabadPage);
    registerFallbackValue(LocationFailureReason.unavailable);
  });

  setUp(() {
    weatherRepository = _MockWeatherRepository();
    locationRepository = _MockLocationRepository();
    when(() => weatherRepository.getCachedReport(any())).thenReturn(null);
  });

  WeatherCubit buildCubit({Place place = ahmedabadPage}) => WeatherCubit(
    place: place,
    weatherRepository: weatherRepository,
    locationRepository: locationRepository,
  );

  void stubWeather(Result<WeatherReport> result) {
    when(
      () => weatherRepository.getWeather(any()),
    ).thenAnswer((_) async => result);
  }

  group('initial state', () {
    test('is empty when nothing is cached', () {
      expect(buildCubit().state, const WeatherState());
    });

    test("shows the place's cached report straight away", () {
      when(
        () => weatherRepository.getCachedReport(ahmedabadPage),
      ).thenReturn(cachedReport);

      expect(
        buildCubit().state,
        WeatherState(
          status: WeatherStatus.success,
          report: cachedReport,
          isFromCache: true,
        ),
      );
    });
  });

  group('refresh without data on screen', () {
    blocTest<WeatherCubit, WeatherState>(
      'shows loading, then the weather',
      setUp: () => stubWeather(Ok(liveReport)),
      build: buildCubit,
      act: (cubit) => cubit.refresh(),
      expect: () => [
        const WeatherState(status: WeatherStatus.loading),
        showingLive,
      ],
      verify: (_) => verify(
        () => weatherRepository.getWeather(TestData.ahmedabad),
      ).called(1),
    );

    blocTest<WeatherCubit, WeatherState>(
      'shows loading, then a full-screen failure',
      setUp: () => stubWeather(const Err(noInternet)),
      build: buildCubit,
      act: (cubit) => cubit.refresh(),
      expect: () => [
        const WeatherState(status: WeatherStatus.loading),
        const WeatherState(status: WeatherStatus.failure, failure: noInternet),
      ],
    );
  });

  group('refresh with data on screen', () {
    blocTest<WeatherCubit, WeatherState>(
      'replaces cached data with live data',
      setUp: () {
        when(
          () => weatherRepository.getCachedReport(ahmedabadPage),
        ).thenReturn(cachedReport);
        stubWeather(Ok(liveReport));
      },
      build: buildCubit,
      act: (cubit) => cubit.refresh(),
      expect: () => [
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
      'keeps cached data when opened offline',
      setUp: () {
        when(
          () => weatherRepository.getCachedReport(ahmedabadPage),
        ).thenReturn(cachedReport);
        stubWeather(const Err(noInternet));
      },
      build: buildCubit,
      act: (cubit) => cubit.refresh(),
      skip: 1,
      expect: () => [
        WeatherState(
          status: WeatherStatus.success,
          report: cachedReport,
          isFromCache: true,
          failure: noInternet,
        ),
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
      'starts a new request once the previous one has finished',
      setUp: () => stubWeather(Ok(liveReport)),
      build: buildCubit,
      act: (cubit) async {
        await cubit.refresh();
        await cubit.refresh();
      },
      verify: (_) =>
          verify(() => weatherRepository.getWeather(any())).called(2),
    );

    blocTest<WeatherCubit, WeatherState>(
      'ignores a response that arrives after the page was closed',
      setUp: () {
        final slow = Completer<Result<WeatherReport>>();
        when(
          () => weatherRepository.getWeather(any()),
        ).thenAnswer((_) => slow.future);
        Future<void>.delayed(
          const Duration(milliseconds: 20),
          () => slow.complete(Ok(liveReport)),
        );
      },
      build: buildCubit,
      act: (cubit) async {
        unawaited(cubit.refresh());
        await cubit.close();
      },
      wait: const Duration(milliseconds: 40),
      expect: () => [const WeatherState(status: WeatherStatus.loading)],
    );
  });

  group('the location page', () {
    blocTest<WeatherCubit, WeatherState>(
      'takes a GPS fix, then fetches weather for it',
      setUp: () {
        when(
          () => locationRepository.getCurrentCity(),
        ).thenAnswer((_) async => const Ok(TestData.currentLocation));
        stubWeather(Ok(TestData.report(city: TestData.currentLocation)));
      },
      build: () => buildCubit(place: locationPage),
      act: (cubit) => cubit.refresh(),
      expect: () => [
        const WeatherState(status: WeatherStatus.loading),
        WeatherState(
          status: WeatherStatus.success,
          report: TestData.report(city: TestData.currentLocation),
        ),
      ],
      verify: (_) => verify(
        () => weatherRepository.getWeather(TestData.currentLocation),
      ).called(1),
    );

    blocTest<WeatherCubit, WeatherState>(
      'shows why the location could not be used',
      setUp: () => when(
        () => locationRepository.getCurrentCity(),
      ).thenAnswer((_) async => const Err(permissionDenied)),
      build: () => buildCubit(place: locationPage),
      act: (cubit) => cubit.refresh(),
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
      'takes a fresh fix on every refresh',
      setUp: () => when(
        () => locationRepository.getCurrentCity(),
      ).thenAnswer((_) async => const Err(permissionDenied)),
      build: () => buildCubit(place: locationPage),
      act: (cubit) async {
        await cubit.refresh();
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
    build: () => buildCubit(place: locationPage),
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
