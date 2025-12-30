import 'package:equatable/equatable.dart';
import '../../domain/entities/device_info.dart';
import '../../domain/entities/interface_info.dart';
import '../../data/models/cisco_device_info_model.dart';
import '../../data/models/microsoft_device_info_model.dart';
import '../../data/models/asterisk_device_info_model.dart';

abstract class SnmpMonitorState extends Equatable {
  const SnmpMonitorState();

  @override
  List<Object?> get props => [];
}

class SnmpMonitorInitial extends SnmpMonitorState {
  const SnmpMonitorInitial();
}

class SnmpMonitorLoading extends SnmpMonitorState {
  const SnmpMonitorLoading();
}

class SnmpMonitorSuccess extends SnmpMonitorState {
  final DeviceInfo deviceInfo;
  final List<InterfaceInfo> interfaces;
  final CiscoDeviceInfoModel? ciscoInfo;
  final MicrosoftDeviceInfoModel? microsoftInfo;
  final AsteriskDeviceInfoModel? asteriskInfo;

  const SnmpMonitorSuccess({
    required this.deviceInfo,
    required this.interfaces,
    this.ciscoInfo,
    this.microsoftInfo,
    this.asteriskInfo,
  });

  @override
  List<Object?> get props => [deviceInfo, interfaces, ciscoInfo, microsoftInfo, asteriskInfo];
}

class SnmpMonitorFailure extends SnmpMonitorState {
  final String message;
  final String? failureType;

  const SnmpMonitorFailure({
    required this.message,
    this.failureType,
  });

  @override
  List<Object?> get props => [message, failureType];
}
