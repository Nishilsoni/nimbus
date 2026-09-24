import 'dart:async';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nimbus/core/error/failures.dart';
import 'package:nimbus/core/utils/result.dart';
import 'package:nimbus/features/weather/data/datasources/device_location_data_source.dart';
import 'package:nimbus/features/weather/domain/entities/city.dart';
import 'package:nimbus/features/weather/domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  const LocationRepositoryImpl(this._device);

  final DeviceLocationDataSource _device;

  @override
  Future<Result<City>> getCurrentCity() async {
    try {
      if (!await _device.isServiceEnabled()) {
        return const Err(
          LocationFailure(LocationFailureReason.serviceDisabled),
        );
      }

      var permission = await _device.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await _device.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        return const Err(
          LocationFailure(LocationFailureReason.permissionDeniedForever),
        );
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.unableToDetermine) {
        return const Err(
          LocationFailure(LocationFailureReason.permissionDenied),
        );
      }

      final position = await _device.currentPosition();
      final placemark = await _lookUpPlacemark(position);
      return Ok(_toCity(position, placemark));
    } on TimeoutException {
      return const Err(LocationFailure(LocationFailureReason.unavailable));
    } on Exception {
      // Plugin errors (e.g. PlatformException) mean we couldn't get a fix.
      return const Err(LocationFailure(LocationFailureReason.unavailable));
    }
  }

  @override
  Future<void> openSettings(LocationFailureReason reason) async {
    if (reason == LocationFailureReason.serviceDisabled) {
      await _device.openLocationSettings();
    } else {
      await _device.openAppSettings();
    }
  }

  /// A place name is nice to have, not essential: reverse geocoding can fail
  /// offline or when the platform geocoder is rate-limited.
  Future<Placemark?> _lookUpPlacemark(Position position) async {
    try {
      return await _device.placemarkAt(position.latitude, position.longitude);
    } on Exception {
      return null;
    }
  }

  City _toCity(Position position, Placemark? placemark) {
    final name = [
      placemark?.locality,
      placemark?.subAdministrativeArea,
      placemark?.administrativeArea,
    ].firstWhere((part) => part != null && part.isNotEmpty, orElse: () => null);

    return City(
      // Without a place name, the coordinates are still a truthful label.
      name: name ?? _formatCoordinates(position),
      latitude: position.latitude,
      longitude: position.longitude,
      region: placemark?.administrativeArea.nullIfEmpty,
      country: placemark?.country.nullIfEmpty,
      countryCode: placemark?.isoCountryCode.nullIfEmpty,
      isCurrentLocation: true,
    );
  }

  String _formatCoordinates(Position position) =>
      '${position.latitude.toStringAsFixed(2)}°, '
      '${position.longitude.toStringAsFixed(2)}°';
}

extension on String? {
  String? get nullIfEmpty => (this?.isEmpty ?? true) ? null : this;
}
