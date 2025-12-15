import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../../../../injection_container.dart';
import '../bloc/dhcp_bloc.dart';
import '../bloc/dhcp_event.dart';
import '../bloc/dhcp_state.dart';
import 'dhcp_servers_page.dart';
import 'dhcp_leases_page.dart';

final _log = AppLogger.tag('DhcpPage');

class DhcpPage extends StatelessWidget {
  const DhcpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DhcpBloc(repository: sl())..add(const LoadDhcpServers()),
      child: const DhcpPageContent(),
    );
  }
}

class DhcpPageContent extends StatefulWidget {
  const DhcpPageContent({super.key});

  @override
  State<DhcpPageContent> createState() => _DhcpPageContentState();
}

class _DhcpPageContentState extends State<DhcpPageContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _loadTabData(_tabController.index);
    }
    // Update FAB label when tab changes
    setState(() {});
  }

  void _loadTabData(int index) {
    final bloc = context.read<DhcpBloc>();
    switch (index) {
      case 0:
        bloc.add(const LoadDhcpServers());
        break;
      case 1:
        bloc.add(const LoadDhcpLeases());
        break;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DhcpBloc, DhcpState>(
      listener: (context, state) {
        if (state is DhcpOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is DhcpError) {
          _log.e('DHCP error: ${state.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('DHCP Server'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Servers', icon: Icon(Icons.dns)),
              Tab(text: 'Leases', icon: Icon(Icons.assignment)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () => _loadTabData(_tabController.index),
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            DhcpServersTab(),
            DhcpLeasesTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddDialog(context),
          icon: const Icon(Icons.add),
          label: Text(_getFabLabel()),
        ),
      ),
    );
  }

  String _getFabLabel() {
    switch (_tabController.index) {
      case 0:
        return 'Add Server';
      case 1:
        return 'Add Lease';
      default:
        return 'Add';
    }
  }

  void _showAddDialog(BuildContext context) {
    final bloc = context.read<DhcpBloc>();
    switch (_tabController.index) {
      case 0:
        bloc.add(const LoadDhcpSetupData());
        showDialog(
          context: context,
          builder: (dialogContext) => BlocProvider.value(
            value: bloc,
            child: const _AddServerDialog(),
          ),
        );
        break;
      case 1:
        showDialog(
          context: context,
          builder: (dialogContext) => BlocProvider.value(
            value: bloc,
            child: const _AddLeaseDialog(),
          ),
        );
        break;
    }
  }
}

// Simple Add Server Dialog
class _AddServerDialog extends StatefulWidget {
  const _AddServerDialog();

  @override
  State<_AddServerDialog> createState() => _AddServerDialogState();
}

class _AddServerDialogState extends State<_AddServerDialog> {
  final _nameController = TextEditingController();
  String? _selectedInterface;
  String? _selectedPool;
  final _leaseTimeController = TextEditingController(text: '10m');
  final bool _authoritative = true;

  // For creating new pool
  bool _showCreatePool = false;
  final _poolNameController = TextEditingController();
  final _poolRangesController = TextEditingController();
  bool _isCreatingPool = false;
  String? _poolRangesError;
  String? _createPoolError; // Error message for pool creation

  // Network fields (auto-create network with server)
  final _networkAddressController = TextEditingController();
  final _gatewayController = TextEditingController();
  final _dnsController = TextEditingController();

  List<Map<String, String>> _interfaces = [];
  List<Map<String, String>> _pools = [];
  bool _dataLoaded = false;

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
        if (state is IpPoolCreated) {
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
          // Show error inline in dialog instead of snackbar
          setState(() {
            _isCreatingPool = false;
            _createPoolError = state.message;
          });
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
          // Update local state for future use
          if (!_dataLoaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _interfaces = state.interfaces;
                  _pools = state.ipPools;
                  _dataLoaded = true;
                });
              }
            });
          }
        } else if (state is IpPoolCreated) {
          interfaces = state.setupData.interfaces;
          pools = state.setupData.ipPools;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _interfaces = state.setupData.interfaces;
                _pools = state.setupData.ipPools;
                _selectedPool = state.poolName;
                _showCreatePool = false;
                _isCreatingPool = false;
                _createPoolError = null; // Clear error on success
                _poolNameController.clear();
                _poolRangesController.clear();
              });
            }
          });
        }

        if (isLoading && interfaces.isEmpty) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.dns, color: colorScheme.primary),
                const SizedBox(width: 12),
                const Text('Add DHCP Server'),
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
              const Text('Add DHCP Server'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name *',
                    hintText: 'e.g., dhcp1',
                    prefixIcon: const Icon(Icons.label),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedInterface,
                  decoration: InputDecoration(
                    labelText: 'Interface *',
                    prefixIcon: const Icon(Icons.router),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: interfaces.map((iface) {
                    final name = iface['name'] ?? '';
                    return DropdownMenuItem(value: name, child: Text(name));
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedInterface = value),
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
                            labelText: 'IP Ranges *',
                            hintText: '192.168.88.10-192.168.88.254',
                            prefixIcon: const Icon(Icons.data_array),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: colorScheme.surface,
                            helperText: 'Full IP format: StartIP-EndIP',
                            helperMaxLines: 2,
                            errorText: _poolRangesError,
                          ),
                          onChanged: (_) => _validatePoolRanges(),
                        ),
                        const SizedBox(height: 12),
                        
                        // Show error message if pool creation failed
                        if (_createPoolError != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: colorScheme.error.withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, 
                                    size: 20, 
                                    color: colorScheme.error),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _createPoolError!,
                                    style: TextStyle(
                                      color: colorScheme.onErrorContainer,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () => setState(() => _createPoolError = null),
                                  color: colorScheme.error,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _canCreatePool && !_isCreatingPool ? _createPool : null,
                            icon: _isCreatingPool 
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.check),
                            label: Text(_isCreatingPool ? 'Creating...' : 'Create Pool'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 16),
                TextField(
                  controller: _leaseTimeController,
                  decoration: InputDecoration(
                    labelText: 'Lease Time',
                    hintText: 'e.g., 10m, 1h, 1d',
                    prefixIcon: const Icon(Icons.timer),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Network Settings Section
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
                      TextField(
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
                      TextField(
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
                      TextField(
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
        );
      },
    );
  }

  bool get _canSubmit => _nameController.text.isNotEmpty && _selectedInterface != null;
  
  bool get _canCreatePool => 
      _poolNameController.text.isNotEmpty && 
      _poolRangesController.text.isNotEmpty &&
      _poolRangesError == null;

  // Validate IP range format: must be full IP addresses like 192.168.1.10-192.168.1.254
  void _validatePoolRanges() {
    final ranges = _poolRangesController.text.trim();
    if (ranges.isEmpty) {
      setState(() => _poolRangesError = null);
      return;
    }

    // Simple regex for IP-IP format
    final ipPattern = r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}';
    final rangeRegex = RegExp('^$ipPattern-$ipPattern\$');
    
    if (!rangeRegex.hasMatch(ranges)) {
      setState(() => _poolRangesError = 'Use format: 192.168.x.x-192.168.x.x');
    } else {
      setState(() => _poolRangesError = null);
    }
  }

  void _createPool() {
    setState(() {
      _isCreatingPool = true;
      _createPoolError = null; // Clear previous error
    });
    context.read<DhcpBloc>().add(AddIpPool(
      name: _poolNameController.text,
      ranges: _poolRangesController.text,
    ));
  }

  void _submit() {
    context.read<DhcpBloc>().add(AddDhcpServer(
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
  }
}

// Simple Add Lease Dialog
class _AddLeaseDialog extends StatefulWidget {
  const _AddLeaseDialog();

  @override
  State<_AddLeaseDialog> createState() => _AddLeaseDialogState();
}

class _AddLeaseDialogState extends State<_AddLeaseDialog> {
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
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'IP Address *',
                  hintText: 'e.g., 192.168.88.100',
                  prefixIcon: const Icon(Icons.computer),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _macController,
                decoration: InputDecoration(
                  labelText: 'MAC Address *',
                  hintText: 'e.g., AA:BB:CC:DD:EE:FF',
                  prefixIcon: const Icon(Icons.router),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  labelText: 'Comment',
                  hintText: 'e.g., John\'s Laptop',
                  prefixIcon: const Icon(Icons.comment),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
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

  bool get _canSubmit => _addressController.text.isNotEmpty && _macController.text.isNotEmpty;

  void _submit() {
    context.read<DhcpBloc>().add(AddDhcpLease(
          address: _addressController.text,
          macAddress: _macController.text,
          comment: _commentController.text.isNotEmpty ? _commentController.text : null,
        ));
  }
}
