import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nimbus/core/utils/result.dart';
import 'package:nimbus/features/settings/presentation/settings_cubit.dart';
import 'package:nimbus/features/weather/domain/entities/city.dart';
import 'package:nimbus/features/weather/domain/entities/place.dart';
import 'package:nimbus/features/weather/domain/entities/saved_places.dart';
import 'package:nimbus/features/weather/domain/repositories/location_repository.dart';
import 'package:nimbus/features/weather/domain/repositories/weather_repository.dart';
import 'package:nimbus/features/weather/presentation/cubit/places_cubit.dart';
import 'package:nimbus/features/weather/presentation/cubit/weather_look_cubit.dart';
import 'package:nimbus/features/weather/presentation/screens/weather_screen.dart';
import 'package:nimbus/features/weather/presentation/widgets/empty_view.dart';
import 'package:nimbus/features/weather/presentation/widgets/page_dots.dart';

import '../../../../helpers/fakes.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/test_data.dart';

void main() {
  late MockWeatherRepository weatherRepository;
  late PlacesCubit places;
  late WeatherLookCubit look;

  setUpAll(() {
    registerFallbackValue(TestData.ahmedabad);
    registerFallbackValue(const CurrentLocationPlace());
  });

  setUp(() {
    weatherRepository = MockWeatherRepository();
    when(() => weatherRepository.getCachedReport(any())).thenReturn(null);
    when(() => weatherRepository.getWeather(any())).thenAnswer(
      (invocation) async => Ok(
        TestData.report(city: invocation.positionalArguments.first as City),
      ),
    );
    look = WeatherLookCubit();
  });

  Future<void> pumpScreen(WidgetTester tester, SavedPlaces saved) async {
    places = PlacesCubit(FakePlacesRepository(saved));
    await tester.pumpApp(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<WeatherRepository>.value(value: weatherRepository),
          RepositoryProvider<LocationRepository>.value(
            value: MockLocationRepository(),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: places),
            BlocProvider.value(value: look),
            BlocProvider(
              create: (_) => SettingsCubit(FakeSettingsRepository()),
            ),
          ],
          child: const WeatherScreen(),
        ),
      ),
    );
    await tester.pumpEntrances();
  }

  testWidgets('welcomes the user when no places are saved', (tester) async {
    await pumpScreen(tester, const SavedPlaces());

    expect(find.byType(EmptyView), findsOneWidget);
    expect(find.byType(PageView), findsNothing);
  });

  testWidgets('shows one page per place, with page dots', (tester) async {
    await pumpScreen(
      tester,
      const SavedPlaces(cities: [TestData.ahmedabad, TestData.london]),
    );

    expect(find.byType(PageView), findsOneWidget);
    expect(find.byType(PageDots), findsOneWidget);
    expect(find.text('Ahmedabad'), findsOneWidget);
  });

  testWidgets('hides the dots when there is only one place', (tester) async {
    await pumpScreen(tester, const SavedPlaces(cities: [TestData.london]));

    expect(find.byType(PageDots), findsNothing);
  });

  testWidgets('swiping moves to the next place and themes the app for it', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const SavedPlaces(cities: [TestData.ahmedabad, TestData.london]),
    );

    await tester.fling(find.byType(PageView), const Offset(-400, 0), 1500);
    await tester.pumpEntrances();

    expect(places.state.selectedIndex, 1);
    expect(find.text('London'), findsOneWidget);
    expect(look.state.condition, TestData.weather.condition);
  });

  testWidgets('moves to a place when it is added', (tester) async {
    await pumpScreen(tester, const SavedPlaces(cities: [TestData.ahmedabad]));

    await places.addCity(TestData.london);
    await tester.pumpEntrances();

    expect(find.text('London'), findsOneWidget);
    verify(() => weatherRepository.getWeather(TestData.london)).called(1);
  });
}
