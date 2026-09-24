import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:nimbus/core/constants/api_constants.dart';

/// A thin wrapper over the geolocator and geocoding plugins.
///
/// The plugins expose static methods, which can't be mocked. Wrapping them
/// keeps the permission logic in [LocationRepositoryImpl] unit-testable.
class DeviceLocationDataSource {
  DeviceLocationDataSource({Geocoding? geocoding})
    : _geocoding = geocoding ?? Geocoding();

  final Geocoding _geocoding;

  Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();

  Future<LocationPermission> checkPermission() => Geolocator.checkPermission();

  Future<LocationPermission> requestPermission() =>
      Geolocator.requestPermission();

  /// City-level accuracy is all weather needs, and it's faster and kinder
  /// to the battery than a precise fix.
  Future<Position> currentPosition() => Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.low,
      timeLimit: ApiConstants.locationTimeout,
    ),
  );

  Future<Placemark?> placemarkAt(double latitude, double longitude) async {
    final placemarks = await _geocoding.placemarkFromCoordinates(
      latitude,
      longitude,
    );
    return placemarks.firstOrNull;
  }

  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();
}
