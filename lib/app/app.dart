import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nimbus/app/dependencies.dart';
import 'package:nimbus/core/constants/app_strings.dart';
import 'package:nimbus/core/theme/app_theme.dart';
import 'package:nimbus/features/splash/presentation/splash_screen.dart';
import 'package:nimbus/features/weather/domain/repositories/location_repository.dart';
import 'package:nimbus/features/weather/domain/repositories/weather_repository.dart';
import 'package:nimbus/features/weather/presentation/cubit/weather_cubit.dart';

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
      ],
      child: BlocProvider(
        // Created above the navigator so every route shares one weather
        // state. Loading starts immediately, while the splash animates.
        create: (context) => WeatherCubit(
          weatherRepository: context.read<WeatherRepository>(),
          locationRepository: context.read<LocationRepository>(),
        )..loadInitialWeather(),
        lazy: false,
        child: MaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
