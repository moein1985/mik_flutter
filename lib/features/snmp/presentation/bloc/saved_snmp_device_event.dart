import 'package:equatable/equatable.dart';
import '../../domain/entities/saved_snmp_device.dart';

abstract class SavedSnmpDeviceEvent extends Equatable {
  const SavedSnmpDeviceEvent();

  @override
  List<Object?> get props => [];
}

class LoadSavedDevices extends SavedSnmpDeviceEvent {
  const LoadSavedDevices();
}

class SaveDevice extends SavedSnmpDeviceEvent {
  final String name;
  final String host;
  final int port;
  final String community;
  final DeviceVendor proprietary;
  final bool isDefault;

  const SaveDevice({
    required this.name,
    required this.host,
    required this.port,
    required this.community,
    required this.proprietary,
    this.isDefault = false,
  });

  @override
  List<Object?> get props => [name, host, port, community, proprietary, isDefault];
}

class UpdateDevice extends SavedSnmpDeviceEvent {
  final SavedSnmpDevice device;

  const UpdateDevice(this.device);

  @override
  List<Object?> get props => [device];
}

class DeleteDevice extends SavedSnmpDeviceEvent {
  final int id;

  const DeleteDevice(this.id);

  @override
  List<Object?> get props => [id];
}

class SetDefaultDevice extends SavedSnmpDeviceEvent {
  final int id;

  const SetDefaultDevice(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadDefaultDevice extends SavedSnmpDeviceEvent {
  const LoadDefaultDevice();
}
