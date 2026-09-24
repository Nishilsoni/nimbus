import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nimbus/features/weather/domain/entities/city.dart';
import 'package:nimbus/features/weather/domain/entities/place.dart';
import 'package:nimbus/features/weather/domain/entities/saved_places.dart';
import 'package:nimbus/features/weather/domain/repositories/places_repository.dart';

/// The user's pages: which places exist, their order, and which one is
/// showing. Every change is saved, so the app reopens where it was left.
class PlacesCubit extends Cubit<SavedPlaces> {
  PlacesCubit(this._repository) : super(_repository.load());

  final PlacesRepository _repository;

  /// Follows the user's swipes.
  Future<void> select(int index) async {
    if (index == state.selectedIndex) return;
    if (index < 0 || index >= state.places.length) return;
    await _update(state.copyWith(selectedIndex: index));
  }

  /// Adds [city] as a new last page and shows it. A city that's already
  /// saved is shown instead of added twice.
  Future<void> addCity(City city) async {
    final existing = state.places.indexOf(CityPlace(city));
    if (existing != -1) return select(existing);

    final added = state.copyWith(cities: [...state.cities, city]);
    await _update(added.copyWith(selectedIndex: added.places.length - 1));
  }

  /// Shows the location page, adding it as the first page if needed.
  Future<void> showCurrentLocation() async {
    if (state.includesCurrentLocation) return select(0);
    await _update(
      state.copyWith(includesCurrentLocation: true, selectedIndex: 0),
    );
  }

  /// Removes [place]. The page on screen stays on screen when it's another
  /// one; otherwise its neighbour takes over.
  Future<void> remove(Place place) async {
    final index = state.places.indexOf(place);
    if (index == -1) return;

    final remaining = switch (place) {
      CurrentLocationPlace() => state.copyWith(includesCurrentLocation: false),
      CityPlace(:final city) => state.copyWith(
        cities: [
          for (final saved in state.cities)
            if (CityPlace(saved) != CityPlace(city)) saved,
        ],
      ),
    };
    final selected = state.selectedIndex;
    final newSelected = index < selected ? selected - 1 : selected;
    final lastIndex = remaining.places.length - 1;
    await _update(
      remaining.copyWith(
        selectedIndex: lastIndex < 0 ? 0 : newSelected.clamp(0, lastIndex),
      ),
    );
  }

  Future<void> _update(SavedPlaces places) async {
    emit(places);
    await _repository.save(places);
  }
}
