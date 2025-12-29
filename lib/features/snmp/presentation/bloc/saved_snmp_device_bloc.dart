import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/saved_snmp_device.dart';
import '../../domain/usecases/delete_device_usecase.dart';
import '../../domain/usecases/get_all_devices_usecase.dart';
import '../../domain/usecases/get_default_device_usecase.dart';
import '../../domain/usecases/save_device_usecase.dart';
import '../../domain/usecases/set_default_device_usecase.dart';
import '../../domain/usecases/update_device_usecase.dart';
import 'saved_snmp_device_event.dart';
import 'saved_snmp_device_state.dart';

class SavedSnmpDeviceBloc
    extends Bloc<SavedSnmpDeviceEvent, SavedSnmpDeviceState> {
  final GetAllDevicesUseCase getAllDevicesUseCase;
  final GetDefaultDeviceUseCase getDefaultDeviceUseCase;
  final SaveDeviceUseCase saveDeviceUseCase;
  final UpdateDeviceUseCase updateDeviceUseCase;
  final DeleteDeviceUseCase deleteDeviceUseCase;
  final SetDefaultDeviceUseCase setDefaultDeviceUseCase;

  SavedSnmpDeviceBloc({
    required this.getAllDevicesUseCase,
    required this.getDefaultDeviceUseCase,
    required this.saveDeviceUseCase,
    required this.updateDeviceUseCase,
    required this.deleteDeviceUseCase,
    required this.setDefaultDeviceUseCase,
  }) : super(const SavedSnmpDeviceInitial()) {
    on<LoadSavedDevices>(_onLoadSavedDevices);
    on<LoadDefaultDevice>(_onLoadDefaultDevice);
    on<SaveDevice>(_onSaveDevice);
    on<UpdateDevice>(_onUpdateDevice);
    on<DeleteDevice>(_onDeleteDevice);
    on<SetDefaultDevice>(_onSetDefaultDevice);
  }

  Future<void> _onLoadSavedDevices(
    LoadSavedDevices event,
    Emitter<SavedSnmpDeviceState> emit,
  ) async {
    emit(const SavedSnmpDeviceLoading());

    final result = await getAllDevicesUseCase();
    final defaultResult = await getDefaultDeviceUseCase();

    result.fold(
      (failure) => emit(SavedSnmpDeviceError(failure.message)),
      (devices) {
        defaultResult.fold(
          (failure) => emit(SavedSnmpDeviceLoaded(devices: devices)),
          (defaultDevice) => emit(SavedSnmpDeviceLoaded(
            devices: devices,
            defaultDevice: defaultDevice,
          )),
        );
      },
    );
  }

  Future<void> _onLoadDefaultDevice(
    LoadDefaultDevice event,
    Emitter<SavedSnmpDeviceState> emit,
  ) async {
    final result = await getDefaultDeviceUseCase();

    result.fold(
      (failure) => emit(SavedSnmpDeviceError(failure.message)),
      (defaultDevice) {
        if (state is SavedSnmpDeviceLoaded) {
          final currentState = state as SavedSnmpDeviceLoaded;
          emit(SavedSnmpDeviceLoaded(
            devices: currentState.devices,
            defaultDevice: defaultDevice,
          ));
        }
      },
    );
  }

  Future<void> _onSaveDevice(
    SaveDevice event,
    Emitter<SavedSnmpDeviceState> emit,
  ) async {
    emit(const SavedSnmpDeviceLoading());

    final device = SavedSnmpDevice.create(
      name: event.name,
      host: event.host,
      port: event.port,
      community: event.community,
      proprietary: event.proprietary,
      isDefault: event.isDefault,
    );

    final result = await saveDeviceUseCase(device);

    await result.fold(
      (failure) async => emit(SavedSnmpDeviceError(failure.message)),
      (savedDevice) async {
        final devicesResult = await getAllDevicesUseCase();
        devicesResult.fold(
          (failure) => emit(SavedSnmpDeviceError(failure.message)),
          (devices) => emit(SavedSnmpDeviceOperationSuccess(
            message: 'Device saved successfully',
            devices: devices,
          )),
        );
      },
    );
  }

  Future<void> _onUpdateDevice(
    UpdateDevice event,
    Emitter<SavedSnmpDeviceState> emit,
  ) async {
    emit(const SavedSnmpDeviceLoading());

    final result = await updateDeviceUseCase(event.device);

    await result.fold(
      (failure) async => emit(SavedSnmpDeviceError(failure.message)),
      (updatedDevice) async {
        final devicesResult = await getAllDevicesUseCase();
        devicesResult.fold(
          (failure) => emit(SavedSnmpDeviceError(failure.message)),
          (devices) => emit(SavedSnmpDeviceOperationSuccess(
            message: 'Device updated successfully',
            devices: devices,
          )),
        );
      },
    );
  }

  Future<void> _onDeleteDevice(
    DeleteDevice event,
    Emitter<SavedSnmpDeviceState> emit,
  ) async {
    emit(const SavedSnmpDeviceLoading());

    final result = await deleteDeviceUseCase(event.id);

    await result.fold(
      (failure) async => emit(SavedSnmpDeviceError(failure.message)),
      (success) async {
        if (success) {
          final devicesResult = await getAllDevicesUseCase();
          devicesResult.fold(
            (failure) => emit(SavedSnmpDeviceError(failure.message)),
            (devices) => emit(SavedSnmpDeviceOperationSuccess(
              message: 'Device deleted successfully',
              devices: devices,
            )),
          );
        } else {
          emit(const SavedSnmpDeviceError('Failed to delete device'));
        }
      },
    );
  }

  Future<void> _onSetDefaultDevice(
    SetDefaultDevice event,
    Emitter<SavedSnmpDeviceState> emit,
  ) async {
    emit(const SavedSnmpDeviceLoading());

    final result = await setDefaultDeviceUseCase(event.id);

    await result.fold(
      (failure) async => emit(SavedSnmpDeviceError(failure.message)),
      (_) async {
        final devicesResult = await getAllDevicesUseCase();
        devicesResult.fold(
          (failure) => emit(SavedSnmpDeviceError(failure.message)),
          (devices) => emit(SavedSnmpDeviceOperationSuccess(
            message: 'Default device set successfully',
            devices: devices,
          )),
        );
      },
    );
  }
}
