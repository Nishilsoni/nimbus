import 'package:equatable/equatable.dart';
import 'package:nimbus/features/weather/domain/entities/city.dart';
import 'package:nimbus/features/weather/domain/entities/place.dart';

/// The pages the user has chosen and which one is showing.
class SavedPlaces extends Equatable {
  const SavedPlaces({
    this.includesCurrentLocation = false,
    this.cities = const [],
    this.selectedIndex = 0,
  });

  /// Whether the "my location" page exists. It's always the first page.
  final bool includesCurrentLocation;
  final List<City> cities;
  final int selectedIndex;

  List<Place> get places => [
    if (includesCurrentLocation) const CurrentLocationPlace(),
    for (final city in cities) CityPlace(city),
  ];

  bool get isEmpty => !includesCurrentLocation && cities.isEmpty;

  SavedPlaces copyWith({
    bool? includesCurrentLocation,
    List<City>? cities,
    int? selectedIndex,
  }) {
    return SavedPlaces(
      includesCurrentLocation:
          includesCurrentLocation ?? this.includesCurrentLocation,
      cities: cities ?? this.cities,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }

  @override
  List<Object?> get props => [includesCurrentLocation, cities, selectedIndex];
}
