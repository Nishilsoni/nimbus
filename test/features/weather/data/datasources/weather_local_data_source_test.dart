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

  WeatherReportModel reportFor(CityModel city) => WeatherReportModel(
    city: city,
    weather: WeatherModel.fromJson(jsonFixture('forecast_response.json')),
    fetchedAt: TestData.fetchedAt,
  );

  test('returns null when nothing has been cached', () async {
    final dataSource = await createDataSource();

    expect(dataSource.readReport('city-1'), isNull);
  });

  test('keeps a separate report for each place', () async {
    final dataSource = await createDataSource();
    final ahmedabad = reportFor(CityModel.fromEntity(TestData.ahmedabad));
    final london = reportFor(CityModel.fromEntity(TestData.london));

    await dataSource.saveReport('ahmedabad', ahmedabad);
    await dataSource.saveReport('london', london);

    expect(dataSource.readReport('ahmedabad')?.city.name, 'Ahmedabad');
    expect(dataSource.readReport('london')?.city.name, 'London');
  });

  test('discards a corrupt entry instead of crashing', () async {
    final dataSource = await createDataSource({
      WeatherLocalDataSource.keyFor('broken'): '{"city": "not an object"',
    });

    expect(dataSource.readReport('broken'), isNull);
    await pumpEventQueue();
    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.containsKey(WeatherLocalDataSource.keyFor('broken')),
      isFalse,
    );
  });
}
