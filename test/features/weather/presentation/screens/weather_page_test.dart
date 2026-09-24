import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nimbus/core/error/failures.dart';
import 'package:nimbus/core/utils/temperature_unit.dart';
import 'package:nimbus/core/widgets/tactile/tactile_pressable.dart';
import 'package:nimbus/features/settings/presentation/settings_cubit.dart';
import 'package:nimbus/features/weather/domain/entities/place.dart';
import 'package:nimbus/features/weather/presentation/cubit/places_cubit.dart';
import 'package:nimbus/features/weather/presentation/cubit/weather_cubit.dart';
import 'package:nimbus/features/weather/presentation/cubit/weather_state.dart';
import 'package:nimbus/features/weather/presentation/screens/weather_page.dart';
import 'package:nimbus/features/weather/presentation/widgets/daily_forecast_card.dart';
import 'package:nimbus/features/weather/presentation/widgets/error_view.dart';
import 'package:nimbus/features/weather/presentation/widgets/hourly_forecast_card.dart';
import 'package:nimbus/features/weather/presentation/widgets/loading_view.dart';
import 'package:nimbus/features/weather/presentation/widgets/refresh_status_banner.dart';
import 'package:nimbus/features/weather/presentation/widgets/weather_content.dart';

import '../../../../helpers/fakes.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/test_data.dart';

void main() {
  late MockWeatherCubit cubit;

  final showingData = WeatherState(
    status: WeatherStatus.success,
    report: TestData.report(),
  );

  setUp(() {
    cubit = MockWeatherCubit();
    when(() => cubit.place).thenReturn(const CityPlace(TestData.ahmedabad));
    when(() => cubit.refresh()).thenAnswer((_) async {});
    when(() => cubit.openLocationSettings()).thenAnswer((_) async {});
  });

  Future<void> pumpPage(
    WidgetTester tester,
    WeatherState state, {
    TemperatureUnit unit = TemperatureUnit.celsius,
    Locale locale = const Locale('en'),
  }) async {
    when(() => cubit.state).thenReturn(state);
    await tester.pumpApp(
      MultiBlocProvider(
        providers: [
          BlocProvider<WeatherCubit>.value(value: cubit),
          BlocProvider(create: (_) => PlacesCubit(FakePlacesRepository())),
          BlocProvider(create: (_) => SettingsCubit(FakeSettingsRepository())),
        ],
        child: const Scaffold(body: WeatherPage()),
      ),
      unit: unit,
      locale: locale,
    );
    await tester.pumpEntrances();
  }

  testWidgets('shows a skeleton while the first load runs', (tester) async {
    await pumpPage(tester, const WeatherState(status: WeatherStatus.loading));

    expect(find.byType(LoadingView), findsOneWidget);
  });

  testWidgets('shows the weather and forecasts for the place', (tester) async {
    await pumpPage(tester, showingData);

    expect(find.byType(WeatherContent), findsOneWidget);
    expect(find.text('Ahmedabad'), findsOneWidget);
    expect(find.text('33°'), findsOneWidget);
    expect(find.text(l10n.conditionClear), findsOneWidget);
    expect(find.byType(HourlyForecastCard), findsOneWidget);
    expect(find.byType(DailyForecastCard), findsOneWidget);
    expect(find.text(l10n.today), findsOneWidget);
    expect(find.byType(RefreshStatusBanner), findsNothing);
  });

  testWidgets('shows temperatures in Fahrenheit when chosen', (tester) async {
    await pumpPage(tester, showingData, unit: TemperatureUnit.fahrenheit);

    expect(find.text('91°'), findsOneWidget);
  });

  testWidgets('speaks the chosen language', (tester) async {
    await pumpPage(tester, showingData, locale: const Locale('hi'));

    expect(find.text('साफ़ आसमान'), findsOneWidget);
    expect(find.text('आज'), findsOneWidget);
  });

  testWidgets('keeps the weather on screen and explains when a refresh fails', (
    tester,
  ) async {
    await pumpPage(
      tester,
      showingData.copyWith(failure: const NoInternetFailure()),
    );

    expect(find.byType(WeatherContent), findsOneWidget);
    expect(find.byType(RefreshStatusBanner), findsOneWidget);
    expect(find.text(l10n.noInternetTitle), findsOneWidget);

    await tester.tap(find.text(l10n.tryAgain));
    verify(() => cubit.refresh()).called(1);
  });

  testWidgets('shows a full-screen error when there is nothing to fall back '
      'on', (tester) async {
    await pumpPage(
      tester,
      const WeatherState(
        status: WeatherStatus.failure,
        failure: TimeoutFailure(),
      ),
    );

    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text(l10n.timeoutTitle), findsOneWidget);

    await tester.tap(find.text(l10n.tryAgain));
    verify(() => cubit.refresh()).called(1);
  });

  testWidgets('names the location page before a fix and offers settings '
      'when access is blocked', (tester) async {
    when(() => cubit.place).thenReturn(const CurrentLocationPlace());
    await pumpPage(
      tester,
      const WeatherState(
        status: WeatherStatus.failure,
        failure: LocationFailure(LocationFailureReason.permissionDeniedForever),
      ),
    );

    expect(find.text(l10n.myLocation), findsOneWidget);
    await tester.tap(find.text(l10n.openSettings));
    verify(() => cubit.openLocationSettings()).called(1);
  });

  testWidgets('disables the refresh button while refreshing', (tester) async {
    await pumpPage(tester, showingData.copyWith(isRefreshing: true));

    final button = tester.widget<TactilePressable>(
      find.descendant(
        of: find.byTooltip(l10n.refreshing),
        matching: find.byType(TactilePressable),
      ),
    );
    expect(button.onPressed, isNull);
    expect(button.isActive, isTrue);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('pull-to-refresh asks the cubit to refresh', (tester) async {
    await pumpPage(tester, showingData);

    await tester.fling(
      find.byType(SingleChildScrollView).first,
      const Offset(0, 400),
      1000,
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    verify(() => cubit.refresh()).called(1);
  });
}
