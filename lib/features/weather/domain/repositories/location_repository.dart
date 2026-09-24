import 'package:nimbus/core/error/failures.dart';
import 'package:nimbus/core/utils/result.dart';
import 'package:nimbus/features/weather/domain/entities/city.dart';

abstract interface class LocationRepository {
  /// Resolves the device position to a [City], asking for permission if
  /// needed. Fails with a `LocationFailure` explaining why it couldn't.
  Future<Result<City>> getCurrentCity();

  /// Opens the system screen that fixes [reason]: location services for a
  /// disabled service, app settings for a blocked permission.
  Future<void> openSettings(LocationFailureReason reason);
}
