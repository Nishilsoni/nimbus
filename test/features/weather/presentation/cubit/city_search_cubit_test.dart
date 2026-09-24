import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nimbus/core/error/failures.dart';
import 'package:nimbus/core/utils/result.dart';
import 'package:nimbus/features/weather/domain/entities/city.dart';
import 'package:nimbus/features/weather/domain/repositories/weather_repository.dart';
import 'package:nimbus/features/weather/presentation/cubit/city_search_cubit.dart';
import 'package:nimbus/features/weather/presentation/cubit/city_search_state.dart';

import '../../../../helpers/test_data.dart';

class _MockWeatherRepository extends Mock implements WeatherRepository {}

void main() {
  late _MockWeatherRepository repository;

  const debounce = Duration(milliseconds: 10);
  const afterDebounce = Duration(milliseconds: 30);

  setUp(() => repository = _MockWeatherRepository());

  CitySearchCubit buildCubit() => CitySearchCubit(
    weatherRepository: repository,
    debounceDuration: debounce,
  );

  void stubSearch(String query, Result<List<City>> result) {
    when(() => repository.searchCities(query)).thenAnswer((_) async => result);
  }

  blocTest<CitySearchCubit, CitySearchState>(
    'debounces typing into a single search for the final query',
    setUp: () => stubSearch('Ahme', const Ok([TestData.ahmedabad])),
    build: buildCubit,
    act: (cubit) => cubit
      ..queryChanged('Ah')
      ..queryChanged('Ahm')
      ..queryChanged('Ahme'),
    wait: afterDebounce,
    expect: () => const [
      CitySearchState(status: CitySearchStatus.loading, query: 'Ahme'),
      CitySearchState(
        status: CitySearchStatus.success,
        query: 'Ahme',
        results: [TestData.ahmedabad],
      ),
    ],
    verify: (_) {
      verify(() => repository.searchCities('Ahme')).called(1);
      verifyNoMoreInteractions(repository);
    },
  );

  blocTest<CitySearchCubit, CitySearchState>(
    'clears results without searching for queries under two letters',
    build: buildCubit,
    seed: () => const CitySearchState(
      status: CitySearchStatus.success,
      query: 'Ahmedabad',
      results: [TestData.ahmedabad],
    ),
    act: (cubit) => cubit.queryChanged(' a '),
    wait: afterDebounce,
    expect: () => const [CitySearchState()],
    verify: (_) => verifyZeroInteractions(repository),
  );

  blocTest<CitySearchCubit, CitySearchState>(
    'reports when no city matches',
    setUp: () => stubSearch('Qwzx', const Err(CityNotFoundFailure('Qwzx'))),
    build: buildCubit,
    act: (cubit) => cubit.submit('Qwzx'),
    expect: () => const [
      CitySearchState(status: CitySearchStatus.loading, query: 'Qwzx'),
      CitySearchState(
        status: CitySearchStatus.failure,
        query: 'Qwzx',
        failure: CityNotFoundFailure('Qwzx'),
      ),
    ],
  );

  blocTest<CitySearchCubit, CitySearchState>(
    'keeps previous results visible while the next search loads',
    setUp: () => stubSearch('London', const Ok([TestData.london])),
    build: buildCubit,
    seed: () => const CitySearchState(
      status: CitySearchStatus.success,
      query: 'Ahmedabad',
      results: [TestData.ahmedabad],
    ),
    act: (cubit) => cubit.submit('London'),
    expect: () => const [
      CitySearchState(
        status: CitySearchStatus.loading,
        query: 'London',
        results: [TestData.ahmedabad],
      ),
      CitySearchState(
        status: CitySearchStatus.success,
        query: 'London',
        results: [TestData.london],
      ),
    ],
  );

  blocTest<CitySearchCubit, CitySearchState>(
    'retry repeats the last query',
    setUp: () => stubSearch('Paris', const Err(NoInternetFailure())),
    build: buildCubit,
    act: (cubit) async {
      await cubit.submit('Paris');
      await cubit.retry();
    },
    verify: (_) => verify(() => repository.searchCities('Paris')).called(2),
  );

  blocTest<CitySearchCubit, CitySearchState>(
    'drops results that arrive after the query was cleared',
    setUp: () {
      final slow = Completer<Result<List<City>>>();
      when(() => repository.searchCities('London')).thenAnswer((_) {
        Future<void>.delayed(
          const Duration(milliseconds: 20),
          () => slow.complete(const Ok([TestData.london])),
        );
        return slow.future;
      });
    },
    build: buildCubit,
    act: (cubit) {
      unawaited(cubit.submit('London'));
      cubit.queryChanged('');
    },
    wait: const Duration(milliseconds: 50),
    expect: () => const [
      CitySearchState(status: CitySearchStatus.loading, query: 'London'),
      CitySearchState(),
    ],
  );
}
