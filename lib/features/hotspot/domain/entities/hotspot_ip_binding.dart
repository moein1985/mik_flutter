import 'package:equatable/equatable.dart';

/// Represents a HotSpot IP Binding
/// IP Bindings allow bypassing hotspot authentication for specific MAC/IP addresses
class HotspotIpBinding extends Equatable {
  final String id;
  final String? mac;             // MAC address
  final String? address;         // IP address to assign
  final String? toAddress;       // Translate to this address
  final String? server;          // Hotspot server name
  final String type;             // regular, bypassed, blocked
  final String? comment;
  final bool disabled;

  const HotspotIpBinding({
    required this.id,
    this.mac,
    this.address,
    this.toAddress,
    this.server,
    required this.type,
    this.comment,
    required this.disabled,
  });

  @override
  List<Object?> get props => [
        id,
        mac,
        address,
        toAddress,
        server,
        type,
        comment,
        disabled,
      ];
  
  /// Returns true if this binding bypasses authentication
  bool get isBypassed => type == 'bypassed';
  
  /// Returns true if this binding blocks the client
  bool get isBlocked => type == 'blocked';
}
