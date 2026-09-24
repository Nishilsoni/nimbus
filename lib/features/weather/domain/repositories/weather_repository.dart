import 'package:nimbus/core/utils/result.dart';
import 'package:nimbus/features/weather/domain/entities/city.dart';
import 'package:nimbus/features/weather/domain/entities/place.dart';
import 'package:nimbus/features/weather/domain/entities/weather_report.dart';

/// What the presentation layer needs from the weather data, and nothing
/// about how it's obtained. Cubits depend on this interface, which keeps
/// them testable with a mock.
abstract interface class WeatherRepository {
  /// Fetches live weather and forecast for [city], and caches the result
  /// for its [Place].
  Future<Result<WeatherReport>> getWeather(City city);

  /// The last report fetched for [place], or `null`. Synchronous, so a page
  /// can show cached weather on its very first frame.
  WeatherReport? getCachedReport(Place place);

  /// Cities matching [query], named in [languageCode] where the provider
  /// has translations. Fails with `CityNotFoundFailure` when there are no
  /// matches.
  Future<Result<List<City>>> searchCities(
    String query, {
    String languageCode = 'en',
  });
}
