import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/wireless_registration.dart';

class SignalMonitorWidget extends StatefulWidget {
  final WirelessRegistration client;
  final Function? onRefresh;

  const SignalMonitorWidget({
    super.key,
    required this.client,
    this.onRefresh,
  });

  @override
  State<SignalMonitorWidget> createState() => _SignalMonitorWidgetState();
}

class _SignalMonitorWidgetState extends State<SignalMonitorWidget> {
  final List<FlSpot> _signalData = [];
  Timer? _refreshTimer;
  int _dataPointCount = 0;
  final int _maxDataPoints = 30; // Show last 30 data points

  @override
  void initState() {
    super.initState();
    _addDataPoint();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        widget.onRefresh?.call();
        _addDataPoint();
      }
    });
  }

  void _addDataPoint() {
    setState(() {
      final signal = widget.client.signalStrength.toDouble();
      _signalData.add(FlSpot(_dataPointCount.toDouble(), signal));
      _dataPointCount++;

      // Keep only last N data points
      if (_signalData.length > _maxDataPoints) {
        _signalData.removeAt(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.signal_cellular_alt,
                  size: 32,
                  color: theme.primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Signal Monitor',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.client.macAddress,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Stats Cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    theme,
                    'Signal',
                    '${widget.client.signalStrength} dBm',
                    _getSignalColor(widget.client.signalStrength),
                    Icons.signal_cellular_alt,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    theme,
                    'CCQ',
                    'N/A',
                    Colors.blue,
                    Icons.network_check,
                  ),
                ),
              ],
            ),
          ),

          // Signal Graph
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              padding: const EdgeInsets.all(16),
              child: _signalData.isEmpty
                  ? const Center(child: Text('Collecting data...'))
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          horizontalInterval: 10,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey[300],
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            axisNameWidget: const Text('dBm'),
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 20,
                              reservedSize: 45,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            axisNameWidget: const Text('Time (3s intervals)'),
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 5,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        minY: -100,
                        maxY: -20,
                        lineBarsData: [
                          LineChartBarData(
                            spots: _signalData,
                            isCurved: true,
                            color: theme.primaryColor,
                            barWidth: 3,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: theme.primaryColor,
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: theme.primaryColor.withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 16),

          // Additional Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildInfoRow(theme, 'Interface', widget.client.interface),
                _buildInfoRow(theme, 'TX Rate', widget.client.txRate.toString()),
                _buildInfoRow(theme, 'RX Rate', widget.client.rxRate.toString()),
                _buildInfoRow(theme, 'Uptime', widget.client.uptime),

              ],
            ),
          ),

          const SizedBox(height: 16),

          // Disconnect Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                // Trigger disconnect from parent
              },
              icon: const Icon(Icons.link_off),
              label: const Text('Disconnect Client'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSignalColor(int signal) {
    if (signal >= -50) return Colors.green;
    if (signal >= -60) return Colors.lightGreen;
    if (signal >= -70) return Colors.orange;
    if (signal >= -80) return Colors.deepOrange;
    return Colors.red;
  }
}
