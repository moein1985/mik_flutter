import 'package:equatable/equatable.dart';

/// Entity representing a traceroute hop
class TracerouteHop extends Equatable {
  final int hopNumber;
  final String? ipAddress;
  final String? hostname;
  final Duration? rtt1;
  final Duration? rtt2;
  final Duration? rtt3;
  final bool isReachable;
  final String? status;

  const TracerouteHop({
    required this.hopNumber,
    this.ipAddress,
    this.hostname,
    this.rtt1,
    this.rtt2,
    this.rtt3,
    this.isReachable = false,
    this.status,
  });

  /// Get the minimum RTT from available measurements
  Duration? get minRtt {
    final rtts = [rtt1, rtt2, rtt3].where((rtt) => rtt != null).toList();
    if (rtts.isEmpty) return null;
    return rtts.reduce((a, b) => a!.compareTo(b!) < 0 ? a : b);
  }

  /// Get the average RTT from available measurements
  Duration? get avgRtt {
    final rtts = [rtt1, rtt2, rtt3].where((rtt) => rtt != null).toList();
    if (rtts.isEmpty) return null;
    final total = rtts.fold<Duration>(Duration.zero, (sum, rtt) => sum + rtt!);
    return Duration(microseconds: total.inMicroseconds ~/ rtts.length);
  }

  /// Get the maximum RTT from available measurements
  Duration? get maxRtt {
    final rtts = [rtt1, rtt2, rtt3].where((rtt) => rtt != null).toList();
    if (rtts.isEmpty) return null;
    return rtts.reduce((a, b) => a!.compareTo(b!) > 0 ? a : b);
  }

  /// Check if this hop has any RTT measurements
  bool get hasMeasurements => rtt1 != null || rtt2 != null || rtt3 != null;

  TracerouteHop copyWith({
    int? hopNumber,
    String? ipAddress,
    String? hostname,
    Duration? rtt1,
    Duration? rtt2,
    Duration? rtt3,
    bool? isReachable,
    String? status,
  }) {
    return TracerouteHop(
      hopNumber: hopNumber ?? this.hopNumber,
      ipAddress: ipAddress ?? this.ipAddress,
      hostname: hostname ?? this.hostname,
      rtt1: rtt1 ?? this.rtt1,
      rtt2: rtt2 ?? this.rtt2,
      rtt3: rtt3 ?? this.rtt3,
      isReachable: isReachable ?? this.isReachable,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        hopNumber,
        ipAddress,
        hostname,
        rtt1,
        rtt2,
        rtt3,
        isReachable,
        status,
      ];
}