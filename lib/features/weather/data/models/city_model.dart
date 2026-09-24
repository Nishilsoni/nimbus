import 'package:nimbus/core/utils/json_reader.dart';
import 'package:nimbus/features/weather/domain/entities/city.dart';

/// A geocoding search result. [toJson] reuses the API's key names so cached
/// cities parse with the same [CityModel.fromJson].
class CityModel {
  const CityModel({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.id,
    this.admin1,
    this.country,
    this.countryCode,
    this.isCurrentLocation = false,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) => CityModel(
    id: json.optionalInt('id'),
    name: json.requireString('name'),
    latitude: json.requireDouble('latitude'),
    longitude: json.requireDouble('longitude'),
    admin1: json.optionalString('admin1'),
    country: json.optionalString('country'),
    countryCode: json.optionalString('country_code'),
    isCurrentLocation: json['is_current_location'] == true,
  );

  factory CityModel.fromEntity(City city) => CityModel(
    id: city.id,
    name: city.name,
    latitude: city.latitude,
    longitude: city.longitude,
    admin1: city.region,
    country: city.country,
    countryCode: city.countryCode,
    isCurrentLocation: city.isCurrentLocation,
  );

  final int? id;
  final String name;
  final double latitude;
  final double longitude;

  /// First-level administrative area (state, province…).
  final String? admin1;
  final String? country;
  final String? countryCode;
  final bool isCurrentLocation;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
    'admin1': admin1,
    'country': country,
    'country_code': countryCode,
    'is_current_location': isCurrentLocation,
  };

  City toEntity() => City(
    id: id,
    name: name,
    latitude: latitude,
    longitude: longitude,
    region: admin1,
    country: country,
    countryCode: countryCode,
    isCurrentLocation: isCurrentLocation,
  );
}
