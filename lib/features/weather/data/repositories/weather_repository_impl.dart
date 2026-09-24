import 'dart:developer' as developer;

import 'package:nimbus/core/error/exceptions.dart';
import 'package:nimbus/core/error/failures.dart';
import 'package:nimbus/core/utils/result.dart';
import 'package:nimbus/features/weather/data/datasources/geocoding_remote_data_source.dart';
import 'package:nimbus/features/weather/data/datasources/weather_local_data_source.dart';
import 'package:nimbus/features/weather/data/datasources/weather_remote_data_source.dart';
import 'package:nimbus/features/weather/data/models/city_model.dart';
import 'package:nimbus/features/weather/data/models/weather_report_model.dart';
import 'package:nimbus/features/weather/domain/entities/city.dart';
import 'package:nimbus/features/weather/domain/entities/weather_report.dart';
import 'package:nimbus/features/weather/domain/repositories/weather_repository.dart';

/// Coordinates the remote APIs and the local cache, and is the boundary
/// where exceptions become [Failure]s.
class WeatherRepositoryImpl implements WeatherRepository {
  WeatherRepositoryImpl({
    required WeatherRemoteDataSource weatherRemote,
    required GeocodingRemoteDataSource geocodingRemote,
    required WeatherLocalDataSource local,
    DateTime Function()? clock,
  }) : _weatherRemote = weatherRemote,
       _geocodingRemote = geocodingRemote,
       _local = local,
       _clock = clock ?? DateTime.now;

  final WeatherRemoteDataSource _weatherRemote;
  final GeocodingRemoteDataSource _geocodingRemote;
  final WeatherLocalDataSource _local;
  final DateTime Function() _clock;

  @override
  Future<Result<WeatherReport>> getWeather(City city) {
    return _guard(() async {
      final weather = await _weatherRemote.fetchWeather(
        latitude: city.latitude,
        longitude: city.longitude,
      );
      final report = WeatherReportModel(
        city: CityModel.fromEntity(city),
        weather: weather,
        fetchedAt: _clock(),
      );
      await _saveToCache(report);
      return report.toEntity();
    });
  }

  @override
  Future<WeatherReport?> getLastReport() async {
    final cached = await _local.readLastReport();
    return cached?.toEntity();
  }

  @override
  Future<Result<List<City>>> searchCities(String query) async {
    final result = await _guard(() async {
      final cities = await _geocodingRemote.searchCities(query);
      return cities.map((city) => city.toEntity()).toList(growable: false);
    });
    return switch (result) {
      Ok(value: final cities) when cities.isEmpty => Err(
        CityNotFoundFailure(query),
      ),
      _ => result,
    };
  }

  /// A failed cache write must never turn a successful fetch into an error.
  Future<void> _saveToCache(WeatherReportModel report) async {
    try {
      await _local.saveReport(report);
    } on Exception catch (error) {
      developer.log('Could not cache weather', error: error, name: 'nimbus');
    }
  }

  /// Runs [action] and converts any exception into an [Err].
  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Ok(await action());
    } on AppException catch (error) {
      return Err(error.toFailure());
    } on Exception catch (error, stackTrace) {
      developer.log(
        'Unexpected error',
        error: error,
        stackTrace: stackTrace,
        name: 'nimbus',
      );
      return const Err(UnknownFailure());
    }
  }
}
