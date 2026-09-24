import 'package:nimbus/core/error/failures.dart';

/// The outcome of an operation that can fail in an expected way.
///
/// Returning a [Result] instead of throwing makes the failure path part of
/// the method signature, so callers can't forget to handle it:
///
/// ```dart
/// switch (await repository.getWeather(city)) {
///   case Ok(:final value): showWeather(value);
///   case Err(:final failure): showError(failure);
/// }
/// ```
sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;
}
