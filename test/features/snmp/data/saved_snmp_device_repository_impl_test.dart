import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hsmik/features/snmp/data/datasources/saved_snmp_device_local_data_source.dart';
import 'package:hsmik/features/snmp/data/models/saved_snmp_device_model.dart';
import 'package:hsmik/features/snmp/data/repositories/saved_snmp_device_repository_impl.dart';
import 'package:hsmik/features/snmp/domain/entities/saved_snmp_device.dart';
import 'package:hsmik/core/errors/failures.dart';

class MockSavedSnmpDeviceLocalDataSource extends Mock
    implements SavedSnmpDeviceLocalDataSource {}

void main() {
  late SavedSnmpDeviceRepositoryImpl repository;
  late MockSavedSnmpDeviceLocalDataSource mockLocal;

  final now = DateTime.parse('2020-01-01T12:00:00Z');

  final sampleModel = SavedSnmpDeviceModel(
    id: 1,
    name: 'Device 1',
    host: '192.168.0.1',
    port: 161,
    community: 'public',
    proprietary: DeviceVendor.general,
    isDefault: false,
    lastConnected: null,
    createdAt: now,
    updatedAt: now,
  );

  final sampleEntity = SavedSnmpDeviceModel.fromEntity(sampleModel);

  setUpAll(() {
    registerFallbackValue(sampleModel);
  });

  setUp(() {
    mockLocal = MockSavedSnmpDeviceLocalDataSource();
    repository = SavedSnmpDeviceRepositoryImpl(mockLocal);
  });

  group('getAllDevices', () {
    test('returns list when local data source succeeds', () async {
      when(() => mockLocal.getAllDevices()).thenAnswer((_) async => [sampleModel]);

      final res = await repository.getAllDevices();

      expect(res.isRight(), true);
      expect(res | [], [sampleModel]);
    });

    test('returns DatabaseFailure when local data source throws', () async {
      when(() => mockLocal.getAllDevices()).thenThrow(Exception('db error'));

      final res = await repository.getAllDevices();

      expect(res.isLeft(), true);
      res.fold((l) => expect(l, isA<DatabaseFailure>()), (_) => null);
    });
  });

  group('getDeviceById', () {
    test('returns device when found', () async {
      when(() => mockLocal.getDeviceById(1)).thenAnswer((_) async => sampleModel);

      final res = await repository.getDeviceById(1);

      expect(res.isRight(), true);
      expect(res | sampleModel, sampleModel);
    });

    test('returns DatabaseFailure when not found', () async {
      when(() => mockLocal.getDeviceById(2)).thenAnswer((_) async => null);

      final res = await repository.getDeviceById(2);

      expect(res.isLeft(), true);
      res.fold((l) => expect(l, isA<DatabaseFailure>()), (_) => null);
    });

    test('returns DatabaseFailure when underlying throws', () async {
      when(() => mockLocal.getDeviceById(1)).thenThrow(Exception('db'));

      final res = await repository.getDeviceById(1);

      expect(res.isLeft(), true);
      res.fold((l) => expect(l, isA<DatabaseFailure>()), (_) => null);
    });
  });

  group('saveDevice', () {
    test('returns Left if device already exists', () async {
      when(() => mockLocal.deviceExists(any(), any(), any()))
          .thenAnswer((_) async => true);

      final res = await repository.saveDevice(sampleEntity);

      expect(res.isLeft(), true);
      res.fold((l) => expect(l, isA<DatabaseFailure>()), (_) => null);
    });

    test('saves and returns saved device when not exists', () async {
      when(() => mockLocal.deviceExists(any(), any(), any()))
          .thenAnswer((_) async => false);
      when(() => mockLocal.saveDevice(any()))
          .thenAnswer((_) async => SavedSnmpDeviceModel.fromEntity(sampleModel.copyWith(id: 5)));

      final res = await repository.saveDevice(sampleEntity);

      expect(res.isRight(), true);
      res.fold((_) => null, (r) => expect(r.id, 5));
    });

    test('returns DatabaseFailure when underlying throws', () async {
      when(() => mockLocal.deviceExists(any(), any(), any()))
          .thenAnswer((_) async => false);
      when(() => mockLocal.saveDevice(any())).thenThrow(Exception('db'));

      final res = await repository.saveDevice(sampleEntity);

      expect(res.isLeft(), true);
      res.fold((l) => expect(l, isA<DatabaseFailure>()), (_) => null);
    });
  });

  group('updateDevice', () {
    test('returns Left if id is null', () async {
      final withoutId = sampleEntity.copyWith(id: null);

      final res = await repository.updateDevice(withoutId);

      expect(res.isLeft(), true);
      res.fold((l) => expect(l, isA<DatabaseFailure>()), (_) => null);
    });

    test('updates and returns device when id present', () async {
      when(() => mockLocal.updateDevice(any()))
          .thenAnswer((_) async => SavedSnmpDeviceModel.fromEntity(sampleModel.copyWith(name: 'Updated')));

      final res = await repository.updateDevice(sampleEntity);

      expect(res.isRight(), true);
      res.fold((_) => null, (r) => expect(r.name, 'Updated'));
    });

    test('returns DatabaseFailure when underlying throws', () async {
      when(() => mockLocal.updateDevice(any())).thenThrow(Exception('db'));

      final res = await repository.updateDevice(sampleEntity);

      expect(res.isLeft(), true);
      res.fold((l) => expect(l, isA<DatabaseFailure>()), (_) => null);
    });
  });

  group('deleteDevice', () {
    test('returns Right(true) on successful delete', () async {
      when(() => mockLocal.deleteDevice(1)).thenAnswer((_) async => true);

      final res = await repository.deleteDevice(1);

      expect(res.isRight(), true);
      res.fold((_) => null, (r) => expect(r, true));
    });

    test('returns DatabaseFailure when underlying throws', () async {
      when(() => mockLocal.deleteDevice(1)).thenThrow(Exception('db'));

      final res = await repository.deleteDevice(1);

      expect(res.isLeft(), true);
      res.fold((l) => expect(l, isA<DatabaseFailure>()), (_) => null);
    });
  });

  group('setDefaultDevice', () {
    test('returns Right(null) on success', () async {
      when(() => mockLocal.setDefaultDevice(1)).thenAnswer((_) async => Future.value());

      final res = await repository.setDefaultDevice(1);

      expect(res.isRight(), true);
    });

    test('returns DatabaseFailure when underlying throws', () async {
      when(() => mockLocal.setDefaultDevice(1)).thenThrow(Exception('db'));

      final res = await repository.setDefaultDevice(1);

      expect(res.isLeft(), true);
      res.fold((l) => expect(l, isA<DatabaseFailure>()), (_) => null);
    });
  });

  group('updateLastConnected', () {
    test('returns Right(null) on success', () async {
      when(() => mockLocal.updateLastConnected(1)).thenAnswer((_) async => Future.value());

      final res = await repository.updateLastConnected(1);

      expect(res.isRight(), true);
    });

    test('returns DatabaseFailure when underlying throws', () async {
      when(() => mockLocal.updateLastConnected(1)).thenThrow(Exception('db'));

      final res = await repository.updateLastConnected(1);

      expect(res.isLeft(), true);
      res.fold((l) => expect(l, isA<DatabaseFailure>()), (_) => null);
    });
  });

  group('deviceExists', () {
    test('returns Right(true) when exists', () async {
      when(() => mockLocal.deviceExists('h', 1, 'c')).thenAnswer((_) async => true);

      final res = await repository.deviceExists('h', 1, 'c');

      expect(res.isRight(), true);
      res.fold((_) => null, (r) => expect(r, true));
    });

    test('returns DatabaseFailure when underlying throws', () async {
      when(() => mockLocal.deviceExists('h', 1, 'c')).thenThrow(Exception('db'));

      final res = await repository.deviceExists('h', 1, 'c');

      expect(res.isLeft(), true);
      res.fold((l) => expect(l, isA<DatabaseFailure>()), (_) => null);
    });
  });
}
