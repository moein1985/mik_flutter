import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/walled_garden.dart';
import '../bloc/hotspot_bloc.dart';
import '../bloc/hotspot_event.dart';
import '../bloc/hotspot_state.dart';

class HotspotWalledGardenPage extends StatefulWidget {
  const HotspotWalledGardenPage({super.key});

  @override
  State<HotspotWalledGardenPage> createState() => _HotspotWalledGardenPageState();
}

class _HotspotWalledGardenPageState extends State<HotspotWalledGardenPage> {
  @override
  void initState() {
    super.initState();
    context.read<HotspotBloc>().add(const LoadWalledGarden());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Walled Garden'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<HotspotBloc>().add(const LoadWalledGarden());
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        child: const Icon(Icons.add),
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
            context.read<HotspotBloc>().add(const LoadWalledGarden());
          }
        },
        builder: (context, state) {
          if (state is HotspotLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HotspotLoaded) {
            final entries = state.walledGarden ?? [];
            if (entries.isEmpty) {
              return _buildEmptyView();
            }
            return _buildEntriesList(entries);
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
            Icons.fence,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Walled Garden Entries',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add a new entry',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntriesList(List<WalledGarden> entries) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _buildEntryCard(entry);
      },
    );
  }

  Widget _buildEntryCard(WalledGarden entry) {
    final isDisabled = entry.disabled;
    
    String displayText = entry.dstHost ?? entry.dstAddress ?? entry.path ?? 'Unknown';
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Icon(
          Icons.fence,
          color: isDisabled ? Colors.grey : Colors.teal,
        ),
        title: Text(
          displayText,
          style: TextStyle(
            color: isDisabled ? Colors.grey : null,
            decoration: isDisabled ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entry.server != null)
              Text('Server: ${entry.server}'),
            if (entry.dstHost != null && entry.dstHost != displayText)
              Text('Host: ${entry.dstHost}'),
            if (entry.dstAddress != null)
              Text('Address: ${entry.dstAddress}'),
            if (entry.dstPort != null)
              Text('Port: ${entry.dstPort}'),
            if (entry.path != null && entry.path != displayText)
              Text('Path: ${entry.path}'),
            _buildActionBadge(entry.action),
            if (entry.method != null)
              Text('Method: ${entry.method}'),
            if (entry.comment != null && entry.comment!.isNotEmpty)
              Text('Comment: ${entry.comment}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'toggle':
                context.read<HotspotBloc>().add(
                  ToggleWalledGarden(id: entry.id, enable: isDisabled),
                );
                break;
              case 'edit':
                _showAddEditDialog(context, entry: entry);
                break;
              case 'delete':
                _showDeleteConfirmation(context, entry);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(isDisabled ? Icons.check_circle : Icons.block),
                  const SizedBox(width: 8),
                  Text(isDisabled ? 'Enable' : 'Disable'),
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
        isThreeLine: true,
      ),
    );
  }

  Widget _buildActionBadge(String action) {
    Color color;
    switch (action.toLowerCase()) {
      case 'allow':
        color = Colors.green;
        break;
      case 'deny':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        action.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WalledGarden entry) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Walled Garden Entry'),
        content: Text(
          'Are you sure you want to delete this entry?\n'
          '${entry.dstHost ?? entry.dstAddress ?? entry.path ?? 'Unknown'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<HotspotBloc>().add(DeleteWalledGarden(entry.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, {WalledGarden? entry}) {
    final isEditing = entry != null;
    final serverController = TextEditingController(text: entry?.server ?? '');
    final dstHostController = TextEditingController(text: entry?.dstHost ?? '');
    final dstAddressController = TextEditingController(text: entry?.dstAddress ?? '');
    final dstPortController = TextEditingController(text: entry?.dstPort ?? '');
    final pathController = TextEditingController(text: entry?.path ?? '');
    final commentController = TextEditingController(text: entry?.comment ?? '');
    String selectedAction = entry?.action ?? 'allow';
    String selectedMethod = entry?.method ?? '';
    bool disabled = entry?.disabled ?? false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Edit Walled Garden' : 'Add Walled Garden'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: serverController,
                  decoration: const InputDecoration(
                    labelText: 'Server',
                    hintText: 'all or server name',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dstHostController,
                  decoration: const InputDecoration(
                    labelText: 'Destination Host',
                    hintText: '*.google.com',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dstAddressController,
                  decoration: const InputDecoration(
                    labelText: 'Destination Address',
                    hintText: '0.0.0.0/0',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dstPortController,
                  decoration: const InputDecoration(
                    labelText: 'Destination Port',
                    hintText: '80,443',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pathController,
                  decoration: const InputDecoration(
                    labelText: 'Path',
                    hintText: '/api/*',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedAction,
                  decoration: const InputDecoration(
                    labelText: 'Action',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'allow', child: Text('Allow')),
                    DropdownMenuItem(value: 'deny', child: Text('Deny')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedAction = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedMethod.isEmpty ? null : selectedMethod,
                  decoration: const InputDecoration(
                    labelText: 'HTTP Method (optional)',
                  ),
                  items: const [
                    DropdownMenuItem(value: '', child: Text('Any')),
                    DropdownMenuItem(value: 'GET', child: Text('GET')),
                    DropdownMenuItem(value: 'POST', child: Text('POST')),
                    DropdownMenuItem(value: 'HEAD', child: Text('HEAD')),
                  ],
                  onChanged: (value) {
                    setState(() => selectedMethod = value ?? '');
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    labelText: 'Comment',
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Disabled'),
                  value: disabled,
                  onChanged: (value) {
                    setState(() => disabled = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                
                if (isEditing) {
                  this.context.read<HotspotBloc>().add(
                    EditWalledGarden(
                      id: entry.id,
                      server: serverController.text.isNotEmpty ? serverController.text : null,
                      dstHost: dstHostController.text.isNotEmpty ? dstHostController.text : null,
                      dstAddress: dstAddressController.text.isNotEmpty ? dstAddressController.text : null,
                      dstPort: dstPortController.text.isNotEmpty ? dstPortController.text : null,
                      path: pathController.text.isNotEmpty ? pathController.text : null,
                      action: selectedAction,
                      method: selectedMethod.isNotEmpty ? selectedMethod : null,
                      comment: commentController.text.isNotEmpty ? commentController.text : null,
                    ),
                  );
                } else {
                  this.context.read<HotspotBloc>().add(
                    AddWalledGarden(
                      server: serverController.text.isNotEmpty ? serverController.text : null,
                      dstHost: dstHostController.text.isNotEmpty ? dstHostController.text : null,
                      dstAddress: dstAddressController.text.isNotEmpty ? dstAddressController.text : null,
                      dstPort: dstPortController.text.isNotEmpty ? dstPortController.text : null,
                      path: pathController.text.isNotEmpty ? pathController.text : null,
                      action: selectedAction,
                      method: selectedMethod.isNotEmpty ? selectedMethod : null,
                      comment: commentController.text.isNotEmpty ? commentController.text : null,
                    ),
                  );
                }
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }
}
