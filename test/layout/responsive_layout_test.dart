import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nimbus/core/error/failures.dart';
import 'package:nimbus/core/utils/result.dart';
import 'package:nimbus/features/settings/presentation/settings_cubit.dart';
import 'package:nimbus/features/settings/presentation/widgets/settings_sheet.dart';
import 'package:nimbus/features/weather/domain/entities/place.dart';
import 'package:nimbus/features/weather/domain/entities/saved_places.dart';
import 'package:nimbus/features/weather/domain/repositories/location_repository.dart';
import 'package:nimbus/features/weather/domain/repositories/weather_repository.dart';
import 'package:nimbus/features/weather/presentation/cubit/places_cubit.dart';
import 'package:nimbus/features/weather/presentation/cubit/weather_cubit.dart';
import 'package:nimbus/features/weather/presentation/cubit/weather_look_cubit.dart';
import 'package:nimbus/features/weather/presentation/cubit/weather_state.dart';
import 'package:nimbus/features/weather/presentation/screens/city_search_screen.dart';
import 'package:nimbus/features/weather/presentation/screens/weather_page.dart';
import 'package:nimbus/features/weather/presentation/screens/weather_screen.dart';
import 'package:nimbus/features/weather/presentation/widgets/current_conditions.dart';
import 'package:nimbus/features/weather/presentation/widgets/empty_view.dart';
import 'package:nimbus/features/weather/presentation/widgets/hourly_forecast_card.dart';

import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';
import '../helpers/test_data.dart';

/// Renders every main screen at the sizes people actually use, with normal
/// and large text. Any overflow fails the test.
void main() {
  const screens = {
    'small phone': Size(320, 568),
    'phone': Size(390, 844),
    'large phone': Size(440, 956),
    'phone landscape': Size(844, 390),
    'foldable': Size(673, 841),
    'tablet portrait': Size(820, 1180),
    'tablet landscape': Size(1180, 820),
    'large tablet landscape': Size(1366, 1024),
  };

  late MockWeatherCubit cubit;

  setUpAll(() => registerFallbackValue(const CurrentLocationPlace()));

  setUp(() {
    cubit = MockWeatherCubit();
    when(() => cubit.place).thenReturn(const CityPlace(TestData.ahmedabad));
  });

  Future<void> useScreen(
    WidgetTester tester,
    Size size, {
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  /// Providers above the whole app, as in production, so pushed routes
  /// and sheets can reach them.
  Widget Function(Widget app) providers({
    SavedPlaces saved = const SavedPlaces(),
  }) {
    final repository = MockWeatherRepository();
    when(
      () => repository.searchCities(
        any(),
        languageCode: any(named: 'languageCode'),
      ),
    ).thenAnswer((_) async => const Ok([TestData.ahmedabad]));
    when(() => repository.getCachedReport(any())).thenReturn(null);
    return (app) => MultiRepositoryProvider(
      providers: [
        RepositoryProvider<WeatherRepository>.value(value: repository),
        RepositoryProvider<LocationRepository>.value(
          value: MockLocationRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<WeatherCubit>.value(value: cubit),
          BlocProvider(create: (_) => PlacesCubit(FakePlacesRepository(saved))),
          BlocProvider(create: (_) => SettingsCubit(FakeSettingsRepository())),
          BlocProvider(create: (_) => WeatherLookCubit()),
        ],
        child: app,
      ),
    );
  }

  Future<void> pumpPage(WidgetTester tester, WeatherState state) async {
    when(() => cubit.state).thenReturn(state);
    await tester.pumpApp(
      const Scaffold(body: WeatherPage()),
      wrap: providers(),
    );
    await tester.pumpEntrances();
  }

  final showingData = WeatherState(
    status: WeatherStatus.success,
    report: TestData.report(),
  );

  for (final MapEntry(key: name, value: size) in screens.entries) {
    for (final textScale in [1.0, 1.4]) {
      final label = '$name, text ×$textScale';

      testWidgets('weather fits on $label', (tester) async {
        await useScreen(tester, size, textScale: textScale);
        await pumpPage(
          tester,
          showingData.copyWith(failure: const NoInternetFailure()),
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('loading and error fit on $label', (tester) async {
        await useScreen(tester, size, textScale: textScale);
        await pumpPage(
          tester,
          const WeatherState(status: WeatherStatus.loading),
        );
        await pumpPage(
          tester,
          const WeatherState(
            status: WeatherStatus.failure,
            failure: LocationFailure(LocationFailureReason.permissionDenied),
          ),
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('welcome view fits on $label', (tester) async {
        await useScreen(tester, size, textScale: textScale);
        await tester.pumpApp(const WeatherScreen(), wrap: providers());
        await tester.pumpEntrances();
        expect(find.byType(EmptyView), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('search and saved places fit on $label', (tester) async {
        await useScreen(tester, size, textScale: textScale);
        await tester.pumpApp(
          Builder(
            builder: (context) => TextButton(
              onPressed: () =>
                  Navigator.of(context).push(CitySearchScreen.route()),
              child: const Text('open'),
            ),
          ),
          wrap: providers(
            saved: const SavedPlaces(
              includesCurrentLocation: true,
              cities: [TestData.ahmedabad, TestData.london],
            ),
          ),
        );
        await tester.tap(find.text('open'));
        await tester.pumpEntrances();
        expect(tester.takeException(), isNull);
      });

      testWidgets('settings sheet fits on $label', (tester) async {
        await useScreen(tester, size, textScale: textScale);
        await tester.pumpApp(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showSettingsSheet(context),
              child: const Text('open'),
            ),
          ),
          wrap: providers(),
        );
        await tester.tap(find.text('open'));
        await tester.pumpEntrances();
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('phones stack the forecast under the hero', (tester) async {
    await useScreen(tester, screens['phone']!);
    await pumpPage(tester, showingData);

    final hero = tester.getRect(find.byType(CurrentConditions));
    final hourly = tester.getRect(find.byType(HourlyForecastCard));
    expect(hourly.top, greaterThan(hero.bottom));
  });

  testWidgets('wide screens put the forecast beside the hero', (tester) async {
    await useScreen(tester, screens['tablet landscape']!);
    await pumpPage(tester, showingData);

    final hero = tester.getRect(find.byType(CurrentConditions));
    final hourly = tester.getRect(find.byType(HourlyForecastCard));
    expect(hourly.left, greaterThan(hero.right));
  });

  testWidgets('phones on their side also use two columns', (tester) async {
    await useScreen(tester, screens['phone landscape']!);
    await pumpPage(tester, showingData);

    final hero = tester.getRect(find.byType(CurrentConditions));
    final hourly = tester.getRect(find.byType(HourlyForecastCard));
    expect(hourly.left, greaterThan(hero.right));
  });
}
