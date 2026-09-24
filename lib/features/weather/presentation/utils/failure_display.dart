import 'package:flutter/material.dart';
import 'package:nimbus/core/error/failures.dart';
import 'package:nimbus/core/l10n/l10n.dart';

/// What the user can do about a failure. Retrying the location page takes
/// a fresh GPS fix, so "retry" covers location problems too.
enum FailureAction { retry, openSettings }

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

  String title(AppLocalizations l10n) => switch (this) {
    NoInternetFailure() => l10n.noInternetTitle,
    TimeoutFailure() => l10n.timeoutTitle,
    RateLimitFailure() => l10n.rateLimitTitle,
    CityNotFoundFailure() => l10n.cityNotFoundTitle,
    ServerFailure() => l10n.serverTitle,
    LocationFailure(:final reason) => switch (reason) {
      LocationFailureReason.serviceDisabled => l10n.locationDisabledTitle,
      LocationFailureReason.permissionDenied => l10n.locationDeniedTitle,
      LocationFailureReason.permissionDeniedForever =>
        l10n.locationBlockedTitle,
      LocationFailureReason.unavailable => l10n.locationUnavailableTitle,
    },
    UnknownFailure() => l10n.unknownTitle,
  };

  String message(AppLocalizations l10n) => switch (this) {
    NoInternetFailure() => l10n.noInternetMessage,
    TimeoutFailure() => l10n.timeoutMessage,
    RateLimitFailure() => l10n.rateLimitMessage,
    CityNotFoundFailure(:final query) => l10n.cityNotFoundMessage(query),
    ServerFailure() => l10n.serverMessage,
    LocationFailure(:final reason) => switch (reason) {
      LocationFailureReason.serviceDisabled => l10n.locationDisabledMessage,
      LocationFailureReason.permissionDenied => l10n.locationDeniedMessage,
      LocationFailureReason.permissionDeniedForever =>
        l10n.locationBlockedMessage,
      LocationFailureReason.unavailable => l10n.locationUnavailableMessage,
    },
    UnknownFailure() => l10n.unknownMessage,
  };

  FailureAction get action => switch (this) {
    LocationFailure(
      reason: LocationFailureReason.serviceDisabled ||
          LocationFailureReason.permissionDeniedForever,
    ) =>
      FailureAction.openSettings,
    _ => FailureAction.retry,
  };

  String actionLabel(AppLocalizations l10n) => switch (action) {
    FailureAction.openSettings => l10n.openSettings,
    FailureAction.retry => l10n.tryAgain,
  };
}
