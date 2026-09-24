import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nimbus/app/dependencies.dart';
import 'package:nimbus/core/constants/app_strings.dart';
import 'package:nimbus/core/theme/app_theme.dart';
import 'package:nimbus/core/theme/surface_palette.dart';
import 'package:nimbus/features/appearance/domain/appearance_repository.dart';
import 'package:nimbus/features/appearance/presentation/appearance_cubit.dart';
import 'package:nimbus/features/splash/presentation/splash_screen.dart';
import 'package:nimbus/features/weather/domain/entities/weather_condition.dart';
import 'package:nimbus/features/weather/domain/repositories/location_repository.dart';
import 'package:nimbus/features/weather/domain/repositories/weather_repository.dart';
import 'package:nimbus/features/weather/presentation/cubit/weather_cubit.dart';
import 'package:nimbus/features/weather/presentation/cubit/weather_state.dart';
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
        RepositoryProvider<AppearanceRepository>.value(
          value: dependencies.appearanceRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // Created above the navigator so every route shares one weather
          // state. Loading starts immediately, while the splash animates.
          BlocProvider(
            create: (context) => WeatherCubit(
              weatherRepository: context.read<WeatherRepository>(),
              locationRepository: context.read<LocationRepository>(),
            )..loadInitialWeather(),
            lazy: false,
          ),
          BlocProvider(
            create: (context) =>
                AppearanceCubit(context.read<AppearanceRepository>()),
          ),
        ],
        child: const _ThemedApp(),
      ),
    );
  }
}

/// Picks the look: the appearance setting decides light or dark (in
/// automatic mode, day or night at the city on screen), and the weather
/// condition picks the accent.
///
/// MaterialApp animates between themes, so any change, a new city, a
/// sunset, or the user switching mode, glides the whole app (surfaces,
/// shadows and text) to the new palette.
class _ThemedApp extends StatelessWidget {
  const _ThemedApp();

  @override
  Widget build(BuildContext context) {
    final appearance = context.watch<AppearanceCubit>().state;

    return BlocSelector<
      WeatherCubit,
      WeatherState,
      ({WeatherCondition? condition, bool? isDay})
    >(
      selector: (state) => (
        condition: state.report?.weather.condition,
        isDay: state.report?.weather.isDay,
      ),
      builder: (context, look) {
        final condition = look.condition;
        Color accent({required bool isDark}) => condition == null
            ? brandAccent(isDark: isDark)
            : condition.accent(isDark: isDark);

        return MaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.fromPalette(
            SurfacePalette.light(accent: accent(isDark: false)),
          ),
          darkTheme: AppTheme.fromPalette(
            SurfacePalette.dark(accent: accent(isDark: true)),
          ),
          themeMode: appearance.toThemeMode(isDay: look.isDay),
          themeAnimationDuration: const Duration(milliseconds: 900),
          themeAnimationCurve: Curves.easeInOutCubic,
          home: const SplashScreen(),
        );
      },
    );
  }
}
