import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nimbus/features/settings/domain/app_settings.dart';
import 'package:nimbus/features/settings/domain/settings_repository.dart';
import 'package:nimbus/features/weather/domain/entities/saved_places.dart';
import 'package:nimbus/features/weather/domain/repositories/location_repository.dart';
import 'package:nimbus/features/weather/domain/repositories/places_repository.dart';
import 'package:nimbus/features/weather/domain/repositories/weather_repository.dart';
import 'package:nimbus/features/weather/presentation/cubit/weather_cubit.dart';
import 'package:nimbus/features/weather/presentation/cubit/weather_state.dart';

class MockWeatherCubit extends MockCubit<WeatherState>
    implements WeatherCubit {}

class MockWeatherRepository extends Mock implements WeatherRepository {}

class MockLocationRepository extends Mock implements LocationRepository {}

class FakePlacesRepository implements PlacesRepository {
  FakePlacesRepository([this.saved = const SavedPlaces()]);

  SavedPlaces saved;

  @override
  SavedPlaces load() => saved;

  @override
  Future<void> save(SavedPlaces places) async => saved = places;
}

class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository([this.saved = const AppSettings()]);

  AppSettings saved;

  @override
  AppSettings load() => saved;

  @override
  Future<void> save(AppSettings settings) async => saved = settings;
}
