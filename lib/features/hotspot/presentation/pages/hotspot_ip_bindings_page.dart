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
  String? _lastShownMessage;

  @override
  void initState() {
    super.initState();
    context.read<HotspotBloc>().add(const LoadIpBindings());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('IP Bindings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
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
            if (_lastShownMessage != state.message) {
              _lastShownMessage = state.message;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
              // Reload to return to normal state
              context.read<HotspotBloc>().add(const LoadIpBindings());
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
              context.read<HotspotBloc>().add(const LoadIpBindings());
            }
          } else {
            _lastShownMessage = null;
          }
        },
        builder: (context, state) {
          return switch (state) {
            HotspotLoading() => const Center(child: CircularProgressIndicator()),
            HotspotLoaded(:final ipBindings) => ipBindings == null || ipBindings.isEmpty
                ? _buildEmptyView(colorScheme)
                : _buildBindingsList(ipBindings, colorScheme),
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
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.link, color: Colors.teal.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'IP bindings map MAC addresses to specific IPs and allow bypassing or blocking hotspot authentication.',
              style: TextStyle(
                color: Colors.teal.shade800,
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
              Icons.link_off,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No IP Bindings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add a new IP binding',
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
            state is HotspotError ? state.message : 'Unable to load bindings',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              context.read<HotspotBloc>().add(const LoadIpBindings());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildBindingsList(List<HotspotIpBinding> bindings, ColorScheme colorScheme) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HotspotBloc>().add(const LoadIpBindings());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildQuickTipCard(),
            
            const SizedBox(height: 16),
            
            // Count
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                '${bindings.length} binding${bindings.length > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            
            // Binding cards
            ...bindings.map((binding) => _buildBindingCard(binding, colorScheme)),
            
            // Bottom spacing for FAB
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildBindingCard(HotspotIpBinding binding, ColorScheme colorScheme) {
    final isDisabled = binding.disabled;
    final typeColor = _getTypeColor(binding.type);
    
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDisabled 
              ? colorScheme.outline.withAlpha(26) 
              : colorScheme.outline.withAlpha(51),
        ),
      ),
      child: Opacity(
        opacity: isDisabled ? 0.6 : 1.0,
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
                      color: typeColor.withAlpha(26),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.link,
                      color: typeColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          binding.address ?? binding.mac ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: isDisabled ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            // Status dot
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isDisabled ? Colors.grey : Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isDisabled ? 'Disabled' : 'Active',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Type tag
                            _buildTypeTag(binding.type, typeColor),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleMenuAction(value, binding),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'toggle',
                        child: Row(
                          children: [
                            Icon(
                              isDisabled ? Icons.check_circle : Icons.block,
                              color: isDisabled ? Colors.green : Colors.orange,
                            ),
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
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: colorScheme.error),
                            const SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: colorScheme.error)),
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
              
              // Details
              if (binding.mac != null)
                _buildDetailRow(Icons.devices, 'MAC', binding.mac!, colorScheme),
              if (binding.toAddress != null)
                _buildDetailRow(Icons.arrow_forward, 'To Address', binding.toAddress!, colorScheme),
              if (binding.server != null)
                _buildDetailRow(Icons.dns, 'Server', binding.server!, colorScheme),
              if (binding.comment != null && binding.comment!.isNotEmpty)
                _buildDetailRow(Icons.comment, 'Comment', binding.comment!, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeTag(String type, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'bypassed':
        return Colors.green;
      case 'blocked':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Widget _buildDetailRow(IconData icon, String label, String value, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, HotspotIpBinding binding) {
    switch (action) {
      case 'toggle':
        context.read<HotspotBloc>().add(
          ToggleIpBinding(id: binding.id, enable: binding.disabled),
        );
        break;
      case 'edit':
        _showAddEditDialog(context, binding: binding);
        break;
      case 'delete':
        _showDeleteConfirmation(context, binding);
        break;
    }
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
