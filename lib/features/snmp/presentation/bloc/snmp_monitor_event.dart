import 'package:equatable/equatable.dart';

abstract class SnmpMonitorEvent extends Equatable {
  const SnmpMonitorEvent();

  @override
  List<Object?> get props => [];
}

class FetchDataRequested extends SnmpMonitorEvent {
  final String ip;
  final String community;
  final int port;

  const FetchDataRequested({
    required this.ip,
    required this.community,
    this.port = 161,
  });

  @override
  List<Object?> get props => [ip, community, port];
}

class FetchCancelled extends SnmpMonitorEvent {
  const FetchCancelled();
}

class DataCleared extends SnmpMonitorEvent {
  const DataCleared();
}
