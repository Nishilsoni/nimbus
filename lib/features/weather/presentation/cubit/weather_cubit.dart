import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nimbus/core/error/failures.dart';
import 'package:nimbus/core/utils/result.dart';
import 'package:nimbus/features/weather/domain/entities/place.dart';
import 'package:nimbus/features/weather/domain/entities/weather_report.dart';
import 'package:nimbus/features/weather/domain/repositories/location_repository.dart';
import 'package:nimbus/features/weather/domain/repositories/weather_repository.dart';
import 'package:nimbus/features/weather/presentation/cubit/weather_state.dart';

/// Owns everything one page of the weather screen shows: one [Place].
///
/// Two rules keep the refresh behaviour predictable:
/// 1. Data on screen is only replaced by newer, successful data. A failure
///    is reported next to it, never instead of it.
/// 2. Refreshing while a request is running joins that request instead of
///    starting a duplicate.
class WeatherCubit extends Cubit<WeatherState> {
  /// Starts from the cached report, if any, so the page shows weather on
  /// its first frame. Call [refresh] to fetch live data.
  WeatherCubit({
    required this.place,
    required WeatherRepository weatherRepository,
    required LocationRepository locationRepository,
  }) : _weatherRepository = weatherRepository,
       _locationRepository = locationRepository,
       super(_initialState(weatherRepository.getCachedReport(place)));

  final Place place;
  final WeatherRepository _weatherRepository;
  final LocationRepository _locationRepository;

  Future<void>? _inFlight;

  static WeatherState _initialState(WeatherReport? cached) => cached == null
      ? const WeatherState()
      : WeatherState(
          status: WeatherStatus.success,
          report: cached,
          isFromCache: true,
        );

  /// Pull-to-refresh, the refresh button and "Try again" all end up here.
  /// For the location page it also takes a fresh GPS fix.
  Future<void> refresh() {
    return _inFlight ??= _load().whenComplete(() => _inFlight = null);
  }

  void dismissFailure() => emit(state.copyWith(clearFailure: true));

  /// Sends the user to the settings screen that fixes a location failure.
  Future<void> openLocationSettings() async {
    if (state.failure case LocationFailure(:final reason)) {
      await _locationRepository.openSettings(reason);
    }
  }

  Future<void> _load() async {
    emit(
      state.hasData
          ? state.copyWith(isRefreshing: true, clearFailure: true)
          : state.copyWith(status: WeatherStatus.loading, clearFailure: true),
    );

    final result = switch (place) {
      CityPlace(:final city) => await _weatherRepository.getWeather(city),
      CurrentLocationPlace() => await _loadCurrentLocation(),
    };
    if (isClosed) return;

    switch (result) {
      case Ok(value: final report):
        emit(WeatherState(status: WeatherStatus.success, report: report));
      case Err(:final failure):
        _emitFailure(failure);
    }
  }

  Future<Result<WeatherReport>> _loadCurrentLocation() async {
    final location = await _locationRepository.getCurrentCity();
    return switch (location) {
      Ok(value: final city) => _weatherRepository.getWeather(city),
      Err(:final failure) => Err(failure),
    };
  }

  /// With data on screen the failure is reported alongside it; without
  /// data it becomes the full-screen error.
  void _emitFailure(Failure failure) {
    emit(
      state.hasData
          ? state.copyWith(isRefreshing: false, failure: failure)
          : state.copyWith(status: WeatherStatus.failure, failure: failure),
    );
  }
}
