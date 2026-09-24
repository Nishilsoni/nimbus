import 'package:equatable/equatable.dart';
import 'package:nimbus/core/error/failures.dart';
import 'package:nimbus/features/weather/domain/entities/weather_report.dart';

/// Which full-screen view to show when there is no [WeatherState.report].
///
/// Once a report exists, [status] stays [success]: later fetches only toggle
/// [WeatherState.isRefreshing] and set [WeatherState.failure], so the data on
/// screen is never thrown away by a failed refresh.
enum WeatherStatus { initial, loading, success, failure }

final class WeatherState extends Equatable {
  const WeatherState({
    this.status = WeatherStatus.initial,
    this.report,
    this.failure,
    this.isRefreshing = false,
    this.isFromCache = false,
  });

  final WeatherStatus status;

  /// The last good data. Only a successful fetch replaces it.
  final WeatherReport? report;

  /// Why the most recent request failed. Cleared when a new one starts.
  final Failure? failure;

  /// A request is running while [report] is already on screen.
  final bool isRefreshing;

  /// [report] came from local storage and hasn't been confirmed live yet.
  final bool isFromCache;

  bool get hasData => report != null;

  /// True while any request is running, with or without data on screen.
  bool get isBusy => isRefreshing || status == WeatherStatus.loading;

  WeatherState copyWith({
    WeatherStatus? status,
    WeatherReport? report,
    Failure? failure,
    bool clearFailure = false,
    bool? isRefreshing,
    bool? isFromCache,
  }) {
    return WeatherState(
      status: status ?? this.status,
      report: report ?? this.report,
      failure: clearFailure ? null : failure ?? this.failure,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  @override
  List<Object?> get props => [
    status,
    report,
    failure,
    isRefreshing,
    isFromCache,
  ];
}
