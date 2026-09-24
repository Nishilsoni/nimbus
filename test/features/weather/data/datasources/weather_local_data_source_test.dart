import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus/features/weather/data/datasources/weather_local_data_source.dart';
import 'package:nimbus/features/weather/data/models/city_model.dart';
import 'package:nimbus/features/weather/data/models/weather_model.dart';
import 'package:nimbus/features/weather/data/models/weather_report_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';
import '../../../../helpers/test_data.dart';

void main() {
  Future<WeatherLocalDataSource> createDataSource([
    Map<String, Object> initialValues = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(initialValues);
    return WeatherLocalDataSource(await SharedPreferences.getInstance());
  }

  test('returns null when nothing has been cached', () async {
    final dataSource = await createDataSource();

    expect(await dataSource.readLastReport(), isNull);
  });

  test('reads back the report it saved', () async {
    final dataSource = await createDataSource();
    final report = WeatherReportModel(
      city: CityModel.fromEntity(TestData.ahmedabad),
      weather: WeatherModel.fromJson(jsonFixture('forecast_response.json')),
      fetchedAt: TestData.fetchedAt,
    );

    await dataSource.saveReport(report);
    final restored = await dataSource.readLastReport();

    expect(restored?.toEntity(), TestData.report());
  });

  test('discards a corrupt entry instead of crashing', () async {
    final dataSource = await createDataSource({
      WeatherLocalDataSource.lastReportKey: '{"city": "not an object"',
    });

    expect(await dataSource.readLastReport(), isNull);
    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.containsKey(WeatherLocalDataSource.lastReportKey),
      isFalse,
    );
  });
}
