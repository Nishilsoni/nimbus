import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus/features/weather/data/models/city_model.dart';
import 'package:nimbus/features/weather/data/models/weather_model.dart';
import 'package:nimbus/features/weather/data/models/weather_report_model.dart';
import 'package:nimbus/features/weather/domain/entities/weather_condition.dart';

import '../../../../fixtures/fixture_reader.dart';
import '../../../../helpers/test_data.dart';

void main() {
  group('WeatherModel', () {
    test('parses a real Open-Meteo forecast response', () {
      final weather = WeatherModel.fromJson(
        jsonFixture('forecast_response.json'),
      ).toEntity();

      expect(weather, TestData.weather);
      expect(weather.condition, WeatherCondition.clear);
      expect(weather.isDay, isFalse);
    });

    test('survives a toJson/fromJson round trip, as used by the cache', () {
      final original = WeatherModel.fromJson(
        jsonFixture('forecast_response.json'),
      );

      final restored = WeatherModel.fromJson(original.toJson());

      expect(restored.toEntity(), original.toEntity());
    });

    test('treats missing optional daily values as null', () {
      final json = jsonFixture('forecast_response.json');
      (json['daily'] as Map<String, dynamic>)
        ..['uv_index_max'] = [null]
        ..['sunrise'] = [null];

      final weather = WeatherModel.fromJson(json).toEntity();

      expect(weather.uvIndex, isNull);
      expect(weather.sunrise, isNull);
      expect(weather.sunset, isNotNull);
    });

    test('throws a FormatException naming the missing field', () {
      final json = jsonFixture('forecast_response.json');
      (json['current'] as Map<String, dynamic>).remove('temperature_2m');

      expect(
        () => WeatherModel.fromJson(json),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('temperature_2m'),
          ),
        ),
      );
    });
  });

  group('CityModel', () {
    test('parses a geocoding result', () {
      final results =
          jsonFixture('geocoding_response.json')['results'] as List<dynamic>;

      final city = CityModel.fromJson(
        results.first as Map<String, dynamic>,
      ).toEntity();

      expect(city, TestData.ahmedabad);
      expect(city.subtitle, 'Gujarat, India');
    });

    test('round-trips a GPS city through toJson/fromJson', () {
      final model = CityModel.fromEntity(TestData.currentLocation);

      expect(
        CityModel.fromJson(model.toJson()).toEntity(),
        TestData.currentLocation,
      );
    });
  });

  group('WeatherReportModel', () {
    test('round-trips city, weather and timestamp', () {
      final model = WeatherReportModel(
        city: CityModel.fromEntity(TestData.london),
        weather: WeatherModel.fromJson(jsonFixture('forecast_response.json')),
        fetchedAt: TestData.fetchedAt,
      );

      expect(
        WeatherReportModel.fromJson(model.toJson()).toEntity(),
        TestData.report(city: TestData.london),
      );
    });
  });
}
