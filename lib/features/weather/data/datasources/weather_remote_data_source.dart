import 'package:nimbus/core/constants/api_constants.dart';
import 'package:nimbus/core/error/exceptions.dart';
import 'package:nimbus/core/network/api_client.dart';
import 'package:nimbus/features/weather/data/models/weather_model.dart';

class WeatherRemoteDataSource {
  const WeatherRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  /// Throws an [AppException] on any failure.
  Future<WeatherModel> fetchWeather({
    required double latitude,
    required double longitude,
  }) async {
    final uri =
        Uri.https(ApiConstants.forecastHost, ApiConstants.forecastPath, {
          'latitude': '$latitude',
          'longitude': '$longitude',
          'current': ApiConstants.currentFields.join(','),
          'hourly': ApiConstants.hourlyFields.join(','),
          'daily': ApiConstants.dailyFields.join(','),
          'timezone': 'auto',
          'forecast_days': '${ApiConstants.forecastDays}',
          'forecast_hours': '${ApiConstants.forecastHours}',
        });

    final json = await _apiClient.getJson(uri);
    try {
      return WeatherModel.fromJson(json);
    } on FormatException catch (error) {
      throw ParsingException(error);
    }
  }
}
