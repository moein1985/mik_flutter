import 'package:equatable/equatable.dart';

class HotspotActiveUser extends Equatable {
  final String id;
  final String user;
  final String server;
  final String address;
  final String macAddress;
  final String loginBy;
  final String uptime;
  final String sessionTimeLeft;
  final String idleTime;
  final String bytesIn;
  final String bytesOut;
  final String packetsIn;
  final String packetsOut;

  const HotspotActiveUser({
    required this.id,
    required this.user,
    required this.server,
    required this.address,
    required this.macAddress,
    required this.loginBy,
    required this.uptime,
    required this.sessionTimeLeft,
    required this.idleTime,
    required this.bytesIn,
    required this.bytesOut,
    required this.packetsIn,
    required this.packetsOut,
  });

  @override
  List<Object?> get props => [
        id,
        user,
        server,
        address,
        macAddress,
        loginBy,
        uptime,
        sessionTimeLeft,
        idleTime,
        bytesIn,
        bytesOut,
        packetsIn,
        packetsOut,
      ];
}
