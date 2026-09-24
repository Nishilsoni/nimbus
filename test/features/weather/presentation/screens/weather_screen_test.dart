import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nimbus/core/constants/app_strings.dart';
import 'package:nimbus/core/error/failures.dart';
import 'package:nimbus/features/weather/presentation/cubit/weather_cubit.dart';
import 'package:nimbus/features/weather/presentation/cubit/weather_state.dart';
import 'package:nimbus/features/weather/presentation/screens/weather_screen.dart';
import 'package:nimbus/features/weather/presentation/widgets/empty_view.dart';
import 'package:nimbus/features/weather/presentation/widgets/error_view.dart';
import 'package:nimbus/features/weather/presentation/widgets/loading_view.dart';
import 'package:nimbus/features/weather/presentation/widgets/refresh_status_banner.dart';
import 'package:nimbus/features/weather/presentation/widgets/weather_content.dart';

import '../../../../helpers/test_data.dart';

class _MockWeatherCubit extends MockCubit<WeatherState>
    implements WeatherCubit {}

void main() {
  late _MockWeatherCubit cubit;

  final showingData = WeatherState(
    status: WeatherStatus.success,
    report: TestData.report(),
  );

  setUp(() {
    cubit = _MockWeatherCubit();
    when(() => cubit.refresh()).thenAnswer((_) async {});
    when(() => cubit.useCurrentLocation()).thenAnswer((_) async {});
  });

  Future<void> pumpScreen(WidgetTester tester, WeatherState state) async {
    when(() => cubit.state).thenReturn(state);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<WeatherCubit>.value(
          value: cubit,
          child: const WeatherScreen(),
        ),
      ),
    );
    // The illustration animates forever, so pump a fixed time rather than
    // waiting to settle.
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('shows the welcome view before any city is chosen', (
    tester,
  ) async {
    await pumpScreen(tester, const WeatherState());

    expect(find.byType(EmptyView), findsOneWidget);
    expect(find.byTooltip(AppStrings.refresh), findsNothing);
  });

  testWidgets('shows a skeleton while the first load runs', (tester) async {
    await pumpScreen(tester, const WeatherState(status: WeatherStatus.loading));

    expect(find.byType(LoadingView), findsOneWidget);
  });

  testWidgets('shows the weather for the selected city', (tester) async {
    await pumpScreen(tester, showingData);

    expect(find.byType(WeatherContent), findsOneWidget);
    expect(find.text('Ahmedabad'), findsOneWidget);
    expect(find.text('33°'), findsOneWidget);
    expect(find.text(AppStrings.conditionClear), findsOneWidget);
    expect(find.byType(RefreshStatusBanner), findsNothing);
  });

  testWidgets('keeps the weather on screen and explains when a refresh fails', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      showingData.copyWith(failure: const NoInternetFailure()),
    );

    expect(find.byType(WeatherContent), findsOneWidget);
    expect(find.byType(RefreshStatusBanner), findsOneWidget);
    expect(find.text(AppStrings.noInternetTitle), findsOneWidget);

    await tester.tap(find.text(AppStrings.tryAgain));
    verify(() => cubit.refresh()).called(1);
  });

  testWidgets('shows a full-screen error when there is nothing to fall back '
      'on', (tester) async {
    await pumpScreen(
      tester,
      const WeatherState(
        status: WeatherStatus.failure,
        failure: TimeoutFailure(),
      ),
    );

    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text(AppStrings.timeoutTitle), findsOneWidget);

    await tester.tap(find.text(AppStrings.tryAgain));
    verify(() => cubit.refresh()).called(1);
  });

  testWidgets('offers to retry the location when permission was denied', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const WeatherState(
        status: WeatherStatus.failure,
        failure: LocationFailure(LocationFailureReason.permissionDenied),
      ),
    );

    await tester.tap(find.text(AppStrings.tryAgain));
    verify(() => cubit.useCurrentLocation()).called(1);
  });

  testWidgets('disables the refresh button while refreshing', (tester) async {
    await pumpScreen(tester, showingData.copyWith(isRefreshing: true));

    final button = tester.widget<IconButton>(
      find.ancestor(
        of: find.byType(CircularProgressIndicator),
        matching: find.byType(IconButton),
      ),
    );
    expect(button.onPressed, isNull);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('pull-to-refresh asks the cubit to refresh', (tester) async {
    await pumpScreen(tester, showingData);

    await tester.fling(
      find.byType(SingleChildScrollView),
      const Offset(0, 400),
      1000,
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    verify(() => cubit.refresh()).called(1);
  });
}
