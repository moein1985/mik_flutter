import 'package:equatable/equatable.dart';

/// Represents a HotSpot Host (connected device)
/// Hosts are devices that are currently or were connected to the hotspot
class HotspotHost extends Equatable {
  final String id;
  final String macAddress;
  final String? address;         // IP address
  final String? toAddress;       // Translated IP
  final String? server;          // Hotspot server name
  final bool authorized;         // Is authenticated
  final bool bypassed;           // Bypasses authentication
  final String? comment;
  
  // Connection info
  final String? uptime;
  final String? idleTime;
  final String? keepaliveTimeout;
  final String? loginBy;         // How the user logged in
  
  // Traffic statistics
  final String? bytesIn;
  final String? bytesOut;
  final String? packetsIn;
  final String? packetsOut;
  
  // Identification
  final String? macBrand;        // Device manufacturer
  final String? hostName;
  
  // Optional RADIUS info
  final String? radiusResponse;

  const HotspotHost({
    required this.id,
    required this.macAddress,
    this.address,
    this.toAddress,
    this.server,
    required this.authorized,
    required this.bypassed,
    this.comment,
    this.uptime,
    this.idleTime,
    this.keepaliveTimeout,
    this.loginBy,
    this.bytesIn,
    this.bytesOut,
    this.packetsIn,
    this.packetsOut,
    this.macBrand,
    this.hostName,
    this.radiusResponse,
  });

  @override
  List<Object?> get props => [
        id,
        macAddress,
        address,
        toAddress,
        server,
        authorized,
        bypassed,
        comment,
        uptime,
        idleTime,
        keepaliveTimeout,
        loginBy,
        bytesIn,
        bytesOut,
        packetsIn,
        packetsOut,
        macBrand,
        hostName,
        radiusResponse,
      ];
  
  /// Returns true if host has traffic statistics
  bool get hasTraffic =>
      (bytesIn != null && bytesIn != '0') ||
      (bytesOut != null && bytesOut != '0');
  
  /// Returns display name (hostname or MAC)
  String get displayName => hostName ?? macAddress;
}
