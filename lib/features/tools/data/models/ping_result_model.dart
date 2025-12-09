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
      // Skip done message
      if (item['type'] == 'done') continue;

      // Parse ping statistics from each response
      if (item.containsKey('sent')) {
        packetsSent = int.tryParse(item['sent'] ?? '0') ?? 0;
      }
      if (item.containsKey('received')) {
        packetsReceived = int.tryParse(item['received'] ?? '0') ?? 0;
      }
      if (item.containsKey('min-rtt') && item['min-rtt'] != null) {
        minRtt = parseDuration(item['min-rtt']!);
      }
      if (item.containsKey('avg-rtt') && item['avg-rtt'] != null) {
        avgRtt = parseDuration(item['avg-rtt']!);
      }
      if (item.containsKey('max-rtt') && item['max-rtt'] != null) {
        maxRtt = parseDuration(item['max-rtt']!);
      }

      // Parse individual packet results
      final seq = int.tryParse(item['seq'] ?? '');
      if (seq != null) {
        final rtt = item['time'] != null ? parseDuration(item['time']!) : null;
        final received = rtt != null;
        final error = received ? null : 'timeout';

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

  /// Parse duration string like "410us", "10ms", "95ms894us" or "1.5s" to Duration
  static Duration parseDuration(String durationStr) {
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