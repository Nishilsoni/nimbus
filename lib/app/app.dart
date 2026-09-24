import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nimbus/app/dependencies.dart';
import 'package:nimbus/core/l10n/l10n.dart';
import 'package:nimbus/core/theme/app_theme.dart';
import 'package:nimbus/core/theme/surface_palette.dart';
import 'package:nimbus/core/widgets/unit_scope.dart';
import 'package:nimbus/features/settings/domain/settings_repository.dart';
import 'package:nimbus/features/settings/presentation/settings_cubit.dart';
import 'package:nimbus/features/splash/presentation/splash_screen.dart';
import 'package:nimbus/features/weather/domain/repositories/location_repository.dart';
import 'package:nimbus/features/weather/domain/repositories/places_repository.dart';
import 'package:nimbus/features/weather/domain/repositories/weather_repository.dart';
import 'package:nimbus/features/weather/presentation/cubit/places_cubit.dart';
import 'package:nimbus/features/weather/presentation/cubit/weather_look_cubit.dart';
import 'package:nimbus/features/weather/presentation/utils/condition_visuals.dart';

class NimbusApp extends StatelessWidget {
  const NimbusApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<WeatherRepository>.value(
          value: dependencies.weatherRepository,
        ),
        RepositoryProvider<LocationRepository>.value(
          value: dependencies.locationRepository,
        ),
        RepositoryProvider<PlacesRepository>.value(
          value: dependencies.placesRepository,
        ),
        RepositoryProvider<SettingsRepository>.value(
          value: dependencies.settingsRepository,
        ),
      ],
      // Above the navigator, so every route shares the same places,
      // settings and look.
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => PlacesCubit(context.read<PlacesRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                SettingsCubit(context.read<SettingsRepository>()),
          ),
          BlocProvider(create: (_) => WeatherLookCubit()),
        ],
        child: const _ThemedApp(),
      ),
    );
  }
}

/// Turns the settings and the weather on screen into the app's look and
/// language: the appearance setting decides light or dark (in automatic
/// mode, day or night at the city on screen), the weather condition picks
/// the accent, and the language setting picks the translations.
///
/// MaterialApp animates between themes, so a new city, a sunset, a swipe
/// to another place or a new setting glides the whole app, surfaces,
/// shadows and text, to the new palette.
class _ThemedApp extends StatelessWidget {
  const _ThemedApp();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final look = context.watch<WeatherLookCubit>().state;
    final condition = look.condition;
    Color accent({required bool isDark}) => condition == null
        ? brandAccent(isDark: isDark)
        : condition.accent(isDark: isDark);
    final languageCode = settings.languageCode;

    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appName,
      debugShowCheckedModeBanner: false,
      locale: languageCode == null ? null : Locale(languageCode),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.fromPalette(
        SurfacePalette.light(accent: accent(isDark: false)),
      ),
      darkTheme: AppTheme.fromPalette(
        SurfacePalette.dark(accent: accent(isDark: true)),
      ),
      themeMode: settings.appearance.toThemeMode(isDay: look.isDay),
      themeAnimationDuration: const Duration(milliseconds: 900),
      themeAnimationCurve: Curves.easeInOutCubic,
      builder: (context, child) =>
          UnitScope(unit: settings.temperatureUnit, child: child!),
      home: const SplashScreen(),
    );
  }
}
