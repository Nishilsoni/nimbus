import 'dart:convert';

import 'package:nimbus/core/utils/json_reader.dart';
import 'package:nimbus/features/weather/data/models/city_model.dart';
import 'package:nimbus/features/weather/domain/entities/saved_places.dart';
import 'package:nimbus/features/weather/domain/repositories/places_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlacesRepositoryImpl implements PlacesRepository {
  const PlacesRepositoryImpl(this._preferences);

  static const storageKey = 'saved_places';

  final SharedPreferences _preferences;

  /// Synchronous so the first frame already knows which pages exist. A
  /// missing or unreadable entry means "no places yet".
  @override
  SavedPlaces load() {
    final raw = _preferences.getString(storageKey);
    if (raw == null) return const SavedPlaces();
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) throw const FormatException();
      final cities = json.require<List<dynamic>>('cities');
      final places = SavedPlaces(
        includesCurrentLocation: json['current_location'] == true,
        cities: [
          for (final city in cities)
            if (city is Map<String, dynamic>)
              CityModel.fromJson(city).toEntity()
            else
              throw const FormatException('Expected a city object'),
        ],
        selectedIndex: json.optionalInt('selected') ?? 0,
      );
      final lastIndex = places.places.length - 1;
      return places.copyWith(
        selectedIndex: places.selectedIndex.clamp(
          0,
          lastIndex < 0 ? 0 : lastIndex,
        ),
      );
    } on FormatException {
      return const SavedPlaces();
    }
  }

  @override
  Future<void> save(SavedPlaces places) => _preferences.setString(
    storageKey,
    jsonEncode({
      'current_location': places.includesCurrentLocation,
      'cities': [
        for (final city in places.cities) CityModel.fromEntity(city).toJson(),
      ],
      'selected': places.selectedIndex,
    }),
  );
}
