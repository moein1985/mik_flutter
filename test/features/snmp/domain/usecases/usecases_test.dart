import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hsmik/features/snmp/domain/usecases/get_all_devices_usecase.dart';
import 'package:hsmik/features/snmp/domain/usecases/save_device_usecase.dart';
import 'package:hsmik/features/snmp/domain/repositories/saved_snmp_device_repository.dart';
import 'package:hsmik/features/snmp/domain/entities/saved_snmp_device.dart';
import 'package:hsmik/core/errors/failures.dart';

class MockRepository extends Mock implements SavedSnmpDeviceRepository {}

void main() {
  late MockRepository mockRepo;
  late GetAllDevicesUseCase getAll;
  late SaveDeviceUseCase saveUse;

  final now = DateTime.parse('2020-01-01T12:00:00Z');
  final device = SavedSnmpDevice.create(
    name: 'd',
    host: 'h',
    port: 161,
    community: 'c',
  ).copyWith(createdAt: now, updatedAt: now);

  setUp(() {
    mockRepo = MockRepository();
    getAll = GetAllDevicesUseCase(mockRepo);
    saveUse = SaveDeviceUseCase(mockRepo);
  });

  test('GetAllDevicesUseCase forwards repository result', () async {
    when(() => mockRepo.getAllDevices())
        .thenAnswer((_) async => Right([device]));

    final res = await getAll();

    expect(res.isRight(), true);
  });

  test('SaveDeviceUseCase forwards repository result', () async {
    when(() => mockRepo.saveDevice(device))
        .thenAnswer((_) async => Right(device));

    final res = await saveUse(device);

    expect(res.isRight(), true);
  });
}
