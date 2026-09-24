import 'package:nimbus/core/error/failures.dart';

/// Exceptions thrown inside the data layer.
///
/// They never reach widgets or cubits: repositories catch them and convert
/// them into [Failure]s with [AppExceptionMapper.toFailure].
sealed class AppException implements Exception {
  const AppException();
}

final class NoInternetException extends AppException {
  const NoInternetException();
}

final class RequestTimeoutException extends AppException {
  const RequestTimeoutException();
}

final class RateLimitException extends AppException {
  const RateLimitException();
}

final class ServerException extends AppException {
  const ServerException(this.statusCode, {this.reason});

  final int statusCode;

  /// The `reason` field Open-Meteo sends with 4xx errors, if any.
  final String? reason;

  @override
  String toString() => 'ServerException($statusCode, $reason)';
}

/// The response body did not have the shape we expected.
final class ParsingException extends AppException {
  const ParsingException(this.cause);

  final Object cause;

  @override
  String toString() => 'ParsingException($cause)';
}

extension AppExceptionMapper on AppException {
  Failure toFailure() => switch (this) {
    NoInternetException() => const NoInternetFailure(),
    RequestTimeoutException() => const TimeoutFailure(),
    RateLimitException() => const RateLimitFailure(),
    ServerException(:final statusCode) => ServerFailure(statusCode: statusCode),
    ParsingException() => const UnknownFailure(),
  };
}
