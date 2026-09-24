import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nimbus/app/app.dart';
import 'package:nimbus/app/dependencies.dart';
import 'package:nimbus/core/network/network_info.dart';
import 'package:nimbus/features/settings/data/settings_repository_impl.dart';
import 'package:nimbus/features/settings/domain/app_settings.dart';
import 'package:nimbus/features/weather/presentation/widgets/empty_view.dart';
import 'package:nimbus/features/weather/presentation/widgets/refresh_status_banner.dart';
import 'package:nimbus/features/weather/presentation/widgets/weather_content.dart';
import 'package:nimbus/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lets the test switch the app "offline" without touching the device's
/// real network.
class _SwitchableNetworkInfo implements NetworkInfo {
  bool online = true;

  @override
  Future<bool> get isConnected async => online;
}

/// Drives the real app against the live Open-Meteo API, end to end.
///
/// Run with `flutter drive` (see README) to also save the screenshots used
/// in the README; with `flutter test integration_test` it runs as a plain
/// end-to-end test.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> screenshot(String name) async {
    try {
      await binding.takeScreenshot(name);
    } on Object {
      // Screenshots need the flutter drive host; `flutter test` has none.
    }
  }

  /// Pumps frames for [duration] of real time. `pumpAndSettle` would never
  /// return because the weather illustration animates forever.
  Future<void> pumpFor(WidgetTester tester, Duration duration) async {
    final end = DateTime.now().add(duration);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> pumpUntil(
    WidgetTester tester,
    Finder finder, {
    bool present = true,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final end = DateTime.now().add(timeout);
    while (finder.evaluate().isNotEmpty != present) {
      if (DateTime.now().isAfter(end)) {
        fail('Timed out waiting for $finder (present: $present)');
      }
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('search, refresh failure, recovery and GPS', (tester) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    // Start in light mode so the screenshots don't depend on the time of
    // day; the dark look is captured at the end.
    await preferences.setString(
      SettingsRepositoryImpl.appearanceKey,
      AppearanceMode.light.name,
    );
    final network = _SwitchableNetworkInfo();
    final dependencies = await AppDependencies.create(networkInfo: network);

    await tester.pumpWidget(NimbusApp(dependencies: dependencies));
    final l10n = AppLocalizations.of(tester.element(find.byType(NimbusApp)));
    await pumpFor(tester, const Duration(milliseconds: 2000));
    await screenshot('01_splash');

    // First launch: nothing cached, so the welcome view is shown.
    await pumpUntil(tester, find.byType(EmptyView));
    await pumpFor(tester, const Duration(seconds: 1));
    await screenshot('02_welcome');

    // An invalid city gets a clear "not found" message.
    await tester.tap(find.byTooltip(l10n.searchCity));
    await pumpFor(tester, const Duration(milliseconds: 600));
    await tester.enterText(find.byType(TextField), 'Qwzxvbn');
    await pumpUntil(tester, find.text(l10n.cityNotFoundTitle));
    await pumpFor(tester, const Duration(milliseconds: 500));
    await screenshot('03_city_not_found');

    // A real city shows suggestions.
    await tester.enterText(find.byType(TextField), 'London');
    final londonResult = find.text('England, United Kingdom');
    await pumpUntil(tester, londonResult);
    await pumpFor(tester, const Duration(milliseconds: 500));
    await screenshot('04_search_results');

    await tester.tap(londonResult.first);
    await pumpUntil(tester, find.byType(WeatherContent));
    await pumpFor(tester, const Duration(seconds: 1));
    await screenshot('05_weather');

    // Refreshing offline keeps the weather on screen and explains why.
    network.online = false;
    await tester.tap(find.byTooltip(l10n.refresh));
    await pumpUntil(tester, find.byType(RefreshStatusBanner));
    await pumpFor(tester, const Duration(milliseconds: 600));
    expect(find.byType(WeatherContent), findsOneWidget);
    expect(find.text(l10n.noInternetTitle), findsOneWidget);
    await screenshot('06_refresh_failed');

    // Back online, "Try again" recovers and the banner goes away.
    network.online = true;
    await tester.tap(find.text(l10n.tryAgain));
    await pumpUntil(tester, find.byType(RefreshStatusBanner), present: false);
    expect(find.byType(WeatherContent), findsOneWidget);

    // Scroll to the measurements.
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -420),
    );
    await pumpFor(tester, const Duration(seconds: 1));
    await screenshot('07_details');

    // GPS: the simulator's location permission is granted by the run
    // script, so this resolves without a system prompt.
    await tester.tap(find.byTooltip(l10n.useMyLocation));
    await pumpUntil(tester, find.byIcon(Icons.near_me_rounded));
    await pumpFor(tester, const Duration(seconds: 1));
    await screenshot('08_current_location');

    // The appearance toggle switches the whole app to the dark look.
    await tester.tap(find.byTooltip(l10n.settings));
    await tester.tap(find.text(l10n.themeLight));
    await pumpUntil(tester, find.text(l10n.themeDark));
    await pumpFor(tester, const Duration(milliseconds: 1500));
    await screenshot('09_dark_mode');
  });

  // Runs after the walkthrough, whose last successful fetch is now cached
  // and whose dark appearance choice is remembered.
  testWidgets('opening the app offline shows the cached weather', (
    tester,
  ) async {
    final network = _SwitchableNetworkInfo()..online = false;
    final dependencies = await AppDependencies.create(networkInfo: network);

    await tester.pumpWidget(NimbusApp(dependencies: dependencies));
    final l10n = AppLocalizations.of(tester.element(find.byType(NimbusApp)));
    await pumpUntil(tester, find.byType(RefreshStatusBanner));
    await pumpFor(tester, const Duration(seconds: 1));

    expect(find.byType(WeatherContent), findsOneWidget);
    expect(find.byIcon(Icons.near_me_rounded), findsOneWidget);
    expect(find.text(l10n.noInternetTitle), findsOneWidget);
    await screenshot('10_offline_cached');
  });
}
