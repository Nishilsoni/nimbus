import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nimbus/core/error/failures.dart';
import 'package:nimbus/core/utils/result.dart';
import 'package:nimbus/features/weather/domain/entities/city.dart';
import 'package:nimbus/features/weather/domain/entities/weather_report.dart';
import 'package:nimbus/features/weather/domain/repositories/location_repository.dart';
import 'package:nimbus/features/weather/domain/repositories/weather_repository.dart';
import 'package:nimbus/features/weather/presentation/cubit/weather_state.dart';

/// Owns everything the weather screen shows.
///
/// Three rules keep the refresh behaviour predictable:
/// 1. Data on screen is only replaced by newer, successful data.
/// 2. Only the newest request may update the state; answers to superseded
///    requests (e.g. the user switched city mid-refresh) are dropped.
/// 3. Refreshing while a request is running joins that request instead of
///    starting a duplicate.
class WeatherCubit extends Cubit<WeatherState> {
  WeatherCubit({
    required WeatherRepository weatherRepository,
    required LocationRepository locationRepository,
  }) : _weatherRepository = weatherRepository,
       _locationRepository = locationRepository,
       super(const WeatherState());

  final WeatherRepository _weatherRepository;
  final LocationRepository _locationRepository;

  /// Incremented per request; a response is applied only if its serial is
  /// still the latest.
  int _latestRequest = 0;

  Future<void>? _inFlight;

  /// Repeats the user's last request. Lets "Try again" work even when no
  /// data has loaded yet (e.g. after a denied location permission).
  Future<void> Function()? _repeatLastRequest;

  /// Shows the cached report straight away, then refreshes it from the API.
  Future<void> loadInitialWeather() async {
    final cached = await _weatherRepository.getLastReport();
    if (isClosed || cached == null || state.hasData) return;

    emit(
      state.copyWith(
        status: WeatherStatus.success,
        report: cached,
        isFromCache: true,
      ),
    );
    await selectCity(cached.city);
  }

  Future<void> selectCity(City city) =>
      _startRequest((serial) => _fetchWeather(city, serial));

  Future<void> useCurrentLocation() => _startRequest(_fetchCurrentLocation);

  /// Pull-to-refresh and the refresh button both end up here.
  Future<void> refresh() {
    final inFlight = _inFlight;
    if (inFlight != null) return inFlight;

    final city = state.report?.city;
    if (city != null) return selectCity(city);
    return _repeatLastRequest?.call() ?? Future.value();
  }

  void dismissFailure() => emit(state.copyWith(clearFailure: true));

  /// Sends the user to the settings screen that fixes a location failure.
  Future<void> openLocationSettings() async {
    if (state.failure case LocationFailure(:final reason)) {
      await _locationRepository.openSettings(reason);
    }
  }

  Future<void> _startRequest(Future<void> Function(int serial) request) {
    final serial = ++_latestRequest;
    _repeatLastRequest = () => _startRequest(request);

    emit(
      state.hasData
          ? state.copyWith(isRefreshing: true, clearFailure: true)
          : state.copyWith(status: WeatherStatus.loading, clearFailure: true),
    );

    final future = request(serial).whenComplete(() {
      if (serial == _latestRequest) _inFlight = null;
    });
    _inFlight = future;
    return future;
  }

  Future<void> _fetchWeather(City city, int serial) async {
    final result = await _weatherRepository.getWeather(city);
    if (_isStale(serial)) return;

    switch (result) {
      case Ok(value: final report):
        _emitSuccess(report);
      case Err(:final failure):
        _emitFailure(failure);
    }
  }

  Future<void> _fetchCurrentLocation(int serial) async {
    final result = await _locationRepository.getCurrentCity();
    if (_isStale(serial)) return;

    switch (result) {
      case Ok(value: final city):
        await _fetchWeather(city, serial);
      case Err(:final failure):
        _emitFailure(failure);
    }
  }

  bool _isStale(int serial) => isClosed || serial != _latestRequest;

  void _emitSuccess(WeatherReport report) {
    emit(WeatherState(status: WeatherStatus.success, report: report));
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
