import '../../domain/entities/ping_result.dart';

/// Model for ping result data from RouterOS API
class PingResultModel extends PingResult {
  const PingResultModel({
    required super.target,
    required super.packetsSent,
    required super.packetsReceived,
    required super.packetLossPercent,
    required super.minRtt,
    required super.avgRtt,
    required super.maxRtt,
    super.isRunning,
    super.packets,
  });

  /// Create model from RouterOS ping response
  factory PingResultModel.fromRouterOS(
    String target,
    List<Map<String, String>> response,
  ) {
    int packetsSent = 0;
    int packetsReceived = 0;
    Duration minRtt = Duration.zero;
    Duration avgRtt = Duration.zero;
    Duration maxRtt = Duration.zero;
    final packets = <PingPacket>[];

    for (final item in response) {
      // Skip protocol messages
      if (item.containsKey('type')) continue;

      // Parse ping statistics
      if (item.containsKey('sent')) {
        packetsSent = int.tryParse(item['sent'] ?? '0') ?? 0;
      }
      if (item.containsKey('received')) {
        packetsReceived = int.tryParse(item['received'] ?? '0') ?? 0;
      }
      if (item.containsKey('min-rtt') && item['min-rtt'] != null) {
        minRtt = _parseDuration(item['min-rtt']!);
      }
      if (item.containsKey('avg-rtt') && item['avg-rtt'] != null) {
        avgRtt = _parseDuration(item['avg-rtt']!);
      }
      if (item.containsKey('max-rtt') && item['max-rtt'] != null) {
        maxRtt = _parseDuration(item['max-rtt']!);
      }

      // Parse individual packet results
      final seq = int.tryParse(item['seq'] ?? '');
      if (seq != null) {
        final rtt = item['time'] != null ? _parseDuration(item['time']!) : null;
        final received = item['status'] == 'received' || rtt != null;
        final error = item['status'] != 'received' && item['status'] != null
            ? item['status']
            : null;

        packets.add(PingPacket(
          sequence: seq,
          rtt: rtt,
          received: received,
          error: error,
        ));
      }
    }

    final packetLossPercent = packetsSent > 0
        ? ((packetsSent - packetsReceived) / packetsSent * 100).round()
        : 0;

    return PingResultModel(
      target: target,
      packetsSent: packetsSent,
      packetsReceived: packetsReceived,
      packetLossPercent: packetLossPercent,
      minRtt: minRtt,
      avgRtt: avgRtt,
      maxRtt: maxRtt,
      packets: packets,
    );
  }

  /// Parse duration string like "10ms" or "1.5s" to Duration
  static Duration _parseDuration(String durationStr) {
    if (durationStr.endsWith('ms')) {
      final ms = double.tryParse(durationStr.substring(0, durationStr.length - 2));
      return Duration(microseconds: (ms! * 1000).round());
    } else if (durationStr.endsWith('s')) {
      final s = double.tryParse(durationStr.substring(0, durationStr.length - 1));
      return Duration(microseconds: (s! * 1000000).round());
    } else {
      // Assume milliseconds if no unit
      final ms = double.tryParse(durationStr);
      return Duration(microseconds: (ms! * 1000).round());
    }
  }

  /// Convert to entity
  PingResult toEntity() {
    return PingResult(
      target: target,
      packetsSent: packetsSent,
      packetsReceived: packetsReceived,
      packetLossPercent: packetLossPercent,
      minRtt: minRtt,
      avgRtt: avgRtt,
      maxRtt: maxRtt,
      isRunning: isRunning,
      packets: packets,
    );
  }
}