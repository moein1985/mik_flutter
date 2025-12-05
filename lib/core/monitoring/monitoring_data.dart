import 'package:equatable/equatable.dart';

/// Represents a single data point for interface traffic monitoring
class TrafficDataPoint extends Equatable {
  final DateTime timestamp;
  final int rxBitsPerSecond;
  final int txBitsPerSecond;
  final int rxPacketsPerSecond;
  final int txPacketsPerSecond;

  const TrafficDataPoint({
    required this.timestamp,
    required this.rxBitsPerSecond,
    required this.txBitsPerSecond,
    required this.rxPacketsPerSecond,
    required this.txPacketsPerSecond,
  });

  /// Convert bits per second to human readable format
  String get rxBandwidth => _formatBandwidth(rxBitsPerSecond);
  String get txBandwidth => _formatBandwidth(txBitsPerSecond);

  /// Get RX bandwidth in Mbps
  double get rxMbps => rxBitsPerSecond / 1000000.0;
  double get txMbps => txBitsPerSecond / 1000000.0;

  /// Get RX bandwidth in Kbps
  double get rxKbps => rxBitsPerSecond / 1000.0;
  double get txKbps => txBitsPerSecond / 1000.0;

  static String _formatBandwidth(int bitsPerSecond) {
    if (bitsPerSecond >= 1000000000) {
      return '${(bitsPerSecond / 1000000000).toStringAsFixed(2)} Gbps';
    } else if (bitsPerSecond >= 1000000) {
      return '${(bitsPerSecond / 1000000).toStringAsFixed(2)} Mbps';
    } else if (bitsPerSecond >= 1000) {
      return '${(bitsPerSecond / 1000).toStringAsFixed(2)} Kbps';
    } else {
      return '$bitsPerSecond bps';
    }
  }

  static String formatPackets(int packetsPerSecond) {
    if (packetsPerSecond >= 1000000) {
      return '${(packetsPerSecond / 1000000).toStringAsFixed(2)} Mpps';
    } else if (packetsPerSecond >= 1000) {
      return '${(packetsPerSecond / 1000).toStringAsFixed(2)} Kpps';
    } else {
      return '$packetsPerSecond pps';
    }
  }

  factory TrafficDataPoint.fromApiResponse(Map<String, String> response) {
    return TrafficDataPoint(
      timestamp: DateTime.now(),
      rxBitsPerSecond: int.tryParse(response['rx-bits-per-second'] ?? '0') ?? 0,
      txBitsPerSecond: int.tryParse(response['tx-bits-per-second'] ?? '0') ?? 0,
      rxPacketsPerSecond: int.tryParse(response['rx-packets-per-second'] ?? '0') ?? 0,
      txPacketsPerSecond: int.tryParse(response['tx-packets-per-second'] ?? '0') ?? 0,
    );
  }

  factory TrafficDataPoint.zero() {
    return TrafficDataPoint(
      timestamp: DateTime.now(),
      rxBitsPerSecond: 0,
      txBitsPerSecond: 0,
      rxPacketsPerSecond: 0,
      txPacketsPerSecond: 0,
    );
  }

  @override
  List<Object?> get props => [
        timestamp,
        rxBitsPerSecond,
        txBitsPerSecond,
        rxPacketsPerSecond,
        txPacketsPerSecond,
      ];
}

/// Represents the monitoring state for an interface
class InterfaceMonitoringData extends Equatable {
  final String interfaceName;
  final List<TrafficDataPoint> dataPoints;
  final int maxDataPoints;

  const InterfaceMonitoringData({
    required this.interfaceName,
    this.dataPoints = const [],
    this.maxDataPoints = 60, // 60 seconds of data
  });

  InterfaceMonitoringData addDataPoint(TrafficDataPoint point) {
    final newPoints = [...dataPoints, point];
    // Keep only the last maxDataPoints
    if (newPoints.length > maxDataPoints) {
      return InterfaceMonitoringData(
        interfaceName: interfaceName,
        dataPoints: newPoints.sublist(newPoints.length - maxDataPoints),
        maxDataPoints: maxDataPoints,
      );
    }
    return InterfaceMonitoringData(
      interfaceName: interfaceName,
      dataPoints: newPoints,
      maxDataPoints: maxDataPoints,
    );
  }

  TrafficDataPoint? get latestDataPoint =>
      dataPoints.isNotEmpty ? dataPoints.last : null;

  /// Get max RX bits/s in current data
  int get maxRxBits =>
      dataPoints.isEmpty ? 0 : dataPoints.map((e) => e.rxBitsPerSecond).reduce((a, b) => a > b ? a : b);

  /// Get max TX bits/s in current data
  int get maxTxBits =>
      dataPoints.isEmpty ? 0 : dataPoints.map((e) => e.txBitsPerSecond).reduce((a, b) => a > b ? a : b);

  /// Get max packets/s in current data
  int get maxRxPackets =>
      dataPoints.isEmpty ? 0 : dataPoints.map((e) => e.rxPacketsPerSecond).reduce((a, b) => a > b ? a : b);

  int get maxTxPackets =>
      dataPoints.isEmpty ? 0 : dataPoints.map((e) => e.txPacketsPerSecond).reduce((a, b) => a > b ? a : b);

  @override
  List<Object?> get props => [interfaceName, dataPoints, maxDataPoints];
}
