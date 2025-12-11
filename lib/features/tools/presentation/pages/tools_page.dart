import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/entities/dns_lookup_result.dart';
import '../../domain/entities/ping_result.dart';
import '../../domain/entities/traceroute_hop.dart';
import '../bloc/tools_bloc.dart';
import '../widgets/ping_results_widget.dart';
import '../bloc/tools_state.dart';
import '../bloc/tools_event.dart';

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
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showToolsInfoDialog(context, l10n),
            tooltip: l10n.toolsInfoTitle,
          ),
        ],
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
                        onTap: () => context.push(AppRoutes.toolsPing),
                      ),
                      _buildToolCard(
                        context,
                        icon: Icons.route,
                        title: l10n.traceroute,
                        subtitle: l10n.tracePath,
                        color: Colors.green,
                        onTap: () => context.push(AppRoutes.toolsTraceroute),
                      ),
                      _buildToolCard(
                        context,
                        icon: Icons.dns,
                        title: l10n.dnsLookup,
                        subtitle: l10n.resolveDomains,
                        color: Colors.orange,
                        onTap: () => context.push(AppRoutes.toolsDnsLookup),
                      ),
                      _buildToolCard(
                        context,
                        icon: Icons.clear_all,
                        title: l10n.clearResults,
                        subtitle: l10n.clearAllResults,
                        color: Colors.red,
                        onTap: () => context.read<ToolsBloc>().add(ClearResults()),
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
    if (state is PingUpdating) {
      // Show partial results as they arrive (real-time)
      return _buildPingResults(state.result, l10n, isUpdating: true);
    } else if (state is PingCompleted) {
      return _buildPingResults(state.result, l10n);
    } else if (state is TracerouteUpdating) {
      // Show partial results as they arrive (real-time)
      return _buildTracerouteResults(state.hops, l10n, isUpdating: true);
    } else if (state is TracerouteCompleted) {
      return _buildTracerouteResults(state.hops, l10n);
    } else if (state is DnsLookupCompleted) {
      return _buildDnsLookupResults(state.result, l10n);
    }
    return const SizedBox.shrink();
  }

  Widget _buildPingResults(PingResult result, AppLocalizations l10n, {bool isUpdating = false}) {
    return PingResultsWidget(
      result: result,
      l10n: l10n,
      isUpdating: isUpdating,
      onStopPing: () => context.read<ToolsBloc>().add(const StopPing()),
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

  Widget _buildTracerouteResults(List<TracerouteHop> hops, AppLocalizations l10n, {bool isUpdating = false}) {
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
                  Icons.route,
                  color: isUpdating ? Colors.orange : Colors.green,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.tracerouteResults,
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
                    onPressed: () {
                      context.read<ToolsBloc>().add(const StopTraceroute());
                    },
                    icon: const Icon(Icons.stop, size: 18),
                    label: Text(l10n.stopTraceroute),
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
            
            // Summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTracerouteStat(
                    icon: Icons.format_list_numbered,
                    label: 'Total Hops',
                    value: '${hops.length}',
                    color: Colors.blue,
                  ),
                  Container(
                    height: 30,
                    width: 1,
                    color: Colors.grey[300],
                  ),
                  _buildTracerouteStat(
                    icon: Icons.timer,
                    label: 'Time',
                    value: _getTotalTracerouteTime(hops),
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Hops list
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: hops.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Colors.grey[300],
                ),
                itemBuilder: (context, index) {
                  final hop = hops[index];
                  final isTimeout = hop.minRtt == null;
                  
                  return Container(
                    color: index % 2 == 0 ? Colors.grey[50] : Colors.white,
                    child: ListTile(
                      dense: true,
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isTimeout ? Colors.red[100] : Colors.green[100],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${hop.hopNumber}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isTimeout ? Colors.red[900] : Colors.green[900],
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        hop.hostname ?? hop.ipAddress ?? 'Unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: hop.ipAddress != null && hop.hostname != null
                          ? Text(
                              hop.ipAddress!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            )
                          : null,
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isTimeout ? Colors.red[50] : Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isTimeout ? Colors.red[200]! : Colors.green[200]!,
                          ),
                        ),
                        child: Text(
                          isTimeout
                              ? 'Timeout'
                              : '${hop.minRtt!.inMilliseconds}ms',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isTimeout ? Colors.red[900] : Colors.green[900],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTracerouteStat({
    required IconData icon,
    required String label,
    required String value,
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
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _getTotalTracerouteTime(List<TracerouteHop> hops) {
    if (hops.isEmpty) return '0ms';
    final lastHop = hops.last;
    if (lastHop.minRtt == null) return 'N/A';
    return '${lastHop.minRtt!.inMilliseconds}ms';
  }

  Widget _buildDnsLookupResults(DnsLookupResult result, AppLocalizations l10n) {
    final hasResults = result.hasResults;
    
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
                  hasResults ? Icons.check_circle : Icons.error,
                  color: hasResults ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.dnsResults,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            
            // Domain name
            _buildInfoRow(
              icon: Icons.language,
              label: l10n.domainName,
              value: result.domain,
              color: Colors.blue,
            ),
            
            if (hasResults) ...[
              const SizedBox(height: 16),
              
              // IPv4 Addresses
              if (result.ipv4Addresses.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.public, size: 16, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          Text(
                            l10n.ipv4Addresses,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.blue[900],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...result.ipv4Addresses.map((ip) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const SizedBox(width: 24),
                            Icon(Icons.circle, size: 6, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Text(
                              ip,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ],
              
              // IPv6 Addresses
              if (result.ipv6Addresses.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.purple[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.public, size: 16, color: Colors.purple[700]),
                          const SizedBox(width: 8),
                          Text(
                            l10n.ipv6Addresses,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.purple[900],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...result.ipv6Addresses.map((ip) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const SizedBox(width: 24),
                            Icon(Icons.circle, size: 6, color: Colors.purple[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                ip,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ],
              
              // Response time
              if (result.responseTime != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.speed, size: 20, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      Text(
                        '${l10n.responseTime}: ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        '${result.responseTime!.inMilliseconds}ms',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ] else ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        result.error ?? l10n.noResults,
                        style: TextStyle(
                          color: Colors.red[900],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Show info dialog explaining real-time tools
  void _showToolsInfoDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue[700]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(l10n.toolsInfoTitle),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.toolsInfoDescription,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildInfoItem(
              icon: Icons.send,
              text: l10n.pingInfoText,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              icon: Icons.route,
              text: l10n.tracerouteInfoText,
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              icon: Icons.dns,
              text: l10n.dnsLookupInfoText,
              color: Colors.orange,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}