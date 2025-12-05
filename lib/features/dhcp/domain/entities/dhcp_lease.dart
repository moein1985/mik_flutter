import 'package:equatable/equatable.dart';

class DhcpLease extends Equatable {
  final String id;
  final String address;
  final String macAddress;
  final String? hostName;
  final String? comment;
  final String status;
  final String? expiresAfter;
  final String? server;
  final String? lastSeen;
  final bool dynamic;
  final bool disabled;
  final bool blocked;

  const DhcpLease({
    required this.id,
    required this.address,
    required this.macAddress,
    this.hostName,
    this.comment,
    required this.status,
    this.expiresAfter,
    this.server,
    this.lastSeen,
    required this.dynamic,
    required this.disabled,
    required this.blocked,
  });

  @override
  List<Object?> get props => [
        id,
        address,
        macAddress,
        hostName,
        comment,
        status,
        expiresAfter,
        server,
        lastSeen,
        dynamic,
        disabled,
        blocked,
      ];
}
