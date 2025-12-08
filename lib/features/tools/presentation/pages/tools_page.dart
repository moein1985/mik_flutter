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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.pingResults,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('${l10n.targetHost}: ${result.target}'),
            Text('${l10n.packetsSent}: ${result.packetsSent}, ${l10n.packetsReceived}: ${result.packetsReceived}'),
            Text('${l10n.packetLoss}: ${result.packetLossPercent}%'),
            if (result.packetsReceived > 0) ...[
              Text('${l10n.rtt}: ${result.minRtt.inMilliseconds}ms min, ${result.avgRtt.inMilliseconds}ms avg, ${result.maxRtt.inMilliseconds}ms max'),
            ],
          ],
        ),
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