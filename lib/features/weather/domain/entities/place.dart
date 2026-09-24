import 'package:equatable/equatable.dart';
import 'package:nimbus/features/weather/domain/entities/city.dart';

/// A page of the weather screen: the device's location, or a saved city.
sealed class Place extends Equatable {
  const Place();

  /// Where a fetched report belongs: GPS results go to the location page,
  /// everything else to its city.
  factory Place.of(City city) =>
      city.isCurrentLocation ? const CurrentLocationPlace() : CityPlace(city);

  /// Stable identity, used as the cache key and the page key.
  String get id;

  @override
  List<Object?> get props => [id];
}

/// Wherever the device is. Resolved again on every refresh.
final class CurrentLocationPlace extends Place {
  const CurrentLocationPlace();

  @override
  String get id => 'current-location';
}

final class CityPlace extends Place {
  const CityPlace(this.city);

  final City city;

  /// The provider's id when there is one, otherwise rounded coordinates
  /// (about 100 m), so the same city is never saved twice.
  @override
  String get id => city.id != null
      ? 'city-${city.id}'
      : 'city-${city.latitude.toStringAsFixed(3)},'
            '${city.longitude.toStringAsFixed(3)}';
}
