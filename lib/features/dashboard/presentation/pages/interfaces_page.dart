import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../auth/data/datasources/auth_remote_data_source.dart';
import '../../domain/entities/router_interface.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import 'interface_monitoring_page.dart';

class InterfacesPage extends StatefulWidget {
  const InterfacesPage({super.key});

  @override
  State<InterfacesPage> createState() => _InterfacesPageState();
}

class _InterfacesPageState extends State<InterfacesPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const LoadInterfaces());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openMonitoring(BuildContext context, String interfaceName) {
    final authDataSource = GetIt.instance<AuthRemoteDataSource>();
    final client = authDataSource.client;

    if (client == null || !client.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not connected to router'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InterfaceMonitoringPage(
          interfaceName: interfaceName,
          client: client,
        ),
      ),
    );
  }

  List<RouterInterface> _filterInterfaces(List<RouterInterface> interfaces) {
    if (_searchQuery.isEmpty) return interfaces;
    return interfaces.where((iface) {
      final query = _searchQuery.toLowerCase();
      return iface.name.toLowerCase().contains(query) ||
          iface.type.toLowerCase().contains(query) ||
          (iface.macAddress?.toLowerCase().contains(query) ?? false) ||
          (iface.comment?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  IconData _getInterfaceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'ether':
        return Icons.settings_ethernet;
      case 'wlan':
        return Icons.wifi;
      case 'bridge':
        return Icons.lan;
      case 'vlan':
        return Icons.layers;
      case 'pppoe-out':
      case 'pppoe-in':
        return Icons.vpn_key;
      case 'l2tp-out':
      case 'l2tp-in':
      case 'pptp-out':
      case 'pptp-in':
        return Icons.vpn_lock;
      case 'ovpn-out':
      case 'ovpn-in':
        return Icons.security;
      case 'lte':
        return Icons.signal_cellular_alt;
      case 'cap':
        return Icons.cell_tower;
      default:
        return Icons.cable;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interfaces'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DashboardBloc>().add(const LoadInterfaces());
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is DashboardLoaded && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.read<DashboardBloc>().add(const ClearError());
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

          if (state is DashboardLoaded && state.interfaces != null) {
            final allInterfaces = state.interfaces!;
            final interfaces = _filterInterfaces(allInterfaces);

            // Calculate statistics
            final activeCount = allInterfaces.where((i) => i.running && !i.disabled).length;
            final disabledCount = allInterfaces.where((i) => i.disabled).length;
            final totalCount = allInterfaces.length;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(const LoadInterfaces());
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
                    
                    // Interfaces List
                    if (interfaces.isEmpty)
                      _buildEmptyState()
                    else
                      ...interfaces.map((iface) => _buildInterfaceCard(iface, colorScheme)),
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
                Text(state is DashboardError ? state.message : 'Unable to load interfaces'),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    context.read<DashboardBloc>().add(const LoadInterfaces());
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
              'Tap "Monitor" to see live traffic statistics for any interface',
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

  Widget _buildSummaryCard(int active, int disabled, int total, ColorScheme colorScheme) {
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
                  icon: Icons.check_circle,
                  value: '$active',
                  label: 'Active',
                  color: Colors.green,
                ),
                _buildSummaryItem(
                  icon: Icons.cancel,
                  value: '$disabled',
                  label: 'Disabled',
                  color: Colors.red,
                ),
                _buildSummaryItem(
                  icon: Icons.router,
                  value: '$total',
                  label: 'Total',
                  color: Colors.blue,
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search interfaces...',
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
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty 
                  ? 'No interfaces found'
                  : 'No interfaces match "$_searchQuery"',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterfaceCard(RouterInterface interface, ColorScheme colorScheme) {
    final isActive = interface.running && !interface.disabled;
    final statusColor = interface.disabled 
        ? Colors.red 
        : (interface.running ? Colors.green : Colors.orange);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isActive ? Colors.green.withValues(alpha: 0.3) : Colors.transparent,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openMonitoring(context, interface.name),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Status indicator and icon
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getInterfaceIcon(interface.type),
                          color: statusColor,
                          size: 24,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // Name and type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          interface.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          interface.type,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Switch
                  Switch(
                    value: !interface.disabled,
                    onChanged: (value) {
                      context.read<DashboardBloc>().add(
                        ToggleInterface(
                          id: interface.id,
                          enable: value,
                        ),
                      );
                    },
                    activeTrackColor: Colors.green.withValues(alpha: 0.5),
                    activeThumbColor: Colors.green,
                  ),
                ],
              ),

              // MAC Address and Comment
              if (interface.macAddress != null || interface.comment != null) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                if (interface.macAddress != null)
                  Row(
                    children: [
                      Icon(Icons.memory, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 6),
                      Text(
                        interface.macAddress!,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                if (interface.comment != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.comment, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          interface.comment!,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],

              const SizedBox(height: 12),

              // Status chip and Monitor button
              Row(
                children: [
                  // Status chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          interface.disabled 
                              ? 'Disabled' 
                              : (interface.running ? 'Running' : 'Stopped'),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Monitor button
                  FilledButton.tonalIcon(
                    onPressed: () => _openMonitoring(context, interface.name),
                    icon: const Icon(Icons.show_chart, size: 18),
                    label: const Text('Monitor'),
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
