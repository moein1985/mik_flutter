import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/ip_address.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';

class IpAddressesPage extends StatefulWidget {
  const IpAddressesPage({super.key});

  @override
  State<IpAddressesPage> createState() => _IpAddressesPageState();
}

class _IpAddressesPageState extends State<IpAddressesPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<String> _availableInterfaces = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final state = context.read<DashboardBloc>().state;
    
    // Check if interfaces are already loaded
    if (state is DashboardLoaded && state.interfaces != null) {
      _availableInterfaces = state.interfaces!.map((i) => i.name).toList();
    }
    
    // Check if IP addresses are already loaded
    if (state is DashboardLoaded && state.ipAddresses != null) {
      // Data already loaded, no need to fetch
      return;
    }
    
    // Load IP addresses first
    context.read<DashboardBloc>().add(const LoadIpAddresses());
    
    // Only load interfaces if not already loaded (with a small delay to avoid race condition)
    if (!(state is DashboardLoaded && state.interfaces != null)) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          context.read<DashboardBloc>().add(const LoadInterfaces());
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<IpAddress> _filterIpAddresses(List<IpAddress> addresses) {
    if (_searchQuery.isEmpty) return addresses;
    return addresses.where((ip) {
      final query = _searchQuery.toLowerCase();
      return ip.address.toLowerCase().contains(query) ||
          ip.interfaceName.toLowerCase().contains(query) ||
          ip.network.toLowerCase().contains(query) ||
          (ip.comment?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('IP Addresses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DashboardBloc>().add(const LoadIpAddresses());
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add IP'),
      ),
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is DashboardLoaded) {
            if (state.interfaces != null) {
              setState(() {
                _availableInterfaces = state.interfaces!.map((i) => i.name).toList();
              });
            }
            // Show error message if present
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              // Clear the error message
              context.read<DashboardBloc>().add(const ClearError());
            }
          }
          if (state is DashboardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DashboardLoaded && state.ipAddresses != null) {
            final allAddresses = state.ipAddresses!;
            final addresses = _filterIpAddresses(allAddresses);

            // Calculate statistics
            final staticCount = allAddresses.where((ip) => !ip.dynamic && !ip.disabled).length;
            final dynamicCount = allAddresses.where((ip) => ip.dynamic).length;
            final disabledCount = allAddresses.where((ip) => ip.disabled).length;
            final totalCount = allAddresses.length;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(const LoadIpAddresses());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Quick Tip Card
                    _buildQuickTipCard(colorScheme),
                    
                    const SizedBox(height: 16),
                    
                    // Summary Card
                    _buildSummaryCard(staticCount, dynamicCount, disabledCount, totalCount, colorScheme),
                    
                    const SizedBox(height: 16),
                    
                    // Search Bar
                    _buildSearchBar(colorScheme),
                    
                    const SizedBox(height: 16),
                    
                    // IP Addresses List
                    if (addresses.isEmpty)
                      _buildEmptyState()
                    else
                      ...addresses.map((ip) => _buildIpAddressCard(ip, colorScheme)),
                    
                    // Extra space for FAB
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(state is DashboardError ? state.message : 'Unable to load IP addresses'),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    context.read<DashboardBloc>().add(const LoadIpAddresses());
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickTipCard(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tap on any IP address to copy it to clipboard. Long press for more options.',
              style: TextStyle(
                color: Colors.blue.shade800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int staticCount, int dynamicCount, int disabledCount, int total, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: colorScheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  icon: Icons.push_pin,
                  value: '$staticCount',
                  label: 'Static',
                  color: Colors.green,
                ),
                _buildSummaryItem(
                  icon: Icons.autorenew,
                  value: '$dynamicCount',
                  label: 'Dynamic',
                  color: Colors.orange,
                ),
                _buildSummaryItem(
                  icon: Icons.block,
                  value: '$disabledCount',
                  label: 'Disabled',
                  color: Colors.red,
                ),
                _buildSummaryItem(
                  icon: Icons.public,
                  value: '$total',
                  label: 'Total',
                  color: colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
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
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search by IP, interface, network...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        filled: true,
        fillColor: colorScheme.surface,
      ),
      onChanged: (value) => setState(() => _searchQuery = value),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'No IP addresses found'
                  : 'No results for "$_searchQuery"',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIpAddressCard(IpAddress ip, ColorScheme colorScheme) {
    final canEdit = !ip.dynamic; // Can't edit dynamic IPs
    
    // Determine status color
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    if (ip.disabled) {
      statusColor = Colors.red;
      statusText = 'Disabled';
      statusIcon = Icons.block;
    } else if (ip.invalid) {
      statusColor = Colors.grey;
      statusText = 'Invalid';
      statusIcon = Icons.error;
    } else {
      statusColor = Colors.green;
      statusText = 'Active';
      statusIcon = Icons.check_circle;
    }

    // Parse IP and subnet
    final parts = ip.address.split('/');
    final ipOnly = parts[0];
    final subnet = parts.length > 1 ? '/${parts[1]}' : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _copyToClipboard(ipOnly, 'IP address'),
        onLongPress: () => _showIpOptionsSheet(ip),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with status
              Row(
                children: [
                  // Status indicator dot
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(alpha: 0.4),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // IP Address (main)
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          ipOnly,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        Text(
                          subnet,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'monospace',
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Action buttons
                  if (!ip.dynamic) ...[
                    // Toggle button
                    IconButton(
                      icon: Icon(
                        ip.disabled ? Icons.toggle_off : Icons.toggle_on,
                        size: 28,
                        color: ip.disabled ? Colors.grey : Colors.green,
                      ),
                      onPressed: () {
                        context.read<DashboardBloc>().add(
                          ToggleIpAddress(id: ip.id, enable: ip.disabled),
                        );
                      },
                      tooltip: ip.disabled ? 'Enable' : 'Disable',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                  
                  // More options
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                    onSelected: (value) {
                      switch (value) {
                        case 'copy':
                          _copyToClipboard(ipOnly, 'IP address');
                          break;
                        case 'edit':
                          _showAddEditDialog(context, ip: ip);
                          break;
                        case 'delete':
                          _showDeleteConfirmDialog(ip);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'copy',
                        child: ListTile(
                          leading: Icon(Icons.copy),
                          title: Text('Copy IP'),
                          contentPadding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      if (canEdit) ...[
                        const PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('Edit'),
                            contentPadding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text('Delete', style: TextStyle(color: Colors.red)),
                            contentPadding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Details row
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      icon: Icons.settings_ethernet,
                      label: 'Interface',
                      value: ip.interfaceName,
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      icon: Icons.lan,
                      label: 'Network',
                      value: ip.network,
                    ),
                    if (ip.comment != null && ip.comment!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        icon: Icons.comment,
                        label: 'Comment',
                        value: ip.comment!,
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Tags row
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Status tag
                  _buildTag(
                    icon: statusIcon,
                    label: statusText,
                    color: statusColor,
                  ),
                  
                  // Dynamic/Static tag
                  if (ip.dynamic)
                    _buildTag(
                      icon: Icons.autorenew,
                      label: 'Dynamic',
                      color: Colors.orange,
                    )
                  else
                    _buildTag(
                      icon: Icons.push_pin,
                      label: 'Static',
                      color: Colors.blue,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTag({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showIpOptionsSheet(IpAddress ip) {
    final parts = ip.address.split('/');
    final ipOnly = parts[0];
    final canEdit = !ip.dynamic;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  ip.address,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy IP Address'),
                subtitle: Text(ipOnly),
                onTap: () {
                  Navigator.pop(context);
                  _copyToClipboard(ipOnly, 'IP address');
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy_all),
                title: const Text('Copy with Subnet'),
                subtitle: Text(ip.address),
                onTap: () {
                  Navigator.pop(context);
                  _copyToClipboard(ip.address, 'IP address with subnet');
                },
              ),
              ListTile(
                leading: const Icon(Icons.lan),
                title: const Text('Copy Network'),
                subtitle: Text(ip.network),
                onTap: () {
                  Navigator.pop(context);
                  _copyToClipboard(ip.network, 'Network');
                },
              ),
              if (canEdit) ...[
                const Divider(),
                ListTile(
                  leading: Icon(
                    ip.disabled ? Icons.toggle_on : Icons.toggle_off,
                    color: ip.disabled ? Colors.green : Colors.orange,
                  ),
                  title: Text(ip.disabled ? 'Enable IP' : 'Disable IP'),
                  onTap: () {
                    Navigator.pop(context);
                    context.read<DashboardBloc>().add(
                      ToggleIpAddress(id: ip.id, enable: ip.disabled),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.blue),
                  title: const Text('Edit'),
                  onTap: () {
                    Navigator.pop(context);
                    _showAddEditDialog(context, ip: ip);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmDialog(ip);
                  },
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, {IpAddress? ip}) {
    final isEditing = ip != null;
    final addressController = TextEditingController(text: ip?.address ?? '');
    final commentController = TextEditingController(text: ip?.comment ?? '');
    
    // Make sure the interface list includes the current IP's interface
    List<String> interfaces = List.from(_availableInterfaces);
    if (ip != null && !interfaces.contains(ip.interfaceName)) {
      interfaces.add(ip.interfaceName);
    }
    
    // Only set selectedInterface if it exists in the list
    String? selectedInterface = (ip != null && interfaces.contains(ip.interfaceName)) 
        ? ip.interfaceName 
        : (interfaces.isNotEmpty ? null : null);
    
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(isEditing ? Icons.edit : Icons.add, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(isEditing ? 'Edit IP Address' : 'Add IP Address'),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Warning if no interfaces
                  if (interfaces.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange.shade700),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'No interfaces loaded. Please refresh the page first.',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // IP Address field
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'IP Address *',
                      hintText: '192.168.1.1/24',
                      prefixIcon: Icon(Icons.public),
                      helperText: 'Format: IP/subnet (e.g., 192.168.1.1/24)',
                    ),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an IP address';
                      }
                      // Basic IP validation
                      final regex = RegExp(
                        r'^(\d{1,3}\.){3}\d{1,3}(\/\d{1,2})?$',
                      );
                      if (!regex.hasMatch(value)) {
                        return 'Invalid IP format. Use: x.x.x.x/xx';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Interface dropdown
                  DropdownButtonFormField<String>(
                    initialValue: selectedInterface,
                    decoration: const InputDecoration(
                      labelText: 'Interface *',
                      prefixIcon: Icon(Icons.settings_ethernet),
                    ),
                    items: interfaces.map((iface) {
                      return DropdownMenuItem(
                        value: iface,
                        child: Text(iface),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedInterface = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select an interface';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Comment field
                  TextFormField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      labelText: 'Comment (optional)',
                      prefixIcon: Icon(Icons.comment),
                      hintText: 'Description for this IP',
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  if (isEditing) {
                    context.read<DashboardBloc>().add(
                      UpdateIpAddress(
                        id: ip.id,
                        address: addressController.text,
                        interfaceName: selectedInterface,
                        comment: commentController.text.isEmpty ? null : commentController.text,
                      ),
                    );
                  } else {
                    context.read<DashboardBloc>().add(
                      AddIpAddress(
                        address: addressController.text,
                        interfaceName: selectedInterface!,
                        comment: commentController.text.isEmpty ? null : commentController.text,
                      ),
                    );
                  }
                  Navigator.pop(context);
                }
              },
              icon: Icon(isEditing ? Icons.save : Icons.add),
              label: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(IpAddress ip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete IP Address'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this IP address?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ip.address,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Interface: ${ip.interfaceName}',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '⚠️ This action cannot be undone!',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () {
              context.read<DashboardBloc>().add(RemoveIpAddress(ip.id));
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
