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
  @override
  void initState() {
    super.initState();
    context.read<HotspotBloc>().add(const LoadHosts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hosts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<HotspotBloc>().add(const LoadHosts());
            },
          ),
        ],
      ),
      body: BlocConsumer<HotspotBloc, HotspotState>(
        listener: (context, state) {
          if (state is HotspotError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is HotspotOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Reload after successful operation
            context.read<HotspotBloc>().add(const LoadHosts());
          }
        },
        builder: (context, state) {
          if (state is HotspotLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HotspotLoaded) {
            final hosts = state.hosts ?? [];
            if (hosts.isEmpty) {
              return _buildEmptyView();
            }
            return _buildHostsList(hosts);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.devices_other,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Hosts Found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No devices are connected to the HotSpot',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHostsList(List<HotspotHost> hosts) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: hosts.length,
      itemBuilder: (context, index) {
        final host = hosts[index];
        return _buildHostCard(host);
      },
    );
  }

  Widget _buildHostCard(HotspotHost host) {
    final isAuthorized = host.authorized;
    final isBypassed = host.bypassed;
    
    Color statusColor = Colors.orange;
    String statusText = 'Not Authorized';
    
    if (isAuthorized) {
      statusColor = Colors.green;
      statusText = 'Authorized';
    } else if (isBypassed) {
      statusColor = Colors.blue;
      statusText = 'Bypassed';
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.2),
          child: Icon(
            Icons.computer,
            color: statusColor,
          ),
        ),
        title: Text(
          host.hostName ?? host.address ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (host.address != null)
              Text('IP: ${host.address}'),
            Text('MAC: ${host.macAddress}'),
            if (host.server != null)
              Text('Server: ${host.server}'),
            if (host.uptime != null)
              Text('Uptime: ${host.uptime}'),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 11,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (host.bytesIn != null || host.bytesOut != null)
              Text(
                '↓ ${_formatBytesStr(host.bytesIn)} | ↑ ${_formatBytesStr(host.bytesOut)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'make_binding':
                _showMakeBindingDialog(context, host);
                break;
              case 'remove':
                _showRemoveConfirmation(context, host);
                break;
            }
          },
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
            const PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Remove', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        isThreeLine: true,
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
