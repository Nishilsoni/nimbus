import 'package:nimbus/core/utils/result.dart';
import 'package:nimbus/features/weather/domain/entities/city.dart';
import 'package:nimbus/features/weather/domain/entities/weather_report.dart';

/// What the presentation layer needs from the weather data, and nothing
/// about how it's obtained. Cubits depend on this interface, which keeps
/// them testable with a mock.
abstract interface class WeatherRepository {
  /// Fetches live weather for [city] and caches it on success.
  Future<Result<WeatherReport>> getWeather(City city);

  /// The last report that was fetched successfully, or `null` if none has
  /// been saved yet.
  Future<WeatherReport?> getLastReport();

  /// Cities matching [query]. Fails with `CityNotFoundFailure` when there
  /// are no matches.
  Future<Result<List<City>>> searchCities(String query);
}
