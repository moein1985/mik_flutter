import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/dhcp_lease.dart';
import '../bloc/dhcp_bloc.dart';
import '../bloc/dhcp_event.dart';
import '../bloc/dhcp_state.dart';

class DhcpLeasesTab extends StatelessWidget {
  const DhcpLeasesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DhcpBloc, DhcpState>(
      builder: (context, state) {
        if (state is DhcpLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<DhcpLease> leases = [];
        if (state is DhcpLoaded && state.leases != null) {
          leases = state.leases!;
        }

        if (leases.isEmpty) {
          return _buildEmptyState(context);
        }

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () async {
              context.read<DhcpBloc>().add(const LoadDhcpLeases());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: leases.length,
              itemBuilder: (context, index) => _buildLeaseCard(context, leases[index]),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddLeaseDialog(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No DHCP Leases',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Leases will appear when clients connect',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          FloatingActionButton.extended(
            onPressed: () => _showAddLeaseDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Static Lease'),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaseCard(BuildContext context, DhcpLease lease) {
    Color statusColor;
    IconData statusIcon;
    switch (lease.status.toLowerCase()) {
      case 'bound':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'waiting':
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: lease.disabled ? Colors.grey : statusColor,
          child: Icon(
            lease.dynamic ? Icons.sync : Icons.push_pin,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Text(
              lease.address,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: lease.disabled ? Colors.grey : null,
              ),
            ),
            const SizedBox(width: 8),
            Icon(statusIcon, size: 16, color: statusColor),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MAC: ${lease.macAddress}'),
            if (lease.hostName != null && lease.hostName!.isNotEmpty)
              Text('Host: ${lease.hostName}'),
            Row(
              children: [
                if (lease.dynamic)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    margin: const EdgeInsets.only(right: 4, top: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('Dynamic', style: TextStyle(fontSize: 10, color: Colors.blue)),
                  ),
                if (!lease.dynamic)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    margin: const EdgeInsets.only(right: 4, top: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('Static', style: TextStyle(fontSize: 10, color: Colors.purple)),
                  ),
                if (lease.expiresAfter != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('Expires: ${lease.expiresAfter}', style: const TextStyle(fontSize: 10)),
                  ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(context, value, lease),
          itemBuilder: (context) => [
            if (lease.dynamic)
              const PopupMenuItem(
                value: 'make_static',
                child: Row(
                  children: [
                    Icon(Icons.push_pin),
                    SizedBox(width: 8),
                    Text('Make Static'),
                  ],
                ),
              ),
            PopupMenuItem(
              value: lease.disabled ? 'enable' : 'disable',
              child: Row(
                children: [
                  Icon(lease.disabled ? Icons.play_arrow : Icons.pause),
                  const SizedBox(width: 8),
                  Text(lease.disabled ? 'Enable' : 'Disable'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action, DhcpLease lease) {
    final bloc = context.read<DhcpBloc>();
    switch (action) {
      case 'make_static':
        bloc.add(MakeDhcpLeaseStatic(lease.id));
        break;
      case 'enable':
        bloc.add(EnableDhcpLease(lease.id));
        break;
      case 'disable':
        bloc.add(DisableDhcpLease(lease.id));
        break;
      case 'delete':
        _showDeleteConfirmation(context, lease);
        break;
    }
  }

  void _showAddLeaseDialog(BuildContext context) {
    final bloc = context.read<DhcpBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: const _LeaseDialog(),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, DhcpLease lease) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Lease'),
        content: Text('Are you sure you want to delete lease for "${lease.address}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<DhcpBloc>().add(RemoveDhcpLease(lease.id));
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _LeaseDialog extends StatefulWidget {
  const _LeaseDialog();

  @override
  State<_LeaseDialog> createState() => _LeaseDialogState();
}

class _LeaseDialogState extends State<_LeaseDialog> {
  final _addressController = TextEditingController();
  final _macController = TextEditingController();
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _macController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DhcpBloc, DhcpState>(
      listener: (context, state) {
        if (state is DhcpOperationSuccess) {
          Navigator.pop(context);
        }
      },
      child: AlertDialog(
        title: const Text('Add Static Lease'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'IP Address *',
                  hintText: 'e.g., 192.168.88.100',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _macController,
                decoration: const InputDecoration(
                  labelText: 'MAC Address *',
                  hintText: 'e.g., AA:BB:CC:DD:EE:FF',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: 'Comment',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _canSubmit ? _submit : null,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  bool get _canSubmit =>
      _addressController.text.isNotEmpty && _macController.text.isNotEmpty;

  void _submit() {
    context.read<DhcpBloc>().add(AddDhcpLease(
      address: _addressController.text,
      macAddress: _macController.text,
      comment: _commentController.text.isNotEmpty ? _commentController.text : null,
    ));
  }
}
