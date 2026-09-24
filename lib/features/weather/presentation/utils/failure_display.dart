import 'package:flutter/material.dart';
import 'package:nimbus/core/constants/app_strings.dart';
import 'package:nimbus/core/error/failures.dart';

/// What the user can do about a failure.
enum FailureAction { retry, retryLocation, openSettings }

/// How each [Failure] is presented. Kept in the presentation layer so the
/// domain's failures stay free of icons and copy.
///
/// The switches are exhaustive over the sealed [Failure] type: a new
/// failure won't compile until it has an icon, a title and a message.
extension FailureDisplay on Failure {
  IconData get icon => switch (this) {
    NoInternetFailure() => Icons.wifi_off_rounded,
    TimeoutFailure() => Icons.hourglass_bottom_rounded,
    RateLimitFailure() => Icons.speed_rounded,
    CityNotFoundFailure() => Icons.search_off_rounded,
    ServerFailure() => Icons.cloud_off_rounded,
    LocationFailure() => Icons.location_off_rounded,
    UnknownFailure() => Icons.error_outline_rounded,
  };

  String get title => switch (this) {
    NoInternetFailure() => AppStrings.noInternetTitle,
    TimeoutFailure() => AppStrings.timeoutTitle,
    RateLimitFailure() => AppStrings.rateLimitTitle,
    CityNotFoundFailure() => AppStrings.cityNotFoundTitle,
    ServerFailure() => AppStrings.serverTitle,
    LocationFailure(:final reason) => switch (reason) {
      LocationFailureReason.serviceDisabled => AppStrings.locationDisabledTitle,
      LocationFailureReason.permissionDenied => AppStrings.locationDeniedTitle,
      LocationFailureReason.permissionDeniedForever =>
        AppStrings.locationBlockedTitle,
      LocationFailureReason.unavailable => AppStrings.locationUnavailableTitle,
    },
    UnknownFailure() => AppStrings.unknownTitle,
  };

  String get message => switch (this) {
    NoInternetFailure() => AppStrings.noInternetMessage,
    TimeoutFailure() => AppStrings.timeoutMessage,
    RateLimitFailure() => AppStrings.rateLimitMessage,
    CityNotFoundFailure(:final query) => AppStrings.cityNotFoundMessage(query),
    ServerFailure() => AppStrings.serverMessage,
    LocationFailure(:final reason) => switch (reason) {
      LocationFailureReason.serviceDisabled =>
        AppStrings.locationDisabledMessage,
      LocationFailureReason.permissionDenied =>
        AppStrings.locationDeniedMessage,
      LocationFailureReason.permissionDeniedForever =>
        AppStrings.locationBlockedMessage,
      LocationFailureReason.unavailable =>
        AppStrings.locationUnavailableMessage,
    },
    UnknownFailure() => AppStrings.unknownMessage,
  };

  FailureAction get action => switch (this) {
    LocationFailure(
      reason: LocationFailureReason.serviceDisabled ||
          LocationFailureReason.permissionDeniedForever,
    ) =>
      FailureAction.openSettings,
    LocationFailure() => FailureAction.retryLocation,
    _ => FailureAction.retry,
  };

  String get actionLabel => switch (action) {
    FailureAction.openSettings => AppStrings.openSettings,
    FailureAction.retry || FailureAction.retryLocation => AppStrings.tryAgain,
  };
}
