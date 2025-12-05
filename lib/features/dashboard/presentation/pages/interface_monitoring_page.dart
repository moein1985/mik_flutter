import 'package:flutter/material.dart';
import 'package:floating/floating.dart';
import '../../../../core/monitoring/interface_monitor.dart';
import '../../../../core/monitoring/monitoring_chart.dart';
import '../../../../core/network/routeros_client.dart';

/// Interface monitoring page with real-time traffic charts
class InterfaceMonitoringPage extends StatefulWidget {
  final String interfaceName;
  final RouterOSClient client;

  const InterfaceMonitoringPage({
    super.key,
    required this.interfaceName,
    required this.client,
  });

  @override
  State<InterfaceMonitoringPage> createState() => _InterfaceMonitoringPageState();
}

class _InterfaceMonitoringPageState extends State<InterfaceMonitoringPage> {
  late InterfaceMonitor _monitor;
  ChartDataType _selectedChartType = ChartDataType.bandwidth;
  final Floating _floating = Floating();

  @override
  void initState() {
    super.initState();
    _monitor = InterfaceMonitor(
      client: widget.client,
      interfaceName: widget.interfaceName,
      pollingInterval: const Duration(seconds: 1),
      maxDataPoints: 60,
    );
    _monitor.addListener(_onMonitorUpdate);
    _monitor.start();
  }

  void _onMonitorUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _enablePiP() async {
    final status = await _floating.isPipAvailable;
    if (status) {
      await _floating.enable(ImmediatePiP(
        aspectRatio: const Rational(16, 9),
      ));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PiP is not available on this device'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _monitor.removeListener(_onMonitorUpdate);
    _monitor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PiPSwitcher(
      childWhenEnabled: _buildPiPView(),
      childWhenDisabled: _buildFullView(),
    );
  }

  /// Compact view shown in PiP mode
  Widget _buildPiPView() {
    return Material(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.interfaceName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            if (_monitor.latestDataPoint != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_downward, color: MonitoringColors.rxColor, size: 12),
                  const SizedBox(width: 2),
                  Text(
                    _monitor.latestDataPoint!.rxBandwidth,
                    style: TextStyle(color: MonitoringColors.rxColor, fontSize: 11),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_upward, color: MonitoringColors.txColor, size: 12),
                  const SizedBox(width: 2),
                  Text(
                    _monitor.latestDataPoint!.txBandwidth,
                    style: TextStyle(color: MonitoringColors.txColor, fontSize: 11),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Expanded(
              child: MonitoringChart(
                dataPoints: _monitor.data.dataPoints,
                dataType: ChartDataType.bandwidth,
                showGrid: false,
                showTitles: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Full view shown when not in PiP mode
  Widget _buildFullView() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monitor: ${widget.interfaceName}'),
        actions: [
          // PiP button
          IconButton(
            icon: const Icon(Icons.picture_in_picture),
            onPressed: _enablePiP,
            tooltip: 'Picture in Picture',
          ),
          // Play/Pause button
          IconButton(
            icon: Icon(
              _monitor.isMonitoring ? Icons.pause : Icons.play_arrow,
            ),
            onPressed: () {
              if (_monitor.isMonitoring) {
                _monitor.stop();
              } else {
                _monitor.start();
              }
            },
            tooltip: _monitor.isMonitoring ? 'Pause' : 'Resume',
          ),
          // Clear button
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              _monitor.clear();
            },
            tooltip: 'Clear Data',
          ),
        ],
      ),
      body: Column(
        children: [
          // Error message if any
          if (_monitor.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.red.shade100,
              child: Text(
                _monitor.error!,
                style: TextStyle(color: Colors.red.shade900),
                textAlign: TextAlign.center,
              ),
            ),

          // Current stats display
          Padding(
            padding: const EdgeInsets.all(16),
            child: TrafficStatsDisplay(
              currentData: _monitor.latestDataPoint,
              showPackets: true,
            ),
          ),

          const Divider(),

          // Chart type selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<ChartDataType>(
                    segments: const [
                      ButtonSegment(
                        value: ChartDataType.bandwidth,
                        label: Text('Bandwidth'),
                        icon: Icon(Icons.speed),
                      ),
                      ButtonSegment(
                        value: ChartDataType.packets,
                        label: Text('Packets'),
                        icon: Icon(Icons.blur_on),
                      ),
                    ],
                    selected: {_selectedChartType},
                    onSelectionChanged: (newSelection) {
                      setState(() {
                        _selectedChartType = newSelection.first;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Chart legend
          ChartLegend(dataType: _selectedChartType),

          const SizedBox(height: 16),

          // Main chart
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MonitoringChart(
                dataPoints: _monitor.data.dataPoints,
                dataType: _selectedChartType,
                height: double.infinity,
                showGrid: true,
                showTitles: true,
              ),
            ),
          ),

          // Status bar
          Container(
            padding: const EdgeInsets.all(12),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _monitor.isMonitoring ? Icons.circle : Icons.circle_outlined,
                      size: 12,
                      color: _monitor.isMonitoring ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _monitor.isMonitoring ? 'Monitoring...' : 'Paused',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                Text(
                  'Data points: ${_monitor.data.dataPoints.length}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact monitoring widget for embedding in other pages
class CompactMonitoringWidget extends StatefulWidget {
  final String interfaceName;
  final RouterOSClient client;
  final double height;
  final VoidCallback? onTap;

  const CompactMonitoringWidget({
    super.key,
    required this.interfaceName,
    required this.client,
    this.height = 150,
    this.onTap,
  });

  @override
  State<CompactMonitoringWidget> createState() => _CompactMonitoringWidgetState();
}

class _CompactMonitoringWidgetState extends State<CompactMonitoringWidget> {
  late InterfaceMonitor _monitor;

  @override
  void initState() {
    super.initState();
    _monitor = InterfaceMonitor(
      client: widget.client,
      interfaceName: widget.interfaceName,
      pollingInterval: const Duration(seconds: 1),
      maxDataPoints: 30,
    );
    _monitor.addListener(_onMonitorUpdate);
    _monitor.start();
  }

  void _onMonitorUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _monitor.removeListener(_onMonitorUpdate);
    _monitor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.interfaceName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Icon(
                    _monitor.isMonitoring ? Icons.circle : Icons.circle_outlined,
                    size: 10,
                    color: _monitor.isMonitoring ? Colors.green : Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_monitor.latestDataPoint != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMiniStat(
                      'RX',
                      _monitor.latestDataPoint!.rxBandwidth,
                      MonitoringColors.rxColor,
                    ),
                    _buildMiniStat(
                      'TX',
                      _monitor.latestDataPoint!.txBandwidth,
                      MonitoringColors.txColor,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              SizedBox(
                height: widget.height - 80,
                child: MonitoringChart(
                  dataPoints: _monitor.data.dataPoints,
                  dataType: ChartDataType.bandwidth,
                  showGrid: false,
                  showTitles: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
