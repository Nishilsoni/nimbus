import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus/features/weather/data/models/city_model.dart';
import 'package:nimbus/features/weather/data/models/weather_model.dart';
import 'package:nimbus/features/weather/data/models/weather_report_model.dart';
import 'package:nimbus/features/weather/domain/entities/weather_condition.dart';

import '../../../../fixtures/fixture_reader.dart';
import '../../../../helpers/test_data.dart';

void main() {
  group('WeatherModel', () {
    final weather = WeatherModel.fromJson(
      jsonFixture('forecast_response.json'),
    ).toEntity();

    test('parses current conditions from a real response', () {
      expect(weather.temperature, 30.2);
      expect(weather.feelsLike, 34.8);
      expect(weather.humidity, 71);
      expect(weather.condition, WeatherCondition.clear);
      expect(weather.isDay, isFalse);
      expect(weather.observedAt, DateTime(2026, 9, 24, 23));
    });

    test("takes today's range, UV and sun times from the first day", () {
      expect(weather.highTemperature, 36.7);
      expect(weather.lowTemperature, 27.4);
      expect(weather.uvIndex, 7.4);
      expect(weather.sunrise, DateTime(2026, 9, 24, 6, 28));
      expect(weather.sunset, DateTime(2026, 9, 24, 18, 34));
    });

    test('keeps exactly 24 hours, starting at the current hour', () {
      // The fixture's first slot (22:00) is before "now" (23:00).
      expect(weather.hourly, hasLength(24));
      expect(weather.hourly.first.time, DateTime(2026, 9, 24, 23));
      expect(weather.hourly.first.temperature, 29.9);
      expect(weather.hourly.last.time, DateTime(2026, 9, 25, 22));
    });

    test('parses seven days of forecast', () {
      expect(weather.daily, hasLength(7));
      expect(weather.daily[2].condition, WeatherCondition.drizzle);
      expect(weather.daily[5].precipitationChance, 12);
      expect(weather.daily[1].high, 35.2);
    });

    test('survives a toJson/fromJson round trip, as used by the cache', () {
      final original = WeatherModel.fromJson(
        jsonFixture('forecast_response.json'),
      );

      final restored = WeatherModel.fromJson(original.toJson());

      expect(restored.toEntity(), original.toEntity());
    });

    test('treats missing optional values as null', () {
      final json = jsonFixture('forecast_response.json');
      final daily = json['daily'] as Map<String, dynamic>;
      (daily['uv_index_max'] as List<dynamic>)[0] = null;
      (daily['sunrise'] as List<dynamic>)[0] = null;

      final parsed = WeatherModel.fromJson(json).toEntity();

      expect(parsed.uvIndex, isNull);
      expect(parsed.sunrise, isNull);
      expect(parsed.sunset, isNotNull);
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

    test('rejects forecast columns of different lengths', () {
      final json = jsonFixture('forecast_response.json');
      ((json['hourly'] as Map<String, dynamic>)['temperature_2m']
              as List<dynamic>)
          .removeLast();

      expect(() => WeatherModel.fromJson(json), throwsFormatException);
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
      final weather = WeatherModel.fromJson(
        jsonFixture('forecast_response.json'),
      );
      final model = WeatherReportModel(
        city: CityModel.fromEntity(TestData.london),
        weather: weather,
        fetchedAt: TestData.fetchedAt,
      );

      final restored = WeatherReportModel.fromJson(model.toJson()).toEntity();

      expect(restored.city, TestData.london);
      expect(restored.fetchedAt, TestData.fetchedAt);
      expect(restored.weather, weather.toEntity());
    });
  });
}
