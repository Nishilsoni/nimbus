import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nimbus/core/constants/api_constants.dart';
import 'package:nimbus/core/utils/result.dart';
import 'package:nimbus/features/weather/domain/repositories/weather_repository.dart';
import 'package:nimbus/features/weather/presentation/cubit/city_search_state.dart';

/// Search-as-you-type for cities.
///
/// Typing is debounced so a fast typist sends one request, not one per
/// letter, which also keeps us well away from the API's rate limit.
class CitySearchCubit extends Cubit<CitySearchState> {
  CitySearchCubit({
    required WeatherRepository weatherRepository,
    this.languageCode = 'en',
    this.debounceDuration = const Duration(milliseconds: 400),
  }) : _weatherRepository = weatherRepository,
       super(const CitySearchState());

  final WeatherRepository _weatherRepository;
  final Duration debounceDuration;

  /// Results are named in this language where the provider can.
  final String languageCode;

  Timer? _debounce;
  int _latestSearch = 0;

  void queryChanged(String query) {
    _debounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.length < ApiConstants.minSearchQueryLength) {
      _latestSearch++; // Drop any search still in flight.
      emit(const CitySearchState());
      return;
    }
    _debounce = Timer(debounceDuration, () => _search(trimmed));
  }

  /// The keyboard's search action: skip the debounce and search now.
  Future<void> submit(String query) async {
    _debounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.length < ApiConstants.minSearchQueryLength) return;
    await _search(trimmed);
  }

  Future<void> retry() => _search(state.query);

  Future<void> _search(String query) async {
    final serial = ++_latestSearch;
    emit(
      CitySearchState(
        status: CitySearchStatus.loading,
        query: query,
        results: state.results,
      ),
    );

    final result = await _weatherRepository.searchCities(
      query,
      languageCode: languageCode,
    );
    if (isClosed || serial != _latestSearch) return;

    emit(switch (result) {
      Ok(value: final cities) => CitySearchState(
        status: CitySearchStatus.success,
        query: query,
        results: cities,
      ),
      Err(:final failure) => CitySearchState(
        status: CitySearchStatus.failure,
        query: query,
        failure: failure,
      ),
    });
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
