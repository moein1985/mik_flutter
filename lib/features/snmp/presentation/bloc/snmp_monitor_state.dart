import 'package:equatable/equatable.dart';
import '../../domain/entities/device_info.dart';
import '../../domain/entities/interface_info.dart';

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

  const SnmpMonitorSuccess({
    required this.deviceInfo,
    required this.interfaces,
  });

  @override
  List<Object?> get props => [deviceInfo, interfaces];
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
