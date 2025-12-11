import 'package:flutter/material.dart';

import 'package:hsmik/l10n/app_localizations.dart';
import 'package:hsmik/features/tools/domain/entities/ping_result.dart';

class PingResultsWidget extends StatelessWidget {
  final PingResult result;
  final AppLocalizations l10n;
  final bool isUpdating;
  final VoidCallback? onStopPing;

  const PingResultsWidget({
    super.key,
    required this.result,
    required this.l10n,
    this.isUpdating = false,
    this.onStopPing,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = result.packetsReceived > 0;
    final packetLoss = result.packetLossPercent;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isUpdating ? Icons.sensors : (isSuccess ? Icons.check_circle : Icons.error),
                  color: isUpdating ? Colors.orange : (isSuccess ? Colors.green : Colors.red),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.pingResults,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isUpdating) ...[
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: onStopPing,
                    icon: const Icon(Icons.stop, size: 18),
                    label: Text(l10n.stopPing),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ],
            ),
            const Divider(height: 24),

            // Target Host
            _buildInfoRow(
              icon: Icons.dns,
              label: l10n.targetHost,
              value: result.target,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),

            // Packet Statistics
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Packet Statistics',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(
                        label: l10n.packetsSent,
                        value: '${result.packetsSent}',
                        icon: Icons.upload,
                        color: Colors.blue,
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.grey[300],
                      ),
                      _buildStatColumn(
                        label: l10n.packetsReceived,
                        value: '${result.packetsReceived}',
                        icon: Icons.download,
                        color: Colors.green,
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.grey[300],
                      ),
                      _buildStatColumn(
                        label: l10n.packetLoss,
                        value: '${packetLoss.toStringAsFixed(1)}%',
                        icon: Icons.warning,
                        color: packetLoss > 0 ? Colors.red : Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // RTT Statistics (only if packets received)
            if (result.packetsReceived > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.speed, size: 16, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Round Trip Time',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.green[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildRttValue(
                          label: 'Min',
                          value: '${result.minRtt.inMilliseconds}ms',
                          color: Colors.green[700]!,
                        ),
                        _buildRttValue(
                          label: 'Avg',
                          value: '${result.avgRtt.inMilliseconds}ms',
                          color: Colors.orange[700]!,
                        ),
                        _buildRttValue(
                          label: 'Max',
                          value: '${result.maxRtt.inMilliseconds}ms',
                          color: Colors.red[700]!,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // Connection Quality Indicator
            if (result.packetsReceived > 0) ...[
              const SizedBox(height: 16),
              _buildQualityIndicator(result),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumn({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
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
      ],
    );
  }

  Widget _buildRttValue({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQualityIndicator(PingResult result) {
    final packetLoss = result.packetLossPercent;
    final avgRtt = result.avgRtt.inMilliseconds;

    String quality;
    Color color;
    IconData icon;

    if (packetLoss == 0 && avgRtt < 50) {
      quality = 'Excellent';
      color = Colors.green;
      icon = Icons.signal_cellular_alt;
    } else if (packetLoss <= 1 && avgRtt < 100) {
      quality = 'Good';
      color = Colors.lightGreen;
      icon = Icons.signal_cellular_alt_2_bar;
    } else if (packetLoss <= 5 && avgRtt < 200) {
      quality = 'Fair';
      color = Colors.orange;
      icon = Icons.signal_cellular_alt_1_bar;
    } else {
      quality = 'Poor';
      color = Colors.red;
      icon = Icons.signal_cellular_connected_no_internet_0_bar;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            'Connection Quality: $quality',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}