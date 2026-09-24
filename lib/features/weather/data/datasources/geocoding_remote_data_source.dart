import 'package:nimbus/core/constants/api_constants.dart';
import 'package:nimbus/core/error/exceptions.dart';
import 'package:nimbus/core/network/api_client.dart';
import 'package:nimbus/features/weather/data/models/city_model.dart';

class GeocodingRemoteDataSource {
  const GeocodingRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  /// Returns an empty list when nothing matches. Throws an [AppException]
  /// on any failure.
  Future<List<CityModel>> searchCities(
    String query, {
    String languageCode = 'en',
  }) async {
    final uri =
        Uri.https(ApiConstants.geocodingHost, ApiConstants.geocodingPath, {
          'name': query,
          'count': '${ApiConstants.searchResultLimit}',
          'language': languageCode,
          'format': 'json',
        });

    final json = await _apiClient.getJson(uri);
    // Open-Meteo omits "results" entirely when there are no matches.
    final results = json['results'] ?? const <dynamic>[];
    try {
      if (results is! List<dynamic>) {
        throw const FormatException('Expected "results" to be a list');
      }
      return results.map(_parseCity).toList(growable: false);
    } on FormatException catch (error) {
      throw ParsingException(error);
    }
  }

  CityModel _parseCity(dynamic item) {
    if (item is! Map<String, dynamic>) {
      throw const FormatException('Expected each result to be an object');
    }
    return CityModel.fromJson(item);
  }
}
