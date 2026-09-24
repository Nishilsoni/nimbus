import 'package:equatable/equatable.dart';

/// A place we can fetch weather for, either picked from search or resolved
/// from the device GPS.
class City extends Equatable {
  const City({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.id,
    this.region,
    this.country,
    this.countryCode,
    this.isCurrentLocation = false,
  });

  /// Provider id for searched cities; `null` for GPS positions.
  final int? id;
  final String name;
  final String? region;
  final String? country;

  /// ISO 3166-1 alpha-2, e.g. "IN".
  final String? countryCode;
  final double latitude;
  final double longitude;
  final bool isCurrentLocation;

  /// "Gujarat, India": the parts that exist, joined.
  String get subtitle => [region, country].nonNulls.join(', ');

  @override
  List<Object?> get props => [
    id,
    name,
    region,
    country,
    countryCode,
    latitude,
    longitude,
    isCurrentLocation,
  ];
}
