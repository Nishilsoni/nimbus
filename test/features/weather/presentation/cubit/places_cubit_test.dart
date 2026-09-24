import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus/features/weather/domain/entities/place.dart';
import 'package:nimbus/features/weather/domain/entities/saved_places.dart';
import 'package:nimbus/features/weather/domain/repositories/places_repository.dart';
import 'package:nimbus/features/weather/presentation/cubit/places_cubit.dart';

import '../../../../helpers/test_data.dart';

class _FakeRepository implements PlacesRepository {
  _FakeRepository([this.saved = const SavedPlaces()]);

  SavedPlaces saved;

  @override
  SavedPlaces load() => saved;

  @override
  Future<void> save(SavedPlaces places) async => saved = places;
}

void main() {
  const twoCities = SavedPlaces(cities: [TestData.ahmedabad, TestData.london]);

  test('starts from the saved places', () {
    expect(PlacesCubit(_FakeRepository(twoCities)).state, twoCities);
  });

  blocTest<PlacesCubit, SavedPlaces>(
    'adds a city as the last page and shows it',
    build: () => PlacesCubit(
      _FakeRepository(const SavedPlaces(cities: [TestData.ahmedabad])),
    ),
    act: (cubit) => cubit.addCity(TestData.london),
    expect: () => const [
      SavedPlaces(
        cities: [TestData.ahmedabad, TestData.london],
        selectedIndex: 1,
      ),
    ],
  );

  blocTest<PlacesCubit, SavedPlaces>(
    'shows a city that is already saved instead of adding it twice',
    build: () => PlacesCubit(_FakeRepository(twoCities)),
    seed: () => twoCities.copyWith(selectedIndex: 1),
    act: (cubit) => cubit.addCity(TestData.ahmedabad),
    expect: () => [twoCities],
  );

  blocTest<PlacesCubit, SavedPlaces>(
    'adds the location page first and shows it',
    build: () => PlacesCubit(_FakeRepository(twoCities)),
    seed: () => twoCities.copyWith(selectedIndex: 1),
    act: (cubit) => cubit.showCurrentLocation(),
    expect: () => [twoCities.copyWith(includesCurrentLocation: true)],
  );

  blocTest<PlacesCubit, SavedPlaces>(
    'follows swipes, ignoring pages that do not exist',
    build: () => PlacesCubit(_FakeRepository(twoCities)),
    act: (cubit) async {
      await cubit.select(1);
      await cubit.select(7);
    },
    expect: () => [twoCities.copyWith(selectedIndex: 1)],
  );

  group('remove', () {
    blocTest<PlacesCubit, SavedPlaces>(
      'keeps showing the same page when an earlier one is removed',
      build: () => PlacesCubit(_FakeRepository(twoCities)),
      seed: () => twoCities.copyWith(selectedIndex: 1),
      act: (cubit) => cubit.remove(const CityPlace(TestData.ahmedabad)),
      expect: () => const [
        SavedPlaces(cities: [TestData.london]),
      ],
    );

    blocTest<PlacesCubit, SavedPlaces>(
      'shows the neighbour when the page on screen is removed',
      build: () => PlacesCubit(_FakeRepository(twoCities)),
      seed: () => twoCities.copyWith(selectedIndex: 1),
      act: (cubit) => cubit.remove(const CityPlace(TestData.london)),
      expect: () => const [
        SavedPlaces(cities: [TestData.ahmedabad]),
      ],
    );

    blocTest<PlacesCubit, SavedPlaces>(
      'can remove the location page',
      build: () => PlacesCubit(_FakeRepository(twoCities)),
      seed: () => twoCities.copyWith(includesCurrentLocation: true),
      act: (cubit) => cubit.remove(const CurrentLocationPlace()),
      expect: () => [twoCities],
    );

    blocTest<PlacesCubit, SavedPlaces>(
      'leaves no places after removing the last one',
      build: () => PlacesCubit(
        _FakeRepository(const SavedPlaces(cities: [TestData.london])),
      ),
      act: (cubit) => cubit.remove(const CityPlace(TestData.london)),
      expect: () => const [SavedPlaces()],
    );
  });

  test('saves every change for the next launch', () async {
    final repository = _FakeRepository();
    final cubit = PlacesCubit(repository);

    await cubit.addCity(TestData.london);

    expect(repository.saved.cities, [TestData.london]);
  });
}
