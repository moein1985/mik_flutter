import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'monitoring_data.dart';

/// Chart colors for monitoring
class MonitoringColors {
  static const Color rxColor = Colors.green;
  static const Color txColor = Colors.blue;
  static const Color gridColor = Color(0xFF37434D);
  static const Color borderColor = Color(0xFF37434D);
  
  MonitoringColors._();
}

/// Enum for chart data type
enum ChartDataType {
  bandwidth,
  packets,
}

/// A real-time traffic monitoring chart widget
class MonitoringChart extends StatelessWidget {
  final List<TrafficDataPoint> dataPoints;
  final ChartDataType dataType;
  final double height;
  final bool showGrid;
  final bool showTitles;
  final bool animate;

  const MonitoringChart({
    super.key,
    required this.dataPoints,
    this.dataType = ChartDataType.bandwidth,
    this.height = 200,
    this.showGrid = true,
    this.showTitles = true,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LineChart(
        _buildChartData(),
        duration: animate ? const Duration(milliseconds: 150) : Duration.zero,
      ),
    );
  }

  LineChartData _buildChartData() {
    final rxSpots = <FlSpot>[];
    final txSpots = <FlSpot>[];

    for (int i = 0; i < dataPoints.length; i++) {
      final point = dataPoints[i];
      final x = i.toDouble();
      
      if (dataType == ChartDataType.bandwidth) {
        // Convert to Mbps for better visualization
        rxSpots.add(FlSpot(x, point.rxMbps));
        txSpots.add(FlSpot(x, point.txMbps));
      } else {
        // Packets per second (in thousands)
        rxSpots.add(FlSpot(x, point.rxPacketsPerSecond / 1000.0));
        txSpots.add(FlSpot(x, point.txPacketsPerSecond / 1000.0));
      }
    }

    // Calculate max Y for proper scaling
    double maxY = 1.0;
    for (final spot in [...rxSpots, ...txSpots]) {
      if (spot.y > maxY) maxY = spot.y;
    }
    // Add 10% padding to max
    maxY = maxY * 1.1;
    if (maxY < 1.0) maxY = 1.0;

    return LineChartData(
      gridData: FlGridData(
        show: showGrid,
        drawVerticalLine: true,
        horizontalInterval: maxY / 5,
        verticalInterval: 10,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: MonitoringColors.gridColor.withAlpha(50),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: MonitoringColors.gridColor.withAlpha(50),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: showTitles,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: maxY / 5,
            getTitlesWidget: (value, meta) {
              if (value == meta.max || value == meta.min) {
                return const SizedBox.shrink();
              }
              return Text(
                dataType == ChartDataType.bandwidth
                    ? value.toStringAsFixed(1)
                    : '${value.toStringAsFixed(0)}K',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              );
            },
            reservedSize: 40,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: MonitoringColors.borderColor, width: 1),
      ),
      minX: 0,
      maxX: dataPoints.isEmpty ? 60 : (dataPoints.length - 1).toDouble(),
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        // RX Line (Download) - Green
        LineChartBarData(
          spots: rxSpots.isEmpty ? [const FlSpot(0, 0)] : rxSpots,
          isCurved: true,
          curveSmoothness: 0.2,
          color: MonitoringColors.rxColor,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: MonitoringColors.rxColor.withAlpha(30),
          ),
        ),
        // TX Line (Upload) - Blue
        LineChartBarData(
          spots: txSpots.isEmpty ? [const FlSpot(0, 0)] : txSpots,
          isCurved: true,
          curveSmoothness: 0.2,
          color: MonitoringColors.txColor,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: MonitoringColors.txColor.withAlpha(30),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final isRx = spot.barIndex == 0;
              final label = isRx ? 'RX' : 'TX';
              final value = dataType == ChartDataType.bandwidth
                  ? '${spot.y.toStringAsFixed(2)} Mbps'
                  : '${(spot.y * 1000).toStringAsFixed(0)} pps';
              
              return LineTooltipItem(
                '$label: $value',
                TextStyle(
                  color: isRx ? MonitoringColors.rxColor : MonitoringColors.txColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }
}

/// Legend widget for the chart
class ChartLegend extends StatelessWidget {
  final ChartDataType dataType;

  const ChartLegend({
    super.key,
    this.dataType = ChartDataType.bandwidth,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(
          color: MonitoringColors.rxColor,
          label: dataType == ChartDataType.bandwidth ? 'RX (Download)' : 'RX Packets',
        ),
        const SizedBox(width: 24),
        _buildLegendItem(
          color: MonitoringColors.txColor,
          label: dataType == ChartDataType.bandwidth ? 'TX (Upload)' : 'TX Packets',
        ),
      ],
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Real-time stats display widget
class TrafficStatsDisplay extends StatelessWidget {
  final TrafficDataPoint? currentData;
  final bool showPackets;

  const TrafficStatsDisplay({
    super.key,
    this.currentData,
    this.showPackets = true,
  });

  @override
  Widget build(BuildContext context) {
    final data = currentData ?? TrafficDataPoint.zero();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatColumn(
          label: 'Download',
          value: data.rxBandwidth,
          subValue: showPackets ? TrafficDataPoint.formatPackets(data.rxPacketsPerSecond) : null,
          color: MonitoringColors.rxColor,
          icon: Icons.arrow_downward,
        ),
        Container(
          height: 60,
          width: 1,
          color: Colors.grey.withAlpha(100),
        ),
        _buildStatColumn(
          label: 'Upload',
          value: data.txBandwidth,
          subValue: showPackets ? TrafficDataPoint.formatPackets(data.txPacketsPerSecond) : null,
          color: MonitoringColors.txColor,
          icon: Icons.arrow_upward,
        ),
      ],
    );
  }

  Widget _buildStatColumn({
    required String label,
    required String value,
    String? subValue,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subValue != null) ...[
          const SizedBox(height: 2),
          Text(
            subValue,
            style: TextStyle(
              color: color.withAlpha(180),
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }
}
