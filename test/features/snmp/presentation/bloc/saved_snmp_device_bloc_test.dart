import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hsmik/features/snmp/domain/entities/saved_snmp_device.dart';
import 'package:hsmik/features/snmp/data/models/saved_snmp_device_model.dart';
import 'package:hsmik/features/snmp/domain/usecases/delete_device_usecase.dart';
import 'package:hsmik/features/snmp/domain/usecases/get_all_devices_usecase.dart';
import 'package:hsmik/features/snmp/domain/usecases/get_default_device_usecase.dart';
import 'package:hsmik/features/snmp/domain/usecases/save_device_usecase.dart';
import 'package:hsmik/features/snmp/domain/usecases/set_default_device_usecase.dart';
import 'package:hsmik/features/snmp/domain/usecases/update_device_usecase.dart';
import 'package:hsmik/features/snmp/presentation/bloc/saved_snmp_device_bloc.dart';
import 'package:hsmik/features/snmp/presentation/bloc/saved_snmp_device_event.dart';
import 'package:hsmik/features/snmp/presentation/bloc/saved_snmp_device_state.dart';
import 'package:hsmik/core/errors/failures.dart';

class MockGetAll extends Mock implements GetAllDevicesUseCase {}
class MockGetDefault extends Mock implements GetDefaultDeviceUseCase {}
class MockSave extends Mock implements SaveDeviceUseCase {}
class MockUpdate extends Mock implements UpdateDeviceUseCase {}
class MockDelete extends Mock implements DeleteDeviceUseCase {}
class MockSetDefault extends Mock implements SetDefaultDeviceUseCase {}

void main() {
  late SavedSnmpDeviceBloc bloc;
  late MockGetAll mockGetAll;
  late MockGetDefault mockGetDefault;
  late MockSave mockSave;
  late MockUpdate mockUpdate;
  late MockDelete mockDelete;
  late MockSetDefault mockSetDefault;

  final now = DateTime.parse('2020-01-01T12:00:00Z');
  final device = SavedSnmpDeviceModel(
    id: 1,
    name: 'Dev',
    host: '10.0.0.1',
    port: 161,
    community: 'public',
    proprietary: DeviceVendor.general,
    isDefault: false,
    lastConnected: null,
    createdAt: now,
    updatedAt: now,
  );

  setUpAll(() {
    registerFallbackValue(device);
  });

  setUp(() {
    mockGetAll = MockGetAll();
    mockGetDefault = MockGetDefault();
    mockSave = MockSave();
    mockUpdate = MockUpdate();
    mockDelete = MockDelete();
    mockSetDefault = MockSetDefault();

    // Provide a default return for getDefault to avoid null Futures in tests
    when(() => mockGetDefault()).thenAnswer((_) async => const Right(null));

    bloc = SavedSnmpDeviceBloc(
      getAllDevicesUseCase: mockGetAll,
      getDefaultDeviceUseCase: mockGetDefault,
      saveDeviceUseCase: mockSave,
      updateDeviceUseCase: mockUpdate,
      deleteDeviceUseCase: mockDelete,
      setDefaultDeviceUseCase: mockSetDefault,
    );
  });

  test('initial state is SavedSnmpDeviceInitial', () {
    expect(bloc.state, const SavedSnmpDeviceInitial());
  });

  blocTest<SavedSnmpDeviceBloc, SavedSnmpDeviceState>(
    'emits [Loading, Loaded] when LoadSavedDevices succeeds',
    build: () {
      when(() => mockGetAll()).thenAnswer((_) async => Right([device]));
      when(() => mockGetDefault()).thenAnswer((_) async => Right(device));
      return bloc;
    },
    act: (b) => b.add(const LoadSavedDevices()),
    expect: () => [
      const SavedSnmpDeviceLoading(),
      SavedSnmpDeviceLoaded(devices: [device], defaultDevice: device),
    ],
  );

  blocTest<SavedSnmpDeviceBloc, SavedSnmpDeviceState>(
    'emits [Loading, Error] when getAllDevices fails',
    build: () {
      when(() => mockGetAll()).thenAnswer((_) async => Left(DatabaseFailure('fail')));
      return bloc;
    },
    act: (b) => b.add(const LoadSavedDevices()),
    expect: () => [
      const SavedSnmpDeviceLoading(),
      isA<SavedSnmpDeviceError>(),
    ],
  );

  blocTest<SavedSnmpDeviceBloc, SavedSnmpDeviceState>(
    'emits [Loading, OperationSuccess] when SaveDevice succeeds',
    build: () {
      when(() => mockSave(any())).thenAnswer((_) async => Right(device));
      when(() => mockGetAll()).thenAnswer((_) async => Right([device]));
      return bloc;
    },
    act: (b) => b.add(const SaveDevice(name: 'Dev', host: '10.0.0.1', port: 161, community: 'public', proprietary: DeviceVendor.general)),
    expect: () => [
      const SavedSnmpDeviceLoading(),
      isA<SavedSnmpDeviceOperationSuccess>(),
    ],
  );

  blocTest<SavedSnmpDeviceBloc, SavedSnmpDeviceState>(
    'emits [Loading, Error] when SaveDevice fails',
    build: () {
      when(() => mockSave(any())).thenAnswer((_) async => Left(DatabaseFailure('fail')));
      return bloc;
    },
    act: (b) => b.add(const SaveDevice(name: 'Dev', host: '10.0.0.1', port: 161, community: 'public', proprietary: DeviceVendor.general)),
    expect: () => [
      const SavedSnmpDeviceLoading(),
      isA<SavedSnmpDeviceError>(),
    ],
  );

  blocTest<SavedSnmpDeviceBloc, SavedSnmpDeviceState>(
    'emits [Loading, OperationSuccess] when UpdateDevice succeeds',
    build: () {
      when(() => mockUpdate(any())).thenAnswer((_) async => Right(device));
      when(() => mockGetAll()).thenAnswer((_) async => Right([device]));
      return bloc;
    },
    act: (b) => b.add(UpdateDevice(device)),
    expect: () => [
      const SavedSnmpDeviceLoading(),
      isA<SavedSnmpDeviceOperationSuccess>(),
    ],
  );

  blocTest<SavedSnmpDeviceBloc, SavedSnmpDeviceState>(
    'emits [Loading, Error] when UpdateDevice fails',
    build: () {
      when(() => mockUpdate(any())).thenAnswer((_) async => Left(DatabaseFailure('fail')));
      return bloc;
    },
    act: (b) => b.add(UpdateDevice(device)),
    expect: () => [
      const SavedSnmpDeviceLoading(),
      isA<SavedSnmpDeviceError>(),
    ],
  );

  blocTest<SavedSnmpDeviceBloc, SavedSnmpDeviceState>(
    'emits [Loading, OperationSuccess] when DeleteDevice succeeds',
    build: () {
      when(() => mockDelete(1)).thenAnswer((_) async => Right(true));
      when(() => mockGetAll()).thenAnswer((_) async => Right(<SavedSnmpDevice>[]));
      return bloc;
    },
    act: (b) => b.add(const DeleteDevice(1)),
    expect: () => [
      const SavedSnmpDeviceLoading(),
      isA<SavedSnmpDeviceOperationSuccess>(),
    ],
  );

  blocTest<SavedSnmpDeviceBloc, SavedSnmpDeviceState>(
    'emits [Loading, Error] when DeleteDevice fails (repo returns false)',
    build: () {
      when(() => mockDelete(1)).thenAnswer((_) async => Right(false));
      return bloc;
    },
    act: (b) => b.add(const DeleteDevice(1)),
    expect: () => [
      const SavedSnmpDeviceLoading(),
      const SavedSnmpDeviceError('Failed to delete device'),
    ],
  );

  blocTest<SavedSnmpDeviceBloc, SavedSnmpDeviceState>(
    'emits [Loading, Error] when DeleteDevice throws',
    build: () {
      when(() => mockDelete(1)).thenAnswer((_) async => Left(DatabaseFailure('fail')));
      return bloc;
    },
    act: (b) => b.add(const DeleteDevice(1)),
    expect: () => [
      const SavedSnmpDeviceLoading(),
      isA<SavedSnmpDeviceError>(),
    ],
  );

  blocTest<SavedSnmpDeviceBloc, SavedSnmpDeviceState>(
    'emits [Loading, OperationSuccess] when SetDefaultDevice succeeds',
    build: () {
      when(() => mockSetDefault(1)).thenAnswer((_) async => const Right(null));
      when(() => mockGetAll()).thenAnswer((_) async => Right([device]));
      return bloc;
    },
    act: (b) => b.add(const SetDefaultDevice(1)),
    expect: () => [
      const SavedSnmpDeviceLoading(),
      isA<SavedSnmpDeviceOperationSuccess>(),
    ],
  );

  group('LoadDefaultDevice event', () {
    test('updates Loaded state with defaultDevice when called', () async {
      when(() => mockGetDefault()).thenAnswer((_) async => Right(device));

      // set initial state to Loaded
      bloc.emit(SavedSnmpDeviceLoaded(devices: [device]));

      bloc.add(const LoadDefaultDevice());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          SavedSnmpDeviceLoaded(devices: [device], defaultDevice: device),
        ]),
      );
    });
  });
}
