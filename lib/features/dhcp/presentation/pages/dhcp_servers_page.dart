import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/dhcp_server.dart';
import '../bloc/dhcp_bloc.dart';
import '../bloc/dhcp_event.dart';
import '../bloc/dhcp_state.dart';

class DhcpServersTab extends StatelessWidget {
  const DhcpServersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DhcpBloc, DhcpState>(
      builder: (context, state) {
        if (state is DhcpLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<DhcpServer> servers = [];
        if (state is DhcpLoaded && state.servers != null) {
          servers = state.servers!;
        }

        if (servers.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<DhcpBloc>().add(const LoadDhcpServers());
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: servers.length,
            itemBuilder: (context, index) => _buildServerCard(context, servers[index]),
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
          Icon(Icons.dns_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No DHCP Servers',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add a DHCP server',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          FloatingActionButton.extended(
            onPressed: () => _showAddServerDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Server'),
          ),
        ],
      ),
    );
  }

  Widget _buildServerCard(BuildContext context, DhcpServer server) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: server.disabled ? Colors.grey : Colors.green,
          child: Icon(
            Icons.dns,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          server.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: server.disabled ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Interface: ${server.interface}'),
            if (server.addressPool != null)
              Text('Pool: ${server.addressPool}'),
            Text('Lease: ${server.leaseTime}'),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(context, value, server),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: server.disabled ? 'enable' : 'disable',
              child: Row(
                children: [
                  Icon(server.disabled ? Icons.play_arrow : Icons.pause),
                  const SizedBox(width: 8),
                  Text(server.disabled ? 'Enable' : 'Disable'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
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

  void _handleMenuAction(BuildContext context, String action, DhcpServer server) {
    final bloc = context.read<DhcpBloc>();
    switch (action) {
      case 'enable':
        bloc.add(EnableDhcpServer(server.id));
        break;
      case 'disable':
        bloc.add(DisableDhcpServer(server.id));
        break;
      case 'edit':
        _showEditServerDialog(context, server);
        break;
      case 'delete':
        _showDeleteConfirmation(context, server);
        break;
    }
  }

  void _showAddServerDialog(BuildContext context) {
    final bloc = context.read<DhcpBloc>();
    bloc.add(const LoadDhcpSetupData());
    
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: const _ServerDialog(),
      ),
    );
  }

  void _showEditServerDialog(BuildContext context, DhcpServer server) {
    final bloc = context.read<DhcpBloc>();
    bloc.add(const LoadDhcpSetupData());
    
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: _ServerDialog(server: server),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, DhcpServer server) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Server'),
        content: Text('Are you sure you want to delete "${server.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<DhcpBloc>().add(RemoveDhcpServer(server.id));
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

class _ServerDialog extends StatefulWidget {
  final DhcpServer? server;

  const _ServerDialog({this.server});

  @override
  State<_ServerDialog> createState() => _ServerDialogState();
}

class _ServerDialogState extends State<_ServerDialog> {
  final _nameController = TextEditingController();
  String? _selectedInterface;
  String? _selectedPool;
  final _leaseTimeController = TextEditingController(text: '10m');
  bool _authoritative = true;

  List<Map<String, String>> _interfaces = [];
  List<Map<String, String>> _pools = [];
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.server != null) {
      _nameController.text = widget.server!.name;
      _selectedInterface = widget.server!.interface;
      _selectedPool = widget.server!.addressPool;
      _leaseTimeController.text = widget.server!.leaseTime;
      _authoritative = widget.server!.authoritative;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _leaseTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DhcpBloc, DhcpState>(
      listener: (context, state) {
        if (state is DhcpSetupDataLoaded) {
          setState(() {
            _interfaces = state.interfaces;
            _pools = state.ipPools;
            _dataLoaded = true;
          });
        } else if (state is DhcpOperationSuccess) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        if (!_dataLoaded && state is DhcpLoading) {
          return AlertDialog(
            title: Text(widget.server == null ? 'Add DHCP Server' : 'Edit DHCP Server'),
            content: const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return AlertDialog(
          title: Text(widget.server == null ? 'Add DHCP Server' : 'Edit DHCP Server'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    hintText: 'e.g., dhcp1',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedInterface,
                  decoration: const InputDecoration(
                    labelText: 'Interface *',
                    border: OutlineInputBorder(),
                  ),
                  items: _interfaces.map((iface) {
                    final name = iface['name'] ?? '';
                    return DropdownMenuItem(value: name, child: Text(name));
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedInterface = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedPool,
                  decoration: const InputDecoration(
                    labelText: 'Address Pool',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('None')),
                    ..._pools.map((pool) {
                      final name = pool['name'] ?? '';
                      return DropdownMenuItem(value: name, child: Text(name));
                    }),
                  ],
                  onChanged: (value) => setState(() => _selectedPool = value),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _leaseTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Lease Time',
                    hintText: 'e.g., 10m, 1h, 1d',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Authoritative'),
                  subtitle: const Text('Respond to DHCP requests even if client requested different server'),
                  value: _authoritative,
                  onChanged: (value) => setState(() => _authoritative = value),
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
              child: Text(widget.server == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  bool get _canSubmit =>
      _nameController.text.isNotEmpty && _selectedInterface != null;

  void _submit() {
    final bloc = context.read<DhcpBloc>();
    if (widget.server == null) {
      bloc.add(AddDhcpServer(
        name: _nameController.text,
        interface: _selectedInterface!,
        addressPool: _selectedPool,
        leaseTime: _leaseTimeController.text,
        authoritative: _authoritative,
      ));
    } else {
      bloc.add(EditDhcpServer(
        id: widget.server!.id,
        name: _nameController.text,
        interface: _selectedInterface,
        addressPool: _selectedPool,
        leaseTime: _leaseTimeController.text,
        authoritative: _authoritative,
      ));
    }
  }
}
