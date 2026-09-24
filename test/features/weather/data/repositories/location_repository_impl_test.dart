import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nimbus/core/error/failures.dart';
import 'package:nimbus/core/utils/result.dart';
import 'package:nimbus/features/weather/data/datasources/device_location_data_source.dart';
import 'package:nimbus/features/weather/data/repositories/location_repository_impl.dart';
import 'package:nimbus/features/weather/domain/entities/city.dart';

class _MockDevice extends Mock implements DeviceLocationDataSource {}

void main() {
  late _MockDevice device;
  late LocationRepositoryImpl repository;

  final position = Position(
    latitude: 23.0225,
    longitude: 72.5714,
    timestamp: DateTime(2026, 9, 24),
    accuracy: 100,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );

  setUp(() {
    device = _MockDevice();
    repository = LocationRepositoryImpl(device);
    when(() => device.isServiceEnabled()).thenAnswer((_) async => true);
    when(
      () => device.checkPermission(),
    ).thenAnswer((_) async => LocationPermission.whileInUse);
    when(() => device.currentPosition()).thenAnswer((_) async => position);
    when(() => device.placemarkAt(any(), any())).thenAnswer(
      (_) async => const Placemark(
        locality: 'Ahmedabad',
        administrativeArea: 'Gujarat',
        country: 'India',
        isoCountryCode: 'IN',
      ),
    );
  });

  Future<Failure> expectFailure() async {
    final result = await repository.getCurrentCity();
    expect(result, isA<Err<City>>());
    return (result as Err<City>).failure;
  }

  test('resolves the position to a named city', () async {
    final result = await repository.getCurrentCity();

    expect(
      (result as Ok<City>).value,
      const City(
        name: 'Ahmedabad',
        region: 'Gujarat',
        country: 'India',
        countryCode: 'IN',
        latitude: 23.0225,
        longitude: 72.5714,
        isCurrentLocation: true,
      ),
    );
  });

  test('falls back to coordinates when reverse geocoding fails', () async {
    when(
      () => device.placemarkAt(any(), any()),
    ).thenThrow(PlatformException(code: 'IO_ERROR'));

    final city = (await repository.getCurrentCity() as Ok<City>).value;

    expect(city.name, '23.02°, 72.57°');
    expect(city.isCurrentLocation, isTrue);
  });

  test('fails when location services are off', () async {
    when(() => device.isServiceEnabled()).thenAnswer((_) async => false);

    expect(
      await expectFailure(),
      const LocationFailure(LocationFailureReason.serviceDisabled),
    );
    verifyNever(() => device.checkPermission());
  });

  test('asks for permission when it has not been granted yet', () async {
    when(
      () => device.checkPermission(),
    ).thenAnswer((_) async => LocationPermission.denied);
    when(
      () => device.requestPermission(),
    ).thenAnswer((_) async => LocationPermission.whileInUse);

    expect(await repository.getCurrentCity(), isA<Ok<City>>());
    verify(() => device.requestPermission()).called(1);
  });

  test('fails when the user denies the permission prompt', () async {
    when(
      () => device.checkPermission(),
    ).thenAnswer((_) async => LocationPermission.denied);
    when(
      () => device.requestPermission(),
    ).thenAnswer((_) async => LocationPermission.denied);

    expect(
      await expectFailure(),
      const LocationFailure(LocationFailureReason.permissionDenied),
    );
  });

  test('fails without prompting when permission is blocked', () async {
    when(
      () => device.checkPermission(),
    ).thenAnswer((_) async => LocationPermission.deniedForever);

    expect(
      await expectFailure(),
      const LocationFailure(LocationFailureReason.permissionDeniedForever),
    );
    verifyNever(() => device.requestPermission());
  });

  test('fails as unavailable when no fix arrives in time', () async {
    when(() => device.currentPosition()).thenThrow(TimeoutException('gps'));

    expect(
      await expectFailure(),
      const LocationFailure(LocationFailureReason.unavailable),
    );
  });

  test('opens the settings screen that matches the failure', () async {
    when(() => device.openLocationSettings()).thenAnswer((_) async => true);
    when(() => device.openAppSettings()).thenAnswer((_) async => true);

    await repository.openSettings(LocationFailureReason.serviceDisabled);
    await repository.openSettings(
      LocationFailureReason.permissionDeniedForever,
    );

    verify(() => device.openLocationSettings()).called(1);
    verify(() => device.openAppSettings()).called(1);
  });
}
