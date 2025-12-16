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
  String? _lastShownMessage;

  @override
  void initState() {
    super.initState();
    context.read<HotspotBloc>().add(const LoadWalledGarden());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Walled Garden'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
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
            if (_lastShownMessage != state.message) {
              _lastShownMessage = state.message;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
              // Reload to return to normal state
              context.read<HotspotBloc>().add(const LoadWalledGarden());
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
              // Reload after successful operation with a small delay
              Future.delayed(const Duration(milliseconds: 1000), () {
                if (!mounted) return;
                // ignore: use_build_context_synchronously
                context.read<HotspotBloc>().add(const LoadWalledGarden());
              });
            }
          } else {
            _lastShownMessage = null;
          }
        },
        builder: (context, state) {
          return switch (state) {
            HotspotLoading() => const Center(child: CircularProgressIndicator()),
            HotspotLoaded(:final walledGarden) => walledGarden == null || walledGarden.isEmpty
                ? _buildEmptyView(colorScheme)
                : _buildEntriesList(walledGarden, colorScheme),
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
        color: Colors.deepOrange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepOrange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.fence, color: Colors.deepOrange.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Walled Garden allows specific destinations to be accessible without authentication.',
              style: TextStyle(
                color: Colors.deepOrange.shade800,
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
              Icons.fence,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Walled Garden Entries',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add a new entry',
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
            state is HotspotError ? state.message : 'Unable to load entries',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              context.read<HotspotBloc>().add(const LoadWalledGarden());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEntriesList(List<WalledGarden> entries, ColorScheme colorScheme) {
    // Count by action
    final allowCount = entries.where((e) => e.action.toLowerCase() == 'allow').length;
    final denyCount = entries.length - allowCount;
    
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HotspotBloc>().add(const LoadWalledGarden());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildQuickTipCard(),
            
            const SizedBox(height: 16),
            
            // Count summary
            _buildCountSummary(entries.length, allowCount, denyCount, colorScheme),
            
            const SizedBox(height: 16),
            
            // Entry cards
            ...entries.map((entry) => _buildEntryCard(entry, colorScheme)),
            
            // Bottom spacing for FAB
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildCountSummary(int total, int allow, int deny, ColorScheme colorScheme) {
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
            '$total entr${total > 1 ? 'ies' : 'y'}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          if (allow > 0)
            _buildMiniTag('$allow Allow', Colors.green),
          if (deny > 0) ...[
            const SizedBox(width: 8),
            _buildMiniTag('$deny Deny', Colors.red),
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

  Widget _buildEntryCard(WalledGarden entry, ColorScheme colorScheme) {
    final isDisabled = entry.disabled;
    final actionColor = _getActionColor(entry.action);
    
    String displayText = entry.dstHost ?? entry.dstAddress ?? entry.path ?? 'Unknown';
    
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
                      color: actionColor.withAlpha(26),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.fence,
                      color: actionColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayText,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: isDisabled ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            // Status
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
                            // Action tag
                            _buildActionTag(entry.action, actionColor),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleMenuAction(value, entry),
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
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (entry.server != null)
                    _buildDetailChip(Icons.dns, 'Server: ${entry.server}', colorScheme),
                  if (entry.dstAddress != null && entry.dstAddress != displayText)
                    _buildDetailChip(Icons.location_on, entry.dstAddress!, colorScheme),
                  if (entry.dstPort != null)
                    _buildDetailChip(Icons.directions_boat, 'Port: ${entry.dstPort}', colorScheme),
                  if (entry.path != null && entry.path != displayText)
                    _buildDetailChip(Icons.route, entry.path!, colorScheme),
                  if (entry.method != null)
                    _buildDetailChip(Icons.http, entry.method!, colorScheme),
                ],
              ),
              
              if (entry.comment != null && entry.comment!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.comment, size: 14, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        entry.comment!,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTag(String action, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        action.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
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

  Color _getActionColor(String action) {
    switch (action.toLowerCase()) {
      case 'allow':
        return Colors.green;
      case 'deny':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _handleMenuAction(String action, WalledGarden entry) {
    switch (action) {
      case 'toggle':
        context.read<HotspotBloc>().add(
          ToggleWalledGarden(id: entry.id, enable: entry.disabled),
        );
        break;
      case 'edit':
        _showAddEditDialog(context, entry: entry);
        break;
      case 'delete':
        _showDeleteConfirmation(context, entry);
        break;
    }
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
    final formKey = GlobalKey<FormState>();
    final serverController = TextEditingController(text: entry?.server ?? '');
    final dstHostController = TextEditingController(text: entry?.dstHost ?? '');
    final dstAddressController = TextEditingController(text: entry?.dstAddress ?? '');
    final dstPortController = TextEditingController(text: entry?.dstPort ?? '');
    final pathController = TextEditingController(text: entry?.path ?? '');
    final commentController = TextEditingController(text: entry?.comment ?? '');
    String selectedAction = entry?.action ?? 'allow';
    String selectedMethod = entry?.method ?? '';
    bool disabled = entry?.disabled ?? false;
    
    final isFormValid = ValueNotifier<bool>(false);

    // Validators
    String? validateDomain(String? value) {
      if (value == null || value.trim().isEmpty) return null; // Optional
      // Domain format: example.com, *.google.com, subdomain.example.com
      final regex = RegExp(r'^(\*\.)?[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?)*$');
      if (!regex.hasMatch(value)) {
        return 'Invalid domain. Use: example.com or *.google.com';
      }
      return null;
    }

    String? validateIpAddressOrCidr(String? value) {
      if (value == null || value.trim().isEmpty) return null; // Optional
      // IPv4 with optional CIDR: 192.168.1.100 or 192.168.1.0/24
      final regex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}(\/\d{1,2})?$');
      if (!regex.hasMatch(value)) {
        return 'Invalid IP. Use: 192.168.1.100 or 192.168.1.0/24';
      }
      // Validate each octet
      final ipPart = value.split('/')[0];
      final parts = ipPart.split('.');
      for (final part in parts) {
        final num = int.tryParse(part);
        if (num == null || num < 0 || num > 255) {
          return 'IP octet must be 0-255';
        }
      }
      // Validate CIDR if present
      if (value.contains('/')) {
        final cidr = int.tryParse(value.split('/')[1]);
        if (cidr == null || cidr < 0 || cidr > 32) {
          return 'CIDR must be 0-32';
        }
      }
      return null;
    }

    String? validatePort(String? value) {
      if (value == null || value.trim().isEmpty) return null; // Optional
      final port = int.tryParse(value);
      if (port == null || port < 1 || port > 65535) {
        return 'Port must be 1-65535';
      }
      return null;
    }

    bool hasAtLeastOneDestination() {
      return dstHostController.text.trim().isNotEmpty || 
             dstAddressController.text.trim().isNotEmpty;
    }

    void validateForm() {
      final isValid = (formKey.currentState?.validate() ?? false) && hasAtLeastOneDestination();
      isFormValid.value = isValid;
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Edit Walled Garden' : 'Add Walled Garden'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: validateForm,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'At least one of Destination Host or Destination Address is required',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: serverController,
                    decoration: const InputDecoration(
                      labelText: 'Server',
                      hintText: 'all or server name',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: dstHostController,
                    decoration: const InputDecoration(
                      labelText: 'Destination Host',
                      hintText: '*.google.com',
                      helperText: 'Domain name with optional wildcard',
                    ),
                    validator: validateDomain,
                    onChanged: (_) => validateForm(),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: dstAddressController,
                    decoration: const InputDecoration(
                      labelText: 'Destination Address',
                      hintText: '0.0.0.0/0',
                      helperText: 'IPv4 with optional CIDR',
                    ),
                    validator: validateIpAddressOrCidr,
                    onChanged: (_) => validateForm(),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: dstPortController,
                    decoration: const InputDecoration(
                      labelText: 'Destination Port',
                      hintText: '80,443',
                      helperText: 'Port number 1-65535',
                    ),
                    keyboardType: TextInputType.number,
                    validator: validatePort,
                    onChanged: (_) => validateForm(),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
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
                  TextFormField(
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
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: isFormValid,
              builder: (context, isValid, child) {
                return ElevatedButton(
                  onPressed: !isValid ? null : () {
                    if (!formKey.currentState!.validate() || !hasAtLeastOneDestination()) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text('Please provide at least Destination Host or Destination Address'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
