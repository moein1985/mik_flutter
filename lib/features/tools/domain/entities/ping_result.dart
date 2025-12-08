import 'package:equatable/equatable.dart';

/// Entity representing a ping result
class PingResult extends Equatable {
  final String target;
  final int packetsSent;
  final int packetsReceived;
  final int packetLossPercent;
  final Duration minRtt;
  final Duration avgRtt;
  final Duration maxRtt;
  final bool isRunning;
  final List<PingPacket> packets;

  const PingResult({
    required this.target,
    required this.packetsSent,
    required this.packetsReceived,
    required this.packetLossPercent,
    required this.minRtt,
    required this.avgRtt,
    required this.maxRtt,
    this.isRunning = false,
    this.packets = const [],
  });

  /// Calculate packet loss percentage
  int get calculatedPacketLossPercent => packetsSent > 0
      ? ((packetsSent - packetsReceived) / packetsSent * 100).round()
      : 0;

  /// Check if ping was successful (at least one packet received)
  bool get isSuccessful => packetsReceived > 0;

  PingResult copyWith({
    String? target,
    int? packetsSent,
    int? packetsReceived,
    int? packetLossPercent,
    Duration? minRtt,
    Duration? avgRtt,
    Duration? maxRtt,
    bool? isRunning,
    List<PingPacket>? packets,
  }) {
    return PingResult(
      target: target ?? this.target,
      packetsSent: packetsSent ?? this.packetsSent,
      packetsReceived: packetsReceived ?? this.packetsReceived,
      packetLossPercent: packetLossPercent ?? this.packetLossPercent,
      minRtt: minRtt ?? this.minRtt,
      avgRtt: avgRtt ?? this.avgRtt,
      maxRtt: maxRtt ?? this.maxRtt,
      isRunning: isRunning ?? this.isRunning,
      packets: packets ?? this.packets,
    );
  }

  @override
  List<Object?> get props => [
        target,
        packetsSent,
        packetsReceived,
        packetLossPercent,
        minRtt,
        avgRtt,
        maxRtt,
        isRunning,
        packets,
      ];
}

/// Entity representing a single ping packet result
class PingPacket extends Equatable {
  final int sequence;
  final Duration? rtt;
  final bool received;
  final String? error;

  const PingPacket({
    required this.sequence,
    this.rtt,
    this.received = false,
    this.error,
  });

  @override
  List<Object?> get props => [sequence, rtt, received, error];
}