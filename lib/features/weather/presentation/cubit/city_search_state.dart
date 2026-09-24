import 'package:equatable/equatable.dart';
import 'package:nimbus/core/error/failures.dart';
import 'package:nimbus/features/weather/domain/entities/city.dart';

enum CitySearchStatus { idle, loading, success, failure }

final class CitySearchState extends Equatable {
  const CitySearchState({
    this.status = CitySearchStatus.idle,
    this.query = '',
    this.results = const [],
    this.failure,
  });

  final CitySearchStatus status;
  final String query;

  /// Kept while a new search loads, so the list doesn't flash empty on
  /// every keystroke.
  final List<City> results;
  final Failure? failure;

  @override
  List<Object?> get props => [status, query, results, failure];
}
