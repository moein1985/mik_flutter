import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/dns_lookup_result.dart';
import '../../domain/entities/ping_result.dart';
import '../../domain/entities/traceroute_hop.dart';
import '../bloc/tools_bloc.dart';
import '../bloc/tools_event.dart';
import '../bloc/tools_state.dart';

class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.networkTools),
      ),
      body: BlocConsumer<ToolsBloc, ToolsState>(
        listener: (context, state) {
          if (state is PingFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is TracerouteFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is DnsLookupFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.diagnosticTools,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.testConnectivity,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildToolCard(
                        context,
                        icon: Icons.network_ping,
                        title: l10n.ping,
                        subtitle: l10n.pingConnectivity,
                        color: Colors.blue,
                        onTap: () => _showPingDialog(context, l10n),
                      ),
                      _buildToolCard(
                        context,
                        icon: Icons.route,
                        title: l10n.traceroute,
                        subtitle: l10n.tracePath,
                        color: Colors.green,
                        onTap: () => _showTracerouteDialog(context, l10n),
                      ),
                      _buildToolCard(
                        context,
                        icon: Icons.dns,
                        title: l10n.dnsLookup,
                        subtitle: l10n.resolveDomains,
                        color: Colors.orange,
                        onTap: () => _showDnsLookupDialog(context, l10n),
                      ),
                      _buildToolCard(
                        context,
                        icon: Icons.clear_all,
                        title: l10n.clearResults,
                        subtitle: l10n.clearAllResults,
                        color: Colors.red,
                        onTap: () => context.read<ToolsBloc>().add(const ClearResults()),
                      ),
                    ],
                  ),
                ),
                if (state is PingInProgress ||
                    state is TracerouteInProgress ||
                    state is DnsLookupInProgress)
                  const LinearProgressIndicator(),
                const SizedBox(height: 16),
                _buildResultsSection(state, l10n),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSection(ToolsState state, AppLocalizations l10n) {
    if (state is PingCompleted) {
      return _buildPingResults(state.result, l10n);
    } else if (state is TracerouteCompleted) {
      return _buildTracerouteResults(state.hops, l10n);
    } else if (state is DnsLookupCompleted) {
      return _buildDnsLookupResults(state.result, l10n);
    }
    return const SizedBox.shrink();
  }

  Widget _buildPingResults(PingResult result, AppLocalizations l10n) {
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
                  isSuccess ? Icons.check_circle : Icons.error,
                  color: isSuccess ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.pingResults,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
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
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
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
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildQualityIndicator(PingResult result) {
    String quality;
    Color qualityColor;
    IconData qualityIcon;
    
    final avgRtt = result.avgRtt.inMilliseconds;
    final loss = result.packetLossPercent;
    
    if (loss > 10 || avgRtt > 200) {
      quality = 'Poor';
      qualityColor = Colors.red;
      qualityIcon = Icons.signal_cellular_0_bar;
    } else if (loss > 5 || avgRtt > 100) {
      quality = 'Fair';
      qualityColor = Colors.orange;
      qualityIcon = Icons.signal_cellular_alt_2_bar;
    } else if (loss > 0 || avgRtt > 50) {
      quality = 'Good';
      qualityColor = Colors.lightGreen;
      qualityIcon = Icons.signal_cellular_alt;
    } else {
      quality = 'Excellent';
      qualityColor = Colors.green;
      qualityIcon = Icons.signal_cellular_alt;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: qualityColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: qualityColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(qualityIcon, color: qualityColor, size: 24),
          const SizedBox(width: 12),
          Text(
            'Connection Quality: ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            quality,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: qualityColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTracerouteResults(List<TracerouteHop> hops, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.tracerouteResults,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: hops.length,
                itemBuilder: (context, index) {
                  final hop = hops[index];
                  return ListTile(
                    leading: Text('${hop.hopNumber}'),
                    title: Text(hop.hostname ?? hop.ipAddress ?? 'Unknown'),
                    subtitle: hop.minRtt != null
                        ? Text('${hop.minRtt!.inMilliseconds}ms')
                        : const Text('Timeout'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDnsLookupResults(DnsLookupResult result, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dnsResults,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('${l10n.domainName}: ${result.domain}'),
            if (result.hasResults) ...[
              Text('${l10n.ipv4Addresses}: ${result.ipv4Addresses.join(', ')}'),
              if (result.ipv6Addresses.isNotEmpty)
                Text('${l10n.ipv6Addresses}: ${result.ipv6Addresses.join(', ')}'),
            ] else ...[
              Text(l10n.noResults),
            ],
            if (result.responseTime != null)
              Text('${l10n.responseTime}: ${result.responseTime!.inMilliseconds}ms'),
            if (result.error != null)
              Text('Error: ${result.error}'),
          ],
        ),
      ),
    );
  }

  void _showPingDialog(BuildContext context, AppLocalizations l10n) {
    final targetController = TextEditingController();
    final countController = TextEditingController(text: '4');
    final timeoutController = TextEditingController(text: '1000');
    final toolsBloc = context.read<ToolsBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.pingTest),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: targetController,
              decoration: InputDecoration(
                labelText: l10n.targetHost,
                hintText: 'e.g., google.com or 8.8.8.8',
              ),
            ),
            TextField(
              controller: countController,
              decoration: InputDecoration(
                labelText: l10n.packetCount,
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: timeoutController,
              decoration: InputDecoration(
                labelText: l10n.timeoutMs,
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final target = targetController.text.trim();
              final count = int.tryParse(countController.text) ?? 4;
              final timeout = int.tryParse(timeoutController.text) ?? 1000;

              if (target.isNotEmpty) {
                toolsBloc.add(StartPing(
                  target: target,
                  count: count,
                  timeout: timeout,
                ));
                Navigator.of(dialogContext).pop();
              }
            },
            child: Text(l10n.startPing),
          ),
        ],
      ),
    );
  }

  void _showTracerouteDialog(BuildContext context, AppLocalizations l10n) {
    final targetController = TextEditingController();
    final maxHopsController = TextEditingController(text: '30');
    final timeoutController = TextEditingController(text: '1000');
    final toolsBloc = context.read<ToolsBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.tracerouteTest),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: targetController,
              decoration: InputDecoration(
                labelText: l10n.targetHost,
                hintText: 'e.g., google.com or 8.8.8.8',
              ),
            ),
            TextField(
              controller: maxHopsController,
              decoration: InputDecoration(
                labelText: l10n.maxHops,
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: timeoutController,
              decoration: InputDecoration(
                labelText: l10n.timeoutMs,
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final target = targetController.text.trim();
              final maxHops = int.tryParse(maxHopsController.text) ?? 30;
              final timeout = int.tryParse(timeoutController.text) ?? 1000;

              if (target.isNotEmpty) {
                toolsBloc.add(StartTraceroute(
                  target: target,
                  maxHops: maxHops,
                  timeout: timeout,
                ));
                Navigator.of(dialogContext).pop();
              }
            },
            child: Text(l10n.startTraceroute),
          ),
        ],
      ),
    );
  }

  void _showDnsLookupDialog(BuildContext context, AppLocalizations l10n) {
    final domainController = TextEditingController();
    final timeoutController = TextEditingController(text: '5000');
    final toolsBloc = context.read<ToolsBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.dnsLookupTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: domainController,
              decoration: InputDecoration(
                labelText: l10n.domainName,
                hintText: 'e.g., google.com',
              ),
            ),
            TextField(
              controller: timeoutController,
              decoration: InputDecoration(
                labelText: l10n.timeoutMs,
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final domain = domainController.text.trim();
              final timeout = int.tryParse(timeoutController.text) ?? 5000;

              if (domain.isNotEmpty) {
                toolsBloc.add(StartDnsLookup(
                  domain: domain,
                  timeout: timeout,
                ));
                Navigator.of(dialogContext).pop();
              }
            },
            child: Text(l10n.lookupDns),
          ),
        ],
      ),
    );
  }
}