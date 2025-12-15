import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/hotspot_host.dart';
import '../bloc/hotspot_bloc.dart';
import '../bloc/hotspot_event.dart';
import '../bloc/hotspot_state.dart';

class HotspotHostsPage extends StatefulWidget {
  const HotspotHostsPage({super.key});

  @override
  State<HotspotHostsPage> createState() => _HotspotHostsPageState();
}

class _HotspotHostsPageState extends State<HotspotHostsPage> {
  String? _lastShownMessage;

  @override
  void initState() {
    super.initState();
    context.read<HotspotBloc>().add(const LoadHosts());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hosts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              context.read<HotspotBloc>().add(const LoadHosts());
            },
          ),
        ],
      ),
      body: BlocConsumer<HotspotBloc, HotspotState>(
        listener: (context, state) {
          if (state is HotspotError) {
            if (_lastShownMessage != state.message) {
              _lastShownMessage = state.message;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } else if (state is HotspotOperationSuccess) {
            if (_lastShownMessage != state.message) {
              _lastShownMessage = state.message;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              context.read<HotspotBloc>().add(const LoadHosts());
            }
          } else {
            _lastShownMessage = null;
          }
        },
        builder: (context, state) {
          return switch (state) {
            HotspotLoading() => const Center(child: CircularProgressIndicator()),
            HotspotLoaded(:final hosts) => hosts == null || hosts.isEmpty
                ? _buildEmptyView(colorScheme)
                : _buildHostsList(hosts, colorScheme),
            _ => _buildErrorView(context, colorScheme, state),
          };
        },
      ),
    );
  }

  Widget _buildQuickTipCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.devices_other, color: Colors.indigo.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Hosts shows all devices currently connected to the HotSpot network, whether authorized or not.',
              style: TextStyle(
                color: Colors.indigo.shade800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildQuickTipCard(),
          
          const SizedBox(height: 48),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withAlpha(77),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.devices_other,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Hosts Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No devices are connected to the HotSpot',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, ColorScheme colorScheme, HotspotState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withAlpha(77),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            state is HotspotError ? state.message : 'Unable to load hosts',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              context.read<HotspotBloc>().add(const LoadHosts());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildHostsList(List<HotspotHost> hosts, ColorScheme colorScheme) {
    // Count by status
    final authorizedCount = hosts.where((h) => h.authorized).length;
    final bypassedCount = hosts.where((h) => h.bypassed).length;
    final otherCount = hosts.length - authorizedCount - bypassedCount;
    
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HotspotBloc>().add(const LoadHosts());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildQuickTipCard(),
            
            const SizedBox(height: 16),
            
            // Status summary
            _buildStatusSummary(hosts.length, authorizedCount, bypassedCount, otherCount, colorScheme),
            
            const SizedBox(height: 16),
            
            // Host cards
            ...hosts.map((host) => _buildHostCard(host, colorScheme)),
            
            // Bottom spacing
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSummary(int total, int authorized, int bypassed, int other, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withAlpha(77),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withAlpha(51)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$total host${total > 1 ? 's' : ''}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          if (authorized > 0)
            _buildMiniTag('$authorized Auth', Colors.green),
          if (bypassed > 0) ...[
            const SizedBox(width: 8),
            _buildMiniTag('$bypassed Bypass', Colors.blue),
          ],
          if (other > 0) ...[
            const SizedBox(width: 8),
            _buildMiniTag('$other Other', Colors.orange),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildHostCard(HotspotHost host, ColorScheme colorScheme) {
    final isAuthorized = host.authorized;
    final isBypassed = host.bypassed;
    
    Color statusColor = Colors.orange;
    String statusText = 'Not Authorized';
    IconData statusIcon = Icons.warning_outlined;
    
    if (isAuthorized) {
      statusColor = Colors.green;
      statusText = 'Authorized';
      statusIcon = Icons.check_circle;
    } else if (isBypassed) {
      statusColor = Colors.blue;
      statusText = 'Bypassed';
      statusIcon = Icons.transit_enterexit;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline.withAlpha(51)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.computer,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        host.hostName ?? host.address ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // Status tag
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withAlpha(26),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(statusIcon, size: 12, color: statusColor),
                                const SizedBox(width: 4),
                                Text(
                                  statusText,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(value, host),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'make_binding',
                      child: Row(
                        children: [
                          Icon(Icons.link),
                          SizedBox(width: 8),
                          Text('Make Binding'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: colorScheme.error),
                          const SizedBox(width: 8),
                          Text('Remove', style: TextStyle(color: colorScheme.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            
            // Details grid
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                if (host.address != null)
                  _buildDetailChip(Icons.lan, 'IP: ${host.address}', colorScheme),
                _buildDetailChip(Icons.router, 'MAC: ${host.macAddress}', colorScheme),
                if (host.server != null)
                  _buildDetailChip(Icons.dns, host.server!, colorScheme),
                if (host.uptime != null)
                  _buildDetailChip(Icons.timer, host.uptime!, colorScheme),
              ],
            ),
            
            // Traffic stats
            if (host.bytesIn != null || host.bytesOut != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTrafficCard(
                      Icons.download,
                      'Download',
                      _formatBytesStr(host.bytesIn),
                      Colors.green,
                      colorScheme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTrafficCard(
                      Icons.upload,
                      'Upload',
                      _formatBytesStr(host.bytesOut),
                      Colors.orange,
                      colorScheme,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String label, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(128),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrafficCard(IconData icon, String label, String value, Color color, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withAlpha(13),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatBytesStr(String? bytesStr) {
    if (bytesStr == null || bytesStr.isEmpty) return '0 B';
    final bytes = int.tryParse(bytesStr) ?? 0;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  void _handleMenuAction(String action, HotspotHost host) {
    switch (action) {
      case 'make_binding':
        _showMakeBindingDialog(context, host);
        break;
      case 'remove':
        _showRemoveConfirmation(context, host);
        break;
    }
  }

  void _showRemoveConfirmation(BuildContext context, HotspotHost host) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Host'),
        content: Text(
          'Are you sure you want to remove this host?\n'
          '${host.hostName ?? host.address ?? host.macAddress}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<HotspotBloc>().add(RemoveHost(host.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showMakeBindingDialog(BuildContext context, HotspotHost host) {
    String bindingType = 'regular';
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Make IP Binding'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Host: ${host.hostName ?? host.address ?? 'Unknown'}'),
              Text('MAC: ${host.macAddress}'),
              if (host.address != null)
                Text('IP: ${host.address}'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: bindingType,
                decoration: const InputDecoration(
                  labelText: 'Binding Type',
                ),
                items: const [
                  DropdownMenuItem(value: 'regular', child: Text('Regular')),
                  DropdownMenuItem(value: 'bypassed', child: Text('Bypassed')),
                  DropdownMenuItem(value: 'blocked', child: Text('Blocked')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => bindingType = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  labelText: 'Comment',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                this.context.read<HotspotBloc>().add(
                  MakeHostBinding(
                    id: host.id,
                    type: bindingType,
                  ),
                );
              },
              child: const Text('Create Binding'),
            ),
          ],
        ),
      ),
    );
  }
}
