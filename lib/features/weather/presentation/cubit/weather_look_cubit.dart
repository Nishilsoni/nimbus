import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nimbus/features/weather/domain/entities/weather.dart';
import 'package:nimbus/features/weather/domain/entities/weather_condition.dart';

/// What the app's theme needs to know about the weather on screen.
typedef WeatherLook = ({WeatherCondition? condition, bool? isDay});

/// The weather of whichever page is showing. The app root turns it into
/// the theme (accent colour, and day or night in automatic mode), so every
/// screen, including the search screen, matches the page behind it.
class WeatherLookCubit extends Cubit<WeatherLook> {
  WeatherLookCubit() : super((condition: null, isDay: null));

  /// [weather] is `null` while the page on screen has no data yet.
  void show(Weather? weather) =>
      emit((condition: weather?.condition, isDay: weather?.isDay));
}
