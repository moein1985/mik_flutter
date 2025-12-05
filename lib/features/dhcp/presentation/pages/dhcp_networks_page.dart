import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/dhcp_network.dart';
import '../bloc/dhcp_bloc.dart';
import '../bloc/dhcp_event.dart';
import '../bloc/dhcp_state.dart';

class DhcpNetworksTab extends StatelessWidget {
  const DhcpNetworksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DhcpBloc, DhcpState>(
      builder: (context, state) {
        if (state is DhcpLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<DhcpNetwork> networks = [];
        if (state is DhcpLoaded && state.networks != null) {
          networks = state.networks!;
        }

        if (networks.isEmpty) {
          return _buildEmptyState(context);
        }

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () async {
              context.read<DhcpBloc>().add(const LoadDhcpNetworks());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: networks.length,
              itemBuilder: (context, index) => _buildNetworkCard(context, networks[index]),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddNetworkDialog(context),
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
          Icon(Icons.lan_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No DHCP Networks',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Networks define DHCP options for clients',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          FloatingActionButton.extended(
            onPressed: () => _showAddNetworkDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Network'),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkCard(BuildContext context, DhcpNetwork network) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: const Icon(Icons.lan, color: Colors.white, size: 20),
        ),
        title: Text(
          network.address,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: network.gateway != null ? Text('Gateway: ${network.gateway}') : null,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (network.gateway != null)
                  _buildInfoRow('Gateway', network.gateway!),
                if (network.dnsServer != null)
                  _buildInfoRow('DNS', network.dnsServer!),
                if (network.domain != null)
                  _buildInfoRow('Domain', network.domain!),
                if (network.netmask != null)
                  _buildInfoRow('Netmask', network.netmask!),
                if (network.comment != null)
                  _buildInfoRow('Comment', network.comment!),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showEditNetworkDialog(context, network),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                    TextButton.icon(
                      onPressed: () => _showDeleteConfirmation(context, network),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showAddNetworkDialog(BuildContext context) {
    final bloc = context.read<DhcpBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: const _NetworkDialog(),
      ),
    );
  }

  void _showEditNetworkDialog(BuildContext context, DhcpNetwork network) {
    final bloc = context.read<DhcpBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: _NetworkDialog(network: network),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, DhcpNetwork network) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Network'),
        content: Text('Are you sure you want to delete "${network.address}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<DhcpBloc>().add(RemoveDhcpNetwork(network.id));
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

class _NetworkDialog extends StatefulWidget {
  final DhcpNetwork? network;

  const _NetworkDialog({this.network});

  @override
  State<_NetworkDialog> createState() => _NetworkDialogState();
}

class _NetworkDialogState extends State<_NetworkDialog> {
  final _addressController = TextEditingController();
  final _gatewayController = TextEditingController();
  final _dnsController = TextEditingController();
  final _domainController = TextEditingController();
  final _netmaskController = TextEditingController();
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.network != null) {
      _addressController.text = widget.network!.address;
      _gatewayController.text = widget.network!.gateway ?? '';
      _dnsController.text = widget.network!.dnsServer ?? '';
      _domainController.text = widget.network!.domain ?? '';
      _netmaskController.text = widget.network!.netmask ?? '';
      _commentController.text = widget.network!.comment ?? '';
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _gatewayController.dispose();
    _dnsController.dispose();
    _domainController.dispose();
    _netmaskController.dispose();
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
        title: Text(widget.network == null ? 'Add DHCP Network' : 'Edit DHCP Network'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Network Address *',
                  hintText: 'e.g., 192.168.88.0/24',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _gatewayController,
                decoration: const InputDecoration(
                  labelText: 'Gateway',
                  hintText: 'e.g., 192.168.88.1',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _dnsController,
                decoration: const InputDecoration(
                  labelText: 'DNS Server',
                  hintText: 'e.g., 8.8.8.8',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _domainController,
                decoration: const InputDecoration(
                  labelText: 'Domain',
                  hintText: 'e.g., local',
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
            child: Text(widget.network == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  bool get _canSubmit => _addressController.text.isNotEmpty;

  void _submit() {
    final bloc = context.read<DhcpBloc>();
    if (widget.network == null) {
      bloc.add(AddDhcpNetwork(
        address: _addressController.text,
        gateway: _gatewayController.text.isNotEmpty ? _gatewayController.text : null,
        dnsServer: _dnsController.text.isNotEmpty ? _dnsController.text : null,
        domain: _domainController.text.isNotEmpty ? _domainController.text : null,
        netmask: _netmaskController.text.isNotEmpty ? _netmaskController.text : null,
        comment: _commentController.text.isNotEmpty ? _commentController.text : null,
      ));
    } else {
      bloc.add(EditDhcpNetwork(
        id: widget.network!.id,
        address: _addressController.text,
        gateway: _gatewayController.text.isNotEmpty ? _gatewayController.text : null,
        dnsServer: _dnsController.text.isNotEmpty ? _dnsController.text : null,
        domain: _domainController.text.isNotEmpty ? _domainController.text : null,
        netmask: _netmaskController.text.isNotEmpty ? _netmaskController.text : null,
        comment: _commentController.text.isNotEmpty ? _commentController.text : null,
      ));
    }
  }
}
