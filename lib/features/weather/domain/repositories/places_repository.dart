import 'package:nimbus/features/weather/domain/entities/saved_places.dart';

/// Remembers the user's pages between launches.
abstract interface class PlacesRepository {
  /// The saved pages; empty on first launch.
  SavedPlaces load();

  Future<void> save(SavedPlaces places);
}
