import 'package:equatable/equatable.dart';
import '../../domain/entities/saved_snmp_device.dart';

abstract class SavedSnmpDeviceState extends Equatable {
  const SavedSnmpDeviceState();

  @override
  List<Object?> get props => [];
}

class SavedSnmpDeviceInitial extends SavedSnmpDeviceState {
  const SavedSnmpDeviceInitial();
}

class SavedSnmpDeviceLoading extends SavedSnmpDeviceState {
  const SavedSnmpDeviceLoading();
}

class SavedSnmpDeviceLoaded extends SavedSnmpDeviceState {
  final List<SavedSnmpDevice> devices;
  final SavedSnmpDevice? defaultDevice;

  const SavedSnmpDeviceLoaded({
    required this.devices,
    this.defaultDevice,
  });

  @override
  List<Object?> get props => [devices, defaultDevice];
}

class SavedSnmpDeviceError extends SavedSnmpDeviceState {
  final String message;

  const SavedSnmpDeviceError(this.message);

  @override
  List<Object?> get props => [message];
}

class SavedSnmpDeviceOperationSuccess extends SavedSnmpDeviceState {
  final String message;
  final List<SavedSnmpDevice> devices;

  const SavedSnmpDeviceOperationSuccess({
    required this.message,
    required this.devices,
  });

  @override
  List<Object?> get props => [message, devices];
}
