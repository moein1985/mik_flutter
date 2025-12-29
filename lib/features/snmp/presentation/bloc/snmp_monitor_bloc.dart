import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/device_info.dart';
import '../../domain/entities/interface_info.dart';
import '../../domain/usecases/get_device_info_usecase.dart';
import '../../domain/usecases/get_interface_status_usecase.dart';
import 'snmp_monitor_event.dart';
import 'snmp_monitor_state.dart';

class SnmpMonitorBloc extends Bloc<SnmpMonitorEvent, SnmpMonitorState> {
  final GetDeviceInfoUseCase getDeviceInfoUseCase;
  final GetInterfaceStatusUseCase getInterfaceStatusUseCase;

  SnmpMonitorBloc({
    required this.getDeviceInfoUseCase,
    required this.getInterfaceStatusUseCase,
  }) : super(const SnmpMonitorInitial()) {
    on<FetchDataRequested>(_onFetchDataRequested);
    on<FetchCancelled>(_onFetchCancelled);
    on<DataCleared>(_onDataCleared);
  }

  Future<void> _onFetchDataRequested(
    FetchDataRequested event,
    Emitter<SnmpMonitorState> emit,
  ) async {
    emit(const SnmpMonitorLoading());

    try {
      final results = await Future.wait([
        getDeviceInfoUseCase(event.ip, event.community, event.port),
        getInterfaceStatusUseCase(event.ip, event.community, event.port),
      ]);

      final deviceInfoResult = results[0];
      final interfacesResult = results[1];

      deviceInfoResult.fold(
        (failure) => emit(SnmpMonitorFailure(message: failure.message)),
        (deviceInfo) {
          interfacesResult.fold(
            (failure) => emit(SnmpMonitorFailure(message: failure.message)),
            (interfaces) => emit(SnmpMonitorSuccess(
              deviceInfo: deviceInfo as DeviceInfo,
              interfaces: interfaces as List<InterfaceInfo>,
            )),
          );
        },
      );
    } catch (e) {
      emit(SnmpMonitorFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  void _onFetchCancelled(
    FetchCancelled event,
    Emitter<SnmpMonitorState> emit,
  ) {
    getDeviceInfoUseCase.cancelOperation();
    getInterfaceStatusUseCase.cancelOperation();
    emit(const SnmpMonitorInitial());
  }

  void _onDataCleared(
    DataCleared event,
    Emitter<SnmpMonitorState> emit,
  ) {
    emit(const SnmpMonitorInitial());
  }
}
