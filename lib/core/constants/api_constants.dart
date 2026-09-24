/// Endpoints and tuning values for the Open-Meteo APIs.
///
/// Open-Meteo needs no API key, so the app runs straight after `flutter run`.
abstract final class ApiConstants {
  static const forecastHost = 'api.open-meteo.com';
  static const forecastPath = '/v1/forecast';

  static const geocodingHost = 'geocoding-api.open-meteo.com';
  static const geocodingPath = '/v1/search';

  /// Fields requested from the forecast endpoint. Keep in sync with
  /// `WeatherModel.fromJson`.
  static const currentFields = [
    'temperature_2m',
    'apparent_temperature',
    'relative_humidity_2m',
    'weather_code',
    'wind_speed_10m',
    'precipitation',
    'surface_pressure',
    'is_day',
  ];

  static const hourlyFields = [
    'temperature_2m',
    'weather_code',
    'precipitation_probability',
    'is_day',
  ];

  static const dailyFields = [
    'weather_code',
    'temperature_2m_max',
    'temperature_2m_min',
    'precipitation_probability_max',
    'uv_index_max',
    'sunrise',
    'sunset',
  ];

  static const forecastDays = 7;

  /// The hourly forecast shows this many hours from now.
  static const hoursShown = 24;

  /// One more than [hoursShown]: the API's first slot can be the hour that
  /// has just started, which is dropped when parsing.
  static const forecastHours = hoursShown + 1;

  static const searchResultLimit = 8;

  /// Open-Meteo returns nothing for a single character, so don't ask.
  static const minSearchQueryLength = 2;

  static const requestTimeout = Duration(seconds: 10);
  static const locationTimeout = Duration(seconds: 15);
}
