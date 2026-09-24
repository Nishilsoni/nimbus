import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nimbus/core/error/exceptions.dart';
import 'package:nimbus/core/error/failures.dart';
import 'package:nimbus/core/utils/result.dart';
import 'package:nimbus/features/weather/data/datasources/geocoding_remote_data_source.dart';
import 'package:nimbus/features/weather/data/datasources/weather_local_data_source.dart';
import 'package:nimbus/features/weather/data/datasources/weather_remote_data_source.dart';
import 'package:nimbus/features/weather/data/models/city_model.dart';
import 'package:nimbus/features/weather/data/models/weather_model.dart';
import 'package:nimbus/features/weather/data/models/weather_report_model.dart';
import 'package:nimbus/features/weather/data/repositories/weather_repository_impl.dart';

import '../../../../fixtures/fixture_reader.dart';
import '../../../../helpers/test_data.dart';

class _MockWeatherRemote extends Mock implements WeatherRemoteDataSource {}

class _MockGeocodingRemote extends Mock implements GeocodingRemoteDataSource {}

class _MockLocal extends Mock implements WeatherLocalDataSource {}

void main() {
  late _MockWeatherRemote weatherRemote;
  late _MockGeocodingRemote geocodingRemote;
  late _MockLocal local;
  late WeatherRepositoryImpl repository;

  final weatherModel = WeatherModel.fromJson(
    jsonFixture('forecast_response.json'),
  );

  setUpAll(() {
    registerFallbackValue(
      WeatherReportModel(
        city: CityModel.fromEntity(TestData.ahmedabad),
        weather: weatherModel,
        fetchedAt: TestData.fetchedAt,
      ),
    );
  });

  setUp(() {
    weatherRemote = _MockWeatherRemote();
    geocodingRemote = _MockGeocodingRemote();
    local = _MockLocal();
    repository = WeatherRepositoryImpl(
      weatherRemote: weatherRemote,
      geocodingRemote: geocodingRemote,
      local: local,
      clock: () => TestData.fetchedAt,
    );
    when(() => local.saveReport(any())).thenAnswer((_) async {});
  });

  void stubWeather(Future<WeatherModel> Function() answer) {
    when(
      () => weatherRemote.fetchWeather(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
      ),
    ).thenAnswer((_) => answer());
  }

  group('getWeather', () {
    test('returns a report stamped with the fetch time', () async {
      stubWeather(() async => weatherModel);

      final result = await repository.getWeather(TestData.ahmedabad);

      expect(result, isA<Ok<Object>>());
      expect((result as Ok).value, TestData.report());
    });

    test('caches the report after a successful fetch', () async {
      stubWeather(() async => weatherModel);

      await repository.getWeather(TestData.ahmedabad);

      final saved =
          verify(() => local.saveReport(captureAny())).captured.single
              as WeatherReportModel;
      expect(saved.toEntity(), TestData.report());
    });

    test('still succeeds when writing the cache fails', () async {
      stubWeather(() async => weatherModel);
      when(() => local.saveReport(any())).thenThrow(Exception('disk full'));

      final result = await repository.getWeather(TestData.ahmedabad);

      expect(result, isA<Ok<Object>>());
    });

    final failureCases = <AppException, Failure>{
      const NoInternetException(): const NoInternetFailure(),
      const RequestTimeoutException(): const TimeoutFailure(),
      const RateLimitException(): const RateLimitFailure(),
      const ServerException(500): const ServerFailure(statusCode: 500),
      const ParsingException('bad'): const UnknownFailure(),
    };

    failureCases.forEach((exception, failure) {
      test(
        'turns ${exception.runtimeType} into ${failure.runtimeType}',
        () async {
          stubWeather(() async => throw exception);

          final result = await repository.getWeather(TestData.ahmedabad);

          expect((result as Err).failure, failure);
          verifyNever(() => local.saveReport(any()));
        },
      );
    });

    test('turns an unexpected exception into UnknownFailure', () async {
      stubWeather(() async => throw Exception('boom'));

      final result = await repository.getWeather(TestData.ahmedabad);

      expect((result as Err).failure, const UnknownFailure());
    });
  });

  group('getLastReport', () {
    test('returns the cached report as an entity', () async {
      when(() => local.readLastReport()).thenAnswer(
        (_) async => WeatherReportModel(
          city: CityModel.fromEntity(TestData.ahmedabad),
          weather: weatherModel,
          fetchedAt: TestData.fetchedAt,
        ),
      );

      expect(await repository.getLastReport(), TestData.report());
    });

    test('returns null when nothing is cached', () async {
      when(() => local.readLastReport()).thenAnswer((_) async => null);

      expect(await repository.getLastReport(), isNull);
    });
  });

  group('searchCities', () {
    test('returns matching cities', () async {
      when(
        () => geocodingRemote.searchCities('Ahmedabad'),
      ).thenAnswer((_) async => [CityModel.fromEntity(TestData.ahmedabad)]);

      final result = await repository.searchCities('Ahmedabad');

      expect((result as Ok).value, [TestData.ahmedabad]);
    });

    test('fails with CityNotFoundFailure when nothing matches', () async {
      when(
        () => geocodingRemote.searchCities('Qwzx'),
      ).thenAnswer((_) async => []);

      final result = await repository.searchCities('Qwzx');

      expect((result as Err).failure, const CityNotFoundFailure('Qwzx'));
    });

    test('maps network problems to failures', () async {
      when(
        () => geocodingRemote.searchCities(any()),
      ).thenThrow(const NoInternetException());

      final result = await repository.searchCities('Paris');

      expect((result as Err).failure, const NoInternetFailure());
    });
  });
}
