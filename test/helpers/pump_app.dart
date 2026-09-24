import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus/core/l10n/l10n.dart';
import 'package:nimbus/core/theme/app_theme.dart';
import 'package:nimbus/core/theme/surface_palette.dart';
import 'package:nimbus/core/utils/temperature_unit.dart';
import 'package:nimbus/core/widgets/unit_scope.dart';

/// English strings, for finding widgets by their text.
final l10n = lookupAppLocalizations(const Locale('en'));

extension PumpApp on WidgetTester {
  /// Pumps [child] inside the app's theme, translations and unit scope.
  ///
  /// [wrap] puts providers above the whole app, as in production, so
  /// pushed routes and sheets can reach them too.
  Future<void> pumpApp(
    Widget child, {
    SurfacePalette? palette,
    TemperatureUnit unit = TemperatureUnit.celsius,
    Locale locale = const Locale('en'),
    Widget Function(Widget app)? wrap,
  }) {
    final app = MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.fromPalette(palette ?? SurfacePalette.light()),
      builder: (context, child) => UnitScope(unit: unit, child: child!),
      home: child,
    );
    return pumpWidget(wrap == null ? app : wrap(app));
  }

  /// The illustrations animate forever, so tests pump fixed times rather
  /// than waiting to settle: first to fire every staggered entrance's start
  /// timer, then to let the entrances and counting numbers finish.
  Future<void> pumpEntrances() async {
    await pump(const Duration(milliseconds: 700));
    await pump(const Duration(milliseconds: 1500));
  }
}
