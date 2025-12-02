import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/hotspot_ip_binding.dart';
import '../bloc/hotspot_bloc.dart';
import '../bloc/hotspot_event.dart';
import '../bloc/hotspot_state.dart';

class HotspotIpBindingsPage extends StatefulWidget {
  const HotspotIpBindingsPage({super.key});

  @override
  State<HotspotIpBindingsPage> createState() => _HotspotIpBindingsPageState();
}

class _HotspotIpBindingsPageState extends State<HotspotIpBindingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<HotspotBloc>().add(const LoadIpBindings());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IP Bindings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<HotspotBloc>().add(const LoadIpBindings());
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
            context.read<HotspotBloc>().add(const LoadIpBindings());
          }
        },
        builder: (context, state) {
          if (state is HotspotLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HotspotLoaded) {
            final bindings = state.ipBindings ?? [];
            if (bindings.isEmpty) {
              return _buildEmptyView();
            }
            return _buildBindingsList(bindings);
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
            Icons.link_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No IP Bindings',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add a new IP binding',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBindingsList(List<HotspotIpBinding> bindings) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: bindings.length,
      itemBuilder: (context, index) {
        final binding = bindings[index];
        return _buildBindingCard(binding);
      },
    );
  }

  Widget _buildBindingCard(HotspotIpBinding binding) {
    final isDisabled = binding.disabled;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Icon(
          Icons.link,
          color: isDisabled ? Colors.grey : Colors.blue,
        ),
        title: Text(
          binding.address ?? binding.mac ?? 'Unknown',
          style: TextStyle(
            color: isDisabled ? Colors.grey : null,
            decoration: isDisabled ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (binding.mac != null)
              Text('MAC: ${binding.mac}'),
            if (binding.toAddress != null)
              Text('To: ${binding.toAddress}'),
            if (binding.server != null)
              Text('Server: ${binding.server}'),
            Text('Type: ${binding.type}'),
            if (binding.comment != null && binding.comment!.isNotEmpty)
              Text('Comment: ${binding.comment}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'toggle':
                context.read<HotspotBloc>().add(
                  ToggleIpBinding(id: binding.id, enable: isDisabled),
                );
                break;
              case 'edit':
                _showAddEditDialog(context, binding: binding);
                break;
              case 'delete':
                _showDeleteConfirmation(context, binding);
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

  void _showDeleteConfirmation(BuildContext context, HotspotIpBinding binding) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete IP Binding'),
        content: Text(
          'Are you sure you want to delete this IP binding?\n'
          '${binding.address ?? binding.mac ?? 'Unknown'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<HotspotBloc>().add(DeleteIpBinding(binding.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, {HotspotIpBinding? binding}) {
    final isEditing = binding != null;
    final macController = TextEditingController(text: binding?.mac ?? '');
    final addressController = TextEditingController(text: binding?.address ?? '');
    final toAddressController = TextEditingController(text: binding?.toAddress ?? '');
    final serverController = TextEditingController(text: binding?.server ?? '');
    final commentController = TextEditingController(text: binding?.comment ?? '');
    String selectedType = binding?.type ?? 'regular';
    bool disabled = binding?.disabled ?? false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Edit IP Binding' : 'Add IP Binding'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: macController,
                  decoration: const InputDecoration(
                    labelText: 'MAC Address',
                    hintText: 'AA:BB:CC:DD:EE:FF',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    hintText: '192.168.1.100',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: toAddressController,
                  decoration: const InputDecoration(
                    labelText: 'To Address',
                    hintText: '192.168.1.200',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: serverController,
                  decoration: const InputDecoration(
                    labelText: 'Server',
                    hintText: 'all or server name',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'regular', child: Text('Regular')),
                    DropdownMenuItem(value: 'bypassed', child: Text('Bypassed')),
                    DropdownMenuItem(value: 'blocked', child: Text('Blocked')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedType = value);
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
                    EditIpBinding(
                      id: binding.id,
                      mac: macController.text.isNotEmpty ? macController.text : null,
                      address: addressController.text.isNotEmpty ? addressController.text : null,
                      toAddress: toAddressController.text.isNotEmpty ? toAddressController.text : null,
                      server: serverController.text.isNotEmpty ? serverController.text : null,
                      type: selectedType,
                      comment: commentController.text.isNotEmpty ? commentController.text : null,
                    ),
                  );
                } else {
                  this.context.read<HotspotBloc>().add(
                    AddIpBinding(
                      mac: macController.text.isNotEmpty ? macController.text : null,
                      address: addressController.text.isNotEmpty ? addressController.text : null,
                      toAddress: toAddressController.text.isNotEmpty ? toAddressController.text : null,
                      server: serverController.text.isNotEmpty ? serverController.text : null,
                      type: selectedType,
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
