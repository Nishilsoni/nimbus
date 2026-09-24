import 'package:equatable/equatable.dart';

/// A problem the user should know about, described in domain terms.
///
/// Failures are what repositories hand to the presentation layer instead of
/// throwing. The class is sealed so every `switch` over it is checked for
/// exhaustiveness by the compiler: adding a new failure forces the UI to
/// decide how to show it.
sealed class Failure extends Equatable {
  const Failure();

  @override
  List<Object?> get props => const [];
}

/// The device is offline or the server could not be reached.
final class NoInternetFailure extends Failure {
  const NoInternetFailure();
}

/// The server did not answer within the request timeout.
final class TimeoutFailure extends Failure {
  const TimeoutFailure();
}

/// The API answered with HTTP 429.
final class RateLimitFailure extends Failure {
  const RateLimitFailure();
}

/// A city search returned no matches.
final class CityNotFoundFailure extends Failure {
  const CityNotFoundFailure(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// The API answered with an unexpected HTTP status.
final class ServerFailure extends Failure {
  const ServerFailure({this.statusCode});

  final int? statusCode;

  @override
  List<Object?> get props => [statusCode];
}

/// The device position could not be determined.
final class LocationFailure extends Failure {
  const LocationFailure(this.reason);

  final LocationFailureReason reason;

  @override
  List<Object?> get props => [reason];
}

enum LocationFailureReason {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  unavailable,
}

/// Anything we did not anticipate, such as a malformed response.
final class UnknownFailure extends Failure {
  const UnknownFailure();
}
