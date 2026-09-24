import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus/features/weather/data/repositories/places_repository_impl.dart';
import 'package:nimbus/features/weather/domain/entities/saved_places.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/test_data.dart';

void main() {
  Future<PlacesRepositoryImpl> repositoryWith(Map<String, Object> saved) async {
    SharedPreferences.setMockInitialValues(saved);
    return PlacesRepositoryImpl(await SharedPreferences.getInstance());
  }

  test('starts with no places', () async {
    final repository = await repositoryWith({});

    expect(repository.load(), const SavedPlaces());
  });

  test('reads back what it saved', () async {
    final repository = await repositoryWith({});
    const places = SavedPlaces(
      includesCurrentLocation: true,
      cities: [TestData.ahmedabad, TestData.london],
      selectedIndex: 2,
    );

    await repository.save(places);

    expect(repository.load(), places);
  });

  test('clamps a selection that points past the last page', () async {
    final repository = await repositoryWith({});
    await repository.save(
      const SavedPlaces(cities: [TestData.london], selectedIndex: 5),
    );

    expect(repository.load().selectedIndex, 0);
  });

  test('treats an unreadable entry as no places', () async {
    final repository = await repositoryWith({
      PlacesRepositoryImpl.storageKey: '{"cities": 42}',
    });

    expect(repository.load(), const SavedPlaces());
  });
}
