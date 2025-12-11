import 'dart:async';
import 'package:flutter/foundation.dart';
import '../network/routeros_client_v2.dart';
import 'monitoring_data.dart';

/// Interface monitor that polls traffic data at regular intervals
class InterfaceMonitor extends ChangeNotifier {
  final RouterOSClientV2 client;
  final String interfaceName;
  final Duration pollingInterval;
  final int maxDataPoints;

  InterfaceMonitoringData _data;
  Timer? _timer;
  bool _isMonitoring = false;
  String? _error;

  InterfaceMonitor({
    required this.client,
    required this.interfaceName,
    this.pollingInterval = const Duration(seconds: 1),
    this.maxDataPoints = 60,
  }) : _data = InterfaceMonitoringData(
          interfaceName: interfaceName,
          maxDataPoints: maxDataPoints,
        );

  /// Current monitoring data
  InterfaceMonitoringData get data => _data;

  /// Whether monitoring is active
  bool get isMonitoring => _isMonitoring;

  /// Last error message
  String? get error => _error;

  /// Latest traffic data point
  TrafficDataPoint? get latestDataPoint => _data.latestDataPoint;

  /// Start monitoring
  void start() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _error = null;
    notifyListeners();

    // Immediately fetch first data point
    _fetchTrafficData();

    // Start periodic polling
    _timer = Timer.periodic(pollingInterval, (_) => _fetchTrafficData());
  }

  /// Stop monitoring
  void stop() {
    _timer?.cancel();
    _timer = null;
    _isMonitoring = false;
    notifyListeners();
  }

  /// Clear all data points
  void clear() {
    _data = InterfaceMonitoringData(
      interfaceName: interfaceName,
      maxDataPoints: maxDataPoints,
    );
    _error = null;
    notifyListeners();
  }

  /// Fetch traffic data from router
  Future<void> _fetchTrafficData() async {
    if (!client.isConnected) {
      _error = 'Not connected to router';
      notifyListeners();
      return;
    }

    try {
      final response = await client.monitorTraffic(interfaceName);

      if (response.isNotEmpty) {
        final dataPoint = TrafficDataPoint.fromApiResponse(response);
        _data = _data.addDataPoint(dataPoint);
        _error = null;
      }
    } catch (e) {
      _error = 'Failed to fetch traffic data: $e';
    }

    notifyListeners();
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}

/// Static utility class for monitoring
class MonitoringUtils {
  MonitoringUtils._();

  /// Create a monitor and start it
  static InterfaceMonitor createMonitor({
    required RouterOSClientV2 client,
    required String interfaceName,
    Duration pollingInterval = const Duration(seconds: 1),
    int maxDataPoints = 60,
  }) {
    return InterfaceMonitor(
      client: client,
      interfaceName: interfaceName,
      pollingInterval: pollingInterval,
      maxDataPoints: maxDataPoints,
    );
  }
}
