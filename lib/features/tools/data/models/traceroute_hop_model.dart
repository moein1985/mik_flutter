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

  /// Create model from RouterOS traceroute response with hop index
  factory TracerouteHopModel.fromRouterOS(Map<String, String> data, int hopIndex) {
    final ipAddress = data['address'];
    final hostname = data['name'];
    final status = data['status'];

    // RouterOS returns RTT values as: best, avg, worst, last (all in milliseconds as numbers)
    Duration? rtt1, rtt2, rtt3;

    // Use 'best', 'avg', 'worst' fields (they are millisecond values without suffix)
    if (data.containsKey('best') && data['best'] != null && data['best']!.isNotEmpty) {
      rtt1 = _parseMilliseconds(data['best']!);
    }
    if (data.containsKey('avg') && data['avg'] != null && data['avg']!.isNotEmpty) {
      rtt2 = _parseMilliseconds(data['avg']!);
    }
    if (data.containsKey('worst') && data['worst'] != null && data['worst']!.isNotEmpty) {
      rtt3 = _parseMilliseconds(data['worst']!);
    }

    // Determine if hop is reachable
    final isReachable = ipAddress != null && ipAddress.isNotEmpty &&
                       (rtt1 != null || rtt2 != null || rtt3 != null);

    return TracerouteHopModel(
      hopNumber: hopIndex + 1, // Hop numbers start from 1
      ipAddress: ipAddress?.isNotEmpty == true ? ipAddress : null,
      hostname: hostname?.isNotEmpty == true ? hostname : null,
      rtt1: rtt1,
      rtt2: rtt2,
      rtt3: rtt3,
      isReachable: isReachable,
      status: status?.isNotEmpty == true ? status : null,
    );
  }

  /// Parse milliseconds value (can be integer or decimal like "0.3", "1", "10.5")
  static Duration? _parseMilliseconds(String value) {
    final ms = double.tryParse(value);
    if (ms == null) return null;
    return Duration(microseconds: (ms * 1000).round());
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