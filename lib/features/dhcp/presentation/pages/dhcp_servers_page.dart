import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/dhcp_server.dart';
import '../bloc/dhcp_bloc.dart';
import '../bloc/dhcp_event.dart';
import '../bloc/dhcp_state.dart';

class DhcpServersTab extends StatefulWidget {
  const DhcpServersTab({super.key});

  @override
  State<DhcpServersTab> createState() => _DhcpServersTabState();
}

class _DhcpServersTabState extends State<DhcpServersTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DhcpServer> _filterServers(List<DhcpServer> servers) {
    if (_searchQuery.isEmpty) return servers;
    return servers.where((server) {
      final query = _searchQuery.toLowerCase();
      return server.name.toLowerCase().contains(query) ||
          server.interface.toLowerCase().contains(query) ||
          (server.addressPool?.toLowerCase().contains(query) ?? false);
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

    return BlocBuilder<DhcpBloc, DhcpState>(
      builder: (context, state) {
        return switch (state) {
          DhcpLoading() => const Center(child: CircularProgressIndicator()),
          DhcpLoaded(:final servers) => _buildServersList(context, servers ?? [], colorScheme),
          _ => _buildServersList(context, [], colorScheme),
        };
      },
    );
  }

  Widget _buildServersList(BuildContext context, List<DhcpServer> allServers, ColorScheme colorScheme) {
    final servers = _filterServers(allServers);

    // Calculate statistics
    final activeCount = allServers.where((s) => !s.disabled && !s.invalid).length;
    final disabledCount = allServers.where((s) => s.disabled).length;
    final totalCount = allServers.length;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<DhcpBloc>().add(const LoadDhcpServers());
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
            _buildSummaryCard(activeCount, disabledCount, totalCount, colorScheme),

            const SizedBox(height: 16),

            // Search Bar
            _buildSearchBar(colorScheme),

            const SizedBox(height: 16),

            // Servers List
            if (allServers.isEmpty)
              _buildEmptyState(context)
            else if (servers.isEmpty)
              _buildNoResultsState()
            else
              ...servers.map((server) => _buildServerCard(context, server, colorScheme)),

            // Extra space for FAB
            const SizedBox(height: 80),
          ],
        ),
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
              'DHCP servers assign IP addresses automatically to devices on your network.',
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

  Widget _buildSummaryCard(int activeCount, int disabledCount, int total, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.dns, color: colorScheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'DHCP Servers Overview',
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
                  icon: Icons.check_circle,
                  value: '$activeCount',
                  label: 'Active',
                  color: Colors.green,
                ),
                _buildSummaryItem(
                  icon: Icons.block,
                  value: '$disabledCount',
                  label: 'Disabled',
                  color: Colors.red,
                ),
                _buildSummaryItem(
                  icon: Icons.dns,
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
        hintText: 'Search servers...',
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.dns_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No DHCP Servers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a DHCP server to automatically\nassign IP addresses to your network devices.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showAddServerDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add DHCP Server'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
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
              'No results for "$_searchQuery"',
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

  Widget _buildServerCard(BuildContext context, DhcpServer server, ColorScheme colorScheme) {
    // Determine status
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (server.disabled) {
      statusColor = Colors.red;
      statusText = 'Disabled';
      statusIcon = Icons.block;
    } else if (server.invalid) {
      statusColor = Colors.grey;
      statusText = 'Invalid';
      statusIcon = Icons.error;
    } else {
      statusColor = Colors.green;
      statusText = 'Active';
      statusIcon = Icons.check_circle;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _copyToClipboard(server.name, 'Server name'),
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

                  // Server Name
                  Expanded(
                    child: Text(
                      server.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Toggle button
                  IconButton(
                    icon: Icon(
                      server.disabled ? Icons.toggle_off : Icons.toggle_on,
                      size: 28,
                      color: server.disabled ? Colors.grey : Colors.green,
                    ),
                    onPressed: () {
                      if (server.disabled) {
                        context.read<DhcpBloc>().add(EnableDhcpServer(server.id));
                      } else {
                        context.read<DhcpBloc>().add(DisableDhcpServer(server.id));
                      }
                    },
                    tooltip: server.disabled ? 'Enable' : 'Disable',
                    visualDensity: VisualDensity.compact,
                  ),

                  // More options
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                    onSelected: (value) => _handleMenuAction(context, value, server),
                    itemBuilder: (context) => [
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
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Details section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      icon: Icons.router,
                      label: 'Interface',
                      value: server.interface,
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      icon: Icons.pool,
                      label: 'Address Pool',
                      value: server.addressPool ?? 'None',
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      icon: Icons.timer,
                      label: 'Lease Time',
                      value: server.leaseTime,
                    ),
                    if (server.authoritative) ...[
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        icon: Icons.verified,
                        label: 'Mode',
                        value: 'Authoritative',
                        valueColor: Colors.blue,
                      ),
                    ],
                  ],
                ),
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
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  void _handleMenuAction(BuildContext context, String action, DhcpServer server) {
    switch (action) {
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
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 48),
        title: const Text('Delete Server'),
        content: Text('Are you sure you want to delete "${server.name}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<DhcpBloc>().add(RemoveDhcpServer(server.id));
              Navigator.pop(dialogContext);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
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
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedInterface;
  String? _selectedPool;
  final _leaseTimeController = TextEditingController(text: '10m');
  bool _authoritative = true;

  // For creating new pool
  bool _showCreatePool = false;
  final _poolNameController = TextEditingController();
  final _poolRangesController = TextEditingController();
  bool _isCreatingPool = false;
  String? _poolRangesError;

  // Network fields (auto-create network with server)
  final _networkAddressController = TextEditingController();
  final _gatewayController = TextEditingController();
  final _dnsController = TextEditingController();

  List<Map<String, String>> _interfaces = [];
  List<Map<String, String>> _pools = [];

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
    _poolNameController.dispose();
    _poolRangesController.dispose();
    _networkAddressController.dispose();
    _gatewayController.dispose();
    _dnsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocConsumer<DhcpBloc, DhcpState>(
      listener: (context, state) {
        if (state is DhcpSetupDataLoaded) {
          setState(() {
            _interfaces = state.interfaces;
            _pools = state.ipPools;

            // Include current interface if editing and not in list
            if (widget.server != null && _selectedInterface != null) {
              final exists = _interfaces.any((i) => i['name'] == _selectedInterface);
              if (!exists) {
                _interfaces = [
                  {'name': _selectedInterface!},
                  ..._interfaces,
                ];
              }
            }
          });
        } else if (state is IpPoolCreated) {
          setState(() {
            _interfaces = state.setupData.interfaces;
            _pools = state.setupData.ipPools;
            _selectedPool = state.poolName;
            _showCreatePool = false;
            _isCreatingPool = false;
            _poolNameController.clear();
            _poolRangesController.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Pool "${state.poolName}" created'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is DhcpOperationSuccess) {
          Navigator.pop(context);
        } else if (state is DhcpError && _isCreatingPool) {
          setState(() => _isCreatingPool = false);
        }
      },
      builder: (context, state) {
        // Get data directly from state
        List<Map<String, String>> interfaces = _interfaces;
        List<Map<String, String>> pools = _pools;
        bool isLoading = state is DhcpLoading;
        
        if (state is DhcpSetupDataLoaded) {
          interfaces = state.interfaces;
          pools = state.ipPools;
          // Include current interface if editing and not in list
          if (widget.server != null && _selectedInterface != null) {
            final exists = interfaces.any((i) => i['name'] == _selectedInterface);
            if (!exists) {
              interfaces = [
                {'name': _selectedInterface!},
                ...interfaces,
              ];
            }
          }
        } else if (state is IpPoolCreated) {
          interfaces = state.setupData.interfaces;
          pools = state.setupData.ipPools;
        }

        if (isLoading && interfaces.isEmpty) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.dns, color: colorScheme.primary),
                const SizedBox(width: 12),
                Text(widget.server == null ? 'Add DHCP Server' : 'Edit DHCP Server'),
              ],
            ),
            content: const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.dns, color: colorScheme.primary),
              const SizedBox(width: 12),
              Text(widget.server == null ? 'Add DHCP Server' : 'Edit DHCP Server'),
            ],
          ),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name *',
                      hintText: 'e.g., dhcp1',
                      prefixIcon: const Icon(Icons.label),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedInterface,
                    decoration: InputDecoration(
                      labelText: 'Interface *',
                      prefixIcon: const Icon(Icons.router),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: interfaces.map((iface) {
                      final name = iface['name'] ?? '';
                      return DropdownMenuItem(value: name, child: Text(name));
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedInterface = value),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select an interface';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Address Pool with Create option
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedPool,
                          decoration: InputDecoration(
                            labelText: 'Address Pool',
                            prefixIcon: const Icon(Icons.pool),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('None')),
                            ...pools.map((pool) {
                              final name = pool['name'] ?? '';
                              return DropdownMenuItem(value: name, child: Text(name));
                            }),
                          ],
                          onChanged: (value) => setState(() => _selectedPool = value),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: () => setState(() => _showCreatePool = !_showCreatePool),
                        icon: Icon(_showCreatePool ? Icons.close : Icons.add),
                        tooltip: _showCreatePool ? 'Cancel' : 'Create new pool',
                        style: IconButton.styleFrom(
                          backgroundColor: _showCreatePool 
                              ? colorScheme.error 
                              : colorScheme.primaryContainer,
                          foregroundColor: _showCreatePool 
                              ? colorScheme.onError 
                              : colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                  
                  // Create Pool Section
                  if (_showCreatePool) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.add_circle, size: 18, color: colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Create New Pool',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _poolNameController,
                            decoration: InputDecoration(
                              labelText: 'Pool Name *',
                              hintText: 'e.g., dhcp-pool',
                              prefixIcon: const Icon(Icons.label_outline),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: colorScheme.surface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _poolRangesController,
                            decoration: InputDecoration(
                              labelText: 'IP Range *',
                              hintText: 'e.g., 192.168.1.100-192.168.1.200',
                              prefixIcon: const Icon(Icons.lan_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: colorScheme.surface,
                              helperText: 'Format: start_ip-end_ip',
                              errorText: _poolRangesError,
                            ),
                            onChanged: (_) => setState(() => _poolRangesError = null),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _isCreatingPool ? null : _createPool,
                              icon: _isCreatingPool 
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.add),
                              label: Text(_isCreatingPool ? 'Creating...' : 'Create Pool'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _leaseTimeController,
                    decoration: InputDecoration(
                      labelText: 'Lease Time',
                      hintText: 'e.g., 10m, 1h, 1d',
                      prefixIcon: const Icon(Icons.timer),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      helperText: 'Format: 10m (minutes), 1h (hours), 1d (days)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SwitchListTile(
                      title: const Text('Authoritative'),
                      subtitle: const Text(
                        'Respond to DHCP requests even if client requested a different server',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: _authoritative,
                      onChanged: (value) => setState(() => _authoritative = value),
                    ),
                  ),
                  
                  // Network Settings Section - only show for new servers
                  if (widget.server == null) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lan, size: 18, color: colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Network Settings (Optional)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Network will be auto-created for DHCP clients',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _networkAddressController,
                            decoration: InputDecoration(
                              labelText: 'Network Address',
                              hintText: 'e.g., 192.168.88.0/24',
                              prefixIcon: const Icon(Icons.lan),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: colorScheme.surface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _gatewayController,
                            decoration: InputDecoration(
                              labelText: 'Gateway',
                              hintText: 'e.g., 192.168.88.1',
                              prefixIcon: const Icon(Icons.router),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: colorScheme.surface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _dnsController,
                            decoration: InputDecoration(
                              labelText: 'DNS Server',
                              hintText: 'e.g., 8.8.8.8 or router IP',
                              prefixIcon: const Icon(Icons.dns),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: colorScheme.surface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
              onPressed: _canSubmit ? _submit : null,
              icon: Icon(widget.server == null ? Icons.add : Icons.save),
              label: Text(widget.server == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  void _createPool() {
    final name = _poolNameController.text.trim();
    final ranges = _poolRangesController.text.trim();
    
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a pool name'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    // Validate IP range format
    final rangeRegex = RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}-\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$');
    if (!rangeRegex.hasMatch(ranges)) {
      setState(() => _poolRangesError = 'Invalid format. Use: start_ip-end_ip');
      return;
    }
    
    setState(() => _isCreatingPool = true);
    context.read<DhcpBloc>().add(AddIpPool(name: name, ranges: ranges));
  }

  bool get _canSubmit =>
      _nameController.text.isNotEmpty && _selectedInterface != null;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final bloc = context.read<DhcpBloc>();
    if (widget.server == null) {
      bloc.add(AddDhcpServer(
        name: _nameController.text,
        interface: _selectedInterface!,
        addressPool: _selectedPool,
        leaseTime: _leaseTimeController.text,
        authoritative: _authoritative,
        networkAddress: _networkAddressController.text.isNotEmpty 
            ? _networkAddressController.text 
            : null,
        gateway: _gatewayController.text.isNotEmpty 
            ? _gatewayController.text 
            : null,
        dnsServer: _dnsController.text.isNotEmpty 
            ? _dnsController.text 
            : null,
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
