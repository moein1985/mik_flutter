import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../bloc/hotspot_bloc.dart';
import '../bloc/hotspot_event.dart';
import '../bloc/hotspot_state.dart';

final _log = AppLogger.tag('HotspotSetupDialog');

class HotspotSetupDialog extends StatefulWidget {
  const HotspotSetupDialog({super.key});

  @override
  State<HotspotSetupDialog> createState() => _HotspotSetupDialogState();
}

class _HotspotSetupDialogState extends State<HotspotSetupDialog> {
  String? _selectedInterface;
  String? _selectedPool;
  final _dnsNameController = TextEditingController();
  final _newPoolNameController = TextEditingController();
  final _newPoolRangesController = TextEditingController();
  bool _isCreatingPool = false;
  
  // Cache the loaded data locally so it persists across state changes
  List<Map<String, String>> _interfaces = [];
  List<Map<String, String>> _pools = [];
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    _log.i('Loading setup data...');
    context.read<HotspotBloc>().add(const LoadSetupData());
  }

  @override
  void dispose() {
    _dnsNameController.dispose();
    _newPoolNameController.dispose();
    _newPoolRangesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HotspotBloc, HotspotState>(
      listener: (context, state) {
        if (state is HotspotSetupDataLoaded) {
          // Cache the data locally
          setState(() {
            _interfaces = state.interfaces;
            _pools = state.ipPools;
            _dataLoaded = true;
          });
        } else if (state is HotspotOperationSuccess) {
          if (state.message == 'HotSpot setup completed') {
            Navigator.of(context).pop(true);
          } else if (state.message == 'IP Pool added successfully') {
            // Reload setup data to get the new pool
            context.read<HotspotBloc>().add(const LoadSetupData());
            setState(() {
              _isCreatingPool = false;
              _newPoolNameController.clear();
              _newPoolRangesController.clear();
            });
          }
        } else if (state is HotspotError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        // Show loading only if we don't have cached data yet
        if (state is HotspotLoading && !_dataLoaded) {
          return AlertDialog(
            title: const Text('Setup HotSpot'),
            content: const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          );
        }

        // Use cached data - this persists even when state changes to Loading/Success
        final interfaces = _interfaces;
        final pools = _pools;

        return AlertDialog(
          title: const Text('Setup HotSpot'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This will setup a basic HotSpot on your router. '
                  'You can configure advanced options later.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),
                
                // Interface Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedInterface,
                  decoration: const InputDecoration(
                    labelText: 'Interface *',
                    border: OutlineInputBorder(),
                    helperText: 'Select the interface for HotSpot',
                  ),
                  isExpanded: true,
                  items: interfaces.map((iface) {
                    final name = iface['name'] ?? '';
                    final type = iface['type'] ?? '';
                    final disabled = iface['disabled'] == 'true';
                    return DropdownMenuItem<String>(
                      value: name,
                      child: Row(
                        children: [
                          Icon(
                            _getInterfaceIcon(type),
                            size: 20,
                            color: disabled ? Colors.grey : Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              name,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: disabled ? Colors.grey : null,
                              ),
                            ),
                          ),
                          if (disabled)
                            const Text(
                              ' (disabled)',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedInterface = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Address Pool Section
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedPool,
                        decoration: const InputDecoration(
                          labelText: 'Address Pool',
                          border: OutlineInputBorder(),
                          helperText: 'Optional: Select or create a pool',
                        ),
                        isExpanded: true,
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Auto (create new)'),
                          ),
                          ...pools.map((pool) {
                            final name = pool['name'] ?? '';
                            final ranges = pool['ranges'] ?? '';
                            return DropdownMenuItem<String>(
                              value: name,
                              child: Text(
                                '$name ($ranges)',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedPool = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(_isCreatingPool ? Icons.close : Icons.add),
                      tooltip: _isCreatingPool ? 'Cancel' : 'Create new pool',
                      onPressed: () {
                        setState(() {
                          _isCreatingPool = !_isCreatingPool;
                        });
                      },
                    ),
                  ],
                ),

                // Create New Pool Section
                if (_isCreatingPool) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Create New IP Pool',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _newPoolNameController,
                          decoration: const InputDecoration(
                            labelText: 'Pool Name',
                            hintText: 'e.g., hs-pool-1',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _newPoolRangesController,
                          decoration: const InputDecoration(
                            labelText: 'IP Ranges',
                            hintText: 'e.g., 192.168.88.10-192.168.88.254',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _newPoolNameController.text.isNotEmpty &&
                                    _newPoolRangesController.text.isNotEmpty
                                ? () {
                                    context.read<HotspotBloc>().add(
                                          AddIpPool(
                                            name: _newPoolNameController.text,
                                            ranges: _newPoolRangesController.text,
                                          ),
                                        );
                                  }
                                : null,
                            child: const Text('Create Pool'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // DNS Name
                TextField(
                  controller: _dnsNameController,
                  decoration: const InputDecoration(
                    labelText: 'DNS Name',
                    hintText: 'e.g., hotspot.local',
                    border: OutlineInputBorder(),
                    helperText: 'Optional: Local DNS name for login page',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _selectedInterface != null
                  ? () {
                      _log.i('Setting up HotSpot with interface: $_selectedInterface');
                      context.read<HotspotBloc>().add(
                            SetupHotspot(
                              interface: _selectedInterface!,
                              addressPool: _selectedPool,
                              dnsName: _dnsNameController.text.isEmpty
                                  ? null
                                  : _dnsNameController.text,
                            ),
                          );
                    }
                  : null,
              child: const Text('Setup'),
            ),
          ],
        );
      },
    );
  }

  IconData _getInterfaceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'ether':
        return Icons.settings_ethernet;
      case 'wlan':
        return Icons.wifi;
      case 'bridge':
        return Icons.device_hub;
      case 'vlan':
        return Icons.layers;
      case 'pppoe-out':
      case 'pppoe-in':
        return Icons.vpn_key;
      case 'gre-tunnel':
      case 'ipip-tunnel':
      case 'eoip-tunnel':
        return Icons.sensor_door;
      case 'ovpn-out':
      case 'ovpn-in':
        return Icons.security;
      default:
        return Icons.settings_input_component;
    }
  }
}
