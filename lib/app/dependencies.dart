import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:nimbus/core/network/api_client.dart';
import 'package:nimbus/core/network/network_info.dart';
import 'package:nimbus/features/settings/data/settings_repository_impl.dart';
import 'package:nimbus/features/settings/domain/settings_repository.dart';
import 'package:nimbus/features/weather/data/datasources/device_location_data_source.dart';
import 'package:nimbus/features/weather/data/datasources/geocoding_remote_data_source.dart';
import 'package:nimbus/features/weather/data/datasources/weather_local_data_source.dart';
import 'package:nimbus/features/weather/data/datasources/weather_remote_data_source.dart';
import 'package:nimbus/features/weather/data/repositories/location_repository_impl.dart';
import 'package:nimbus/features/weather/data/repositories/places_repository_impl.dart';
import 'package:nimbus/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:nimbus/features/weather/domain/repositories/location_repository.dart';
import 'package:nimbus/features/weather/domain/repositories/places_repository.dart';
import 'package:nimbus/features/weather/domain/repositories/weather_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The composition root: the one place that knows which concrete classes
/// implement each interface.
///
/// Plain constructor injection is enough for an app this size and keeps the
/// wiring readable top to bottom. Tests build their own graph with fakes.
class AppDependencies {
  const AppDependencies({
    required this.weatherRepository,
    required this.locationRepository,
    required this.placesRepository,
    required this.settingsRepository,
  });

  final WeatherRepository weatherRepository;
  final LocationRepository locationRepository;
  final PlacesRepository placesRepository;
  final SettingsRepository settingsRepository;

  static Future<AppDependencies> create({NetworkInfo? networkInfo}) async {
    final preferences = await SharedPreferences.getInstance();
    final apiClient = ApiClient(
      httpClient: http.Client(),
      networkInfo: networkInfo ?? ConnectivityNetworkInfo(Connectivity()),
    );

    return AppDependencies(
      weatherRepository: WeatherRepositoryImpl(
        weatherRemote: WeatherRemoteDataSource(apiClient),
        geocodingRemote: GeocodingRemoteDataSource(apiClient),
        local: WeatherLocalDataSource(preferences),
      ),
      locationRepository: LocationRepositoryImpl(DeviceLocationDataSource()),
      placesRepository: PlacesRepositoryImpl(preferences),
      settingsRepository: SettingsRepositoryImpl(preferences),
    );
  }
}
