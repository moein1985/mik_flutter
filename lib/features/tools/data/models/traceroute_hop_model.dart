import '../../domain/entities/traceroute_hop.dart';

/// Model for traceroute hop data from RouterOS API
class TracerouteHopModel extends TracerouteHop {
  const TracerouteHopModel({
    required super.hopNumber,
    super.ipAddress,
    super.hostname,
    super.rtt1,
    super.rtt2,
    super.rtt3,
    super.isReachable,
    super.status,
  });

  /// Create model from RouterOS traceroute response
  factory TracerouteHopModel.fromRouterOS(Map<String, String> data) {
    final hopNumber = int.tryParse(data['hop'] ?? '') ?? 0;
    final ipAddress = data['address'];
    final hostname = data['name'];
    final status = data['status'];

    // Parse RTT values (they come as strings like "10ms", "1.5s", etc.)
    Duration? rtt1, rtt2, rtt3;

    if (data.containsKey('rtt1') && data['rtt1'] != null) {
      rtt1 = _parseDuration(data['rtt1']!);
    }
    if (data.containsKey('rtt2') && data['rtt2'] != null) {
      rtt2 = _parseDuration(data['rtt2']!);
    }
    if (data.containsKey('rtt3') && data['rtt3'] != null) {
      rtt3 = _parseDuration(data['rtt3']!);
    }

    // Determine if hop is reachable
    final isReachable = ipAddress != null && ipAddress.isNotEmpty &&
                       (rtt1 != null || rtt2 != null || rtt3 != null);

    return TracerouteHopModel(
      hopNumber: hopNumber,
      ipAddress: ipAddress,
      hostname: hostname,
      rtt1: rtt1,
      rtt2: rtt2,
      rtt3: rtt3,
      isReachable: isReachable,
      status: status,
    );
  }

  /// Parse duration string like "410us", "10ms", "95ms894us" or "1.5s" to Duration
  static Duration _parseDuration(String durationStr) {
    // Handle RouterOS format: "95ms894us" (milliseconds + microseconds)
    if (durationStr.contains('ms') && durationStr.contains('us')) {
      final parts = durationStr.split('ms');
      final ms = int.tryParse(parts[0]) ?? 0;
      final us = int.tryParse(parts[1].replaceAll('us', '')) ?? 0;
      return Duration(microseconds: ms * 1000 + us);
    }
    // Handle microseconds only: "410us"
    else if (durationStr.endsWith('us')) {
      final us = int.tryParse(durationStr.substring(0, durationStr.length - 2)) ?? 0;
      return Duration(microseconds: us);
    }
    // Handle milliseconds: "10ms"
    else if (durationStr.endsWith('ms')) {
      final ms = double.tryParse(durationStr.substring(0, durationStr.length - 2)) ?? 0;
      return Duration(microseconds: (ms * 1000).round());
    }
    // Handle seconds: "1.5s"
    else if (durationStr.endsWith('s')) {
      final s = double.tryParse(durationStr.substring(0, durationStr.length - 1)) ?? 0;
      return Duration(microseconds: (s * 1000000).round());
    }
    // Assume milliseconds if no unit
    else {
      final ms = double.tryParse(durationStr) ?? 0;
      return Duration(microseconds: (ms * 1000).round());
    }
  }

  /// Convert to entity
  TracerouteHop toEntity() {
    return TracerouteHop(
      hopNumber: hopNumber,
      ipAddress: ipAddress,
      hostname: hostname,
      rtt1: rtt1,
      rtt2: rtt2,
      rtt3: rtt3,
      isReachable: isReachable,
      status: status,
    );
  }
}