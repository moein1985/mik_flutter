import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/dhcp_network.dart';
import '../bloc/dhcp_bloc.dart';
import '../bloc/dhcp_event.dart';
import '../bloc/dhcp_state.dart';

class DhcpNetworksTab extends StatefulWidget {
  const DhcpNetworksTab({super.key});

  @override
  State<DhcpNetworksTab> createState() => _DhcpNetworksTabState();
}

class _DhcpNetworksTabState extends State<DhcpNetworksTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DhcpNetwork> _filterNetworks(List<DhcpNetwork> networks) {
    if (_searchQuery.isEmpty) return networks;
    return networks.where((network) {
      final query = _searchQuery.toLowerCase();
      return network.address.toLowerCase().contains(query) ||
          (network.gateway?.toLowerCase().contains(query) ?? false) ||
          (network.dnsServer?.toLowerCase().contains(query) ?? false) ||
          (network.comment?.toLowerCase().contains(query) ?? false);
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
          DhcpLoaded(:final networks) => _buildNetworksList(context, networks ?? [], colorScheme),
          _ => _buildNetworksList(context, [], colorScheme),
        };
      },
    );
  }

  Widget _buildNetworksList(BuildContext context, List<DhcpNetwork> allNetworks, ColorScheme colorScheme) {
    final networks = _filterNetworks(allNetworks);
    final totalCount = allNetworks.length;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<DhcpBloc>().add(const LoadDhcpNetworks());
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
            _buildSummaryCard(totalCount, colorScheme),

            const SizedBox(height: 16),

            // Search Bar
            _buildSearchBar(colorScheme),

            const SizedBox(height: 16),

            // Networks List
            if (allNetworks.isEmpty)
              _buildEmptyState(context)
            else if (networks.isEmpty)
              _buildNoResultsState()
            else
              ...networks.map((network) => _buildNetworkCard(context, network, colorScheme)),

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
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.purple.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Networks define DHCP options like gateway, DNS, and domain for clients.',
              style: TextStyle(
                color: Colors.purple.shade800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int total, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.lan, color: colorScheme.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$total',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                Text(
                  'DHCP Networks',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search networks...',
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
              Icons.lan_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No DHCP Networks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a network to define DHCP options\nlike gateway and DNS for your clients.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showAddNetworkDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Network'),
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

  Widget _buildNetworkCard(BuildContext context, DhcpNetwork network, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _copyToClipboard(network.address, 'Network address'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Network icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lan, color: Colors.blue, size: 22),
                  ),
                  const SizedBox(width: 12),

                  // Network Address
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          network.address,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        if (network.comment != null)
                          Text(
                            network.comment!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // More options
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                    onSelected: (value) => _handleMenuAction(context, value, network),
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
                    if (network.gateway != null)
                      _buildDetailRow(
                        icon: Icons.router,
                        label: 'Gateway',
                        value: network.gateway!,
                      ),
                    if (network.gateway != null && network.dnsServer != null)
                      const SizedBox(height: 8),
                    if (network.dnsServer != null)
                      _buildDetailRow(
                        icon: Icons.dns,
                        label: 'DNS',
                        value: network.dnsServer!,
                      ),
                    if ((network.gateway != null || network.dnsServer != null) && network.domain != null)
                      const SizedBox(height: 8),
                    if (network.domain != null)
                      _buildDetailRow(
                        icon: Icons.domain,
                        label: 'Domain',
                        value: network.domain!,
                      ),
                    if ((network.gateway != null || network.dnsServer != null || network.domain != null) && network.netmask != null)
                      const SizedBox(height: 8),
                    if (network.netmask != null)
                      _buildDetailRow(
                        icon: Icons.masks,
                        label: 'Netmask',
                        value: network.netmask!,
                      ),
                    if (network.gateway == null && network.dnsServer == null && network.domain == null && network.netmask == null)
                      Text(
                        'No additional options configured',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
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
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  void _handleMenuAction(BuildContext context, String action, DhcpNetwork network) {
    switch (action) {
      case 'edit':
        _showEditNetworkDialog(context, network);
        break;
      case 'delete':
        _showDeleteConfirmation(context, network);
        break;
    }
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
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 48),
        title: const Text('Delete Network'),
        content: Text('Are you sure you want to delete "${network.address}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<DhcpBloc>().add(RemoveDhcpNetwork(network.id));
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

class _NetworkDialog extends StatefulWidget {
  final DhcpNetwork? network;

  const _NetworkDialog({this.network});

  @override
  State<_NetworkDialog> createState() => _NetworkDialogState();
}

class _NetworkDialogState extends State<_NetworkDialog> {
  final _formKey = GlobalKey<FormState>();
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
    // Listen for text changes to update button state
    _addressController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _addressController.removeListener(_onTextChanged);
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
            Icon(Icons.lan, color: colorScheme.primary),
            const SizedBox(width: 12),
            Text(widget.network == null ? 'Add Network' : 'Edit Network'),
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
                    labelText: 'Network Address *',
                    hintText: 'e.g., 192.168.88.0/24',
                    prefixIcon: const Icon(Icons.lan),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter network address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _gatewayController,
                  decoration: InputDecoration(
                    labelText: 'Gateway',
                    hintText: 'e.g., 192.168.88.1',
                    prefixIcon: const Icon(Icons.router),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dnsController,
                  decoration: InputDecoration(
                    labelText: 'DNS Server',
                    hintText: 'e.g., 8.8.8.8',
                    prefixIcon: const Icon(Icons.dns),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _domainController,
                  decoration: InputDecoration(
                    labelText: 'Domain',
                    hintText: 'e.g., local',
                    prefixIcon: const Icon(Icons.domain),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    labelText: 'Comment',
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
            icon: Icon(widget.network == null ? Icons.add : Icons.save),
            label: Text(widget.network == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  bool get _canSubmit => _addressController.text.isNotEmpty;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

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
