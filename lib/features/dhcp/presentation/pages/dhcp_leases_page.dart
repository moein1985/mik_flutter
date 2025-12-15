import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/dhcp_lease.dart';
import '../bloc/dhcp_bloc.dart';
import '../bloc/dhcp_event.dart';
import '../bloc/dhcp_state.dart';

class DhcpLeasesTab extends StatefulWidget {
  const DhcpLeasesTab({super.key});

  @override
  State<DhcpLeasesTab> createState() => _DhcpLeasesTabState();
}

class _DhcpLeasesTabState extends State<DhcpLeasesTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DhcpLease> _filterLeases(List<DhcpLease> leases) {
    if (_searchQuery.isEmpty) return leases;
    return leases.where((lease) {
      final query = _searchQuery.toLowerCase();
      return lease.address.toLowerCase().contains(query) ||
          lease.macAddress.toLowerCase().contains(query) ||
          (lease.hostName?.toLowerCase().contains(query) ?? false) ||
          (lease.comment?.toLowerCase().contains(query) ?? false);
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
          DhcpLoaded(:final leases) => _buildLeasesList(context, leases ?? [], colorScheme),
          _ => _buildLeasesList(context, [], colorScheme),
        };
      },
    );
  }

  Widget _buildLeasesList(BuildContext context, List<DhcpLease> allLeases, ColorScheme colorScheme) {
    final leases = _filterLeases(allLeases);

    // Calculate statistics
    final boundCount = allLeases.where((l) => l.status.toLowerCase() == 'bound' && !l.disabled).length;
    final staticCount = allLeases.where((l) => !l.dynamic).length;
    final dynamicCount = allLeases.where((l) => l.dynamic).length;
    final totalCount = allLeases.length;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<DhcpBloc>().add(const LoadDhcpLeases());
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
            _buildSummaryCard(boundCount, staticCount, dynamicCount, totalCount, colorScheme),

            const SizedBox(height: 16),

            // Search Bar
            _buildSearchBar(colorScheme),

            const SizedBox(height: 16),

            // Leases List
            if (allLeases.isEmpty)
              _buildEmptyState(context)
            else if (leases.isEmpty)
              _buildNoResultsState()
            else
              ...leases.map((lease) => _buildLeaseCard(context, lease, colorScheme)),

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
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.green.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Leases show devices that have received IP addresses from DHCP. Make a lease static to reserve an IP.',
              style: TextStyle(
                color: Colors.green.shade800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int boundCount, int staticCount, int dynamicCount, int total, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assignment, color: colorScheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'DHCP Leases Overview',
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
                  value: '$boundCount',
                  label: 'Active',
                  color: Colors.green,
                ),
                _buildSummaryItem(
                  icon: Icons.push_pin,
                  value: '$staticCount',
                  label: 'Static',
                  color: Colors.purple,
                ),
                _buildSummaryItem(
                  icon: Icons.sync,
                  value: '$dynamicCount',
                  label: 'Dynamic',
                  color: Colors.blue,
                ),
                _buildSummaryItem(
                  icon: Icons.assignment,
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
          child: Icon(icon, color: color, size: 20),
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
            fontSize: 11,
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
        hintText: 'Search by IP, MAC, hostname...',
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
              Icons.assignment_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No DHCP Leases',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Leases will appear when devices connect\nto your network and request an IP address.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showAddLeaseDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Static Lease'),
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

  Widget _buildLeaseCard(BuildContext context, DhcpLease lease, ColorScheme colorScheme) {
    // Determine status
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (lease.disabled) {
      statusColor = Colors.grey;
      statusText = 'Disabled';
      statusIcon = Icons.block;
    } else if (lease.status.toLowerCase() == 'bound') {
      statusColor = Colors.green;
      statusText = 'Bound';
      statusIcon = Icons.check_circle;
    } else if (lease.status.toLowerCase() == 'waiting') {
      statusColor = Colors.orange;
      statusText = 'Waiting';
      statusIcon = Icons.hourglass_empty;
    } else {
      statusColor = Colors.grey;
      statusText = lease.status;
      statusIcon = Icons.help_outline;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _copyToClipboard(lease.address, 'IP address'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
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

                  // IP Address
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lease.address,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        if (lease.hostName != null && lease.hostName!.isNotEmpty)
                          Text(
                            lease.hostName!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Type badge (Static/Dynamic)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (lease.dynamic ? Colors.blue : Colors.purple).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          lease.dynamic ? Icons.sync : Icons.push_pin,
                          size: 14,
                          color: lease.dynamic ? Colors.blue : Colors.purple,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          lease.dynamic ? 'Dynamic' : 'Static',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: lease.dynamic ? Colors.blue : Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // More options
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                    onSelected: (value) => _handleMenuAction(context, value, lease),
                    itemBuilder: (context) => [
                      if (lease.dynamic)
                        const PopupMenuItem(
                          value: 'make_static',
                          child: ListTile(
                            leading: Icon(Icons.push_pin, color: Colors.purple),
                            title: Text('Make Static'),
                            contentPadding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      PopupMenuItem(
                        value: lease.disabled ? 'enable' : 'disable',
                        child: ListTile(
                          leading: Icon(
                            lease.disabled ? Icons.play_arrow : Icons.pause,
                            color: lease.disabled ? Colors.green : Colors.orange,
                          ),
                          title: Text(lease.disabled ? 'Enable' : 'Disable'),
                          contentPadding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'copy_mac',
                        child: ListTile(
                          leading: Icon(Icons.copy),
                          title: Text('Copy MAC'),
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
                      label: 'MAC Address',
                      value: lease.macAddress,
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      icon: statusIcon,
                      label: 'Status',
                      value: statusText,
                      valueColor: statusColor,
                    ),
                    if (lease.server != null) ...[
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        icon: Icons.dns,
                        label: 'Server',
                        value: lease.server!,
                      ),
                    ],
                    if (lease.expiresAfter != null) ...[
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        icon: Icons.timer,
                        label: 'Expires',
                        value: lease.expiresAfter!,
                      ),
                    ],
                    if (lease.lastSeen != null) ...[
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        icon: Icons.access_time,
                        label: 'Last Seen',
                        value: lease.lastSeen!,
                      ),
                    ],
                    if (lease.comment != null && lease.comment!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        icon: Icons.comment,
                        label: 'Comment',
                        value: lease.comment!,
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
              fontFamily: label == 'MAC Address' ? 'monospace' : null,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ),
      ],
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
      case 'copy_mac':
        _copyToClipboard(lease.macAddress, 'MAC address');
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
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 48),
        title: const Text('Delete Lease'),
        content: Text(
          'Are you sure you want to delete the lease for "${lease.address}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<DhcpBloc>().add(RemoveDhcpLease(lease.id));
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

class _LeaseDialog extends StatefulWidget {
  const _LeaseDialog();

  @override
  State<_LeaseDialog> createState() => _LeaseDialogState();
}

class _LeaseDialogState extends State<_LeaseDialog> {
  final _formKey = GlobalKey<FormState>();
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
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<DhcpBloc, DhcpState>(
      listener: (context, state) {
        if (state is DhcpOperationSuccess) {
          Navigator.pop(context);
        }
      },
      child: AlertDialog(
        title: Row(
          children: [
            Icon(Icons.assignment, color: colorScheme.primary),
            const SizedBox(width: 12),
            const Text('Add Static Lease'),
          ],
        ),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'IP Address *',
                    hintText: 'e.g., 192.168.88.100',
                    prefixIcon: const Icon(Icons.computer),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter IP address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _macController,
                  decoration: InputDecoration(
                    labelText: 'MAC Address *',
                    hintText: 'e.g., AA:BB:CC:DD:EE:FF',
                    prefixIcon: const Icon(Icons.router),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter MAC address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    labelText: 'Comment',
                    hintText: 'e.g., John\'s Laptop',
                    prefixIcon: const Icon(Icons.comment),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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
            onPressed: _canSubmit ? _submit : null,
            icon: const Icon(Icons.add),
            label: const Text('Add'),
          ),
        ],
      ),
    );
  }

  bool get _canSubmit =>
      _addressController.text.isNotEmpty && _macController.text.isNotEmpty;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<DhcpBloc>().add(AddDhcpLease(
          address: _addressController.text,
          macAddress: _macController.text,
          comment: _commentController.text.isNotEmpty ? _commentController.text : null,
        ));
  }
}
