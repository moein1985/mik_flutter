import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/saved_snmp_device.dart';
import '../../data/models/cisco_device_info_model.dart';
import '../bloc/saved_snmp_device_bloc.dart';
import '../bloc/saved_snmp_device_event.dart';
import '../bloc/saved_snmp_device_state.dart';
import '../bloc/snmp_monitor_bloc.dart';
import '../bloc/snmp_monitor_event.dart';
import '../bloc/snmp_monitor_state.dart';

class SnmpDashboardPage extends StatefulWidget {
  const SnmpDashboardPage({super.key});

  @override
  State<SnmpDashboardPage> createState() => _SnmpDashboardPageState();
}

class _SnmpDashboardPageState extends State<SnmpDashboardPage> {
  final _ipController = TextEditingController();
  final _communityController = TextEditingController(text: 'public');
  final _portController = TextEditingController(text: '161');
  DeviceVendor _selectedVendor = DeviceVendor.general;

  @override
  void dispose() {
    _ipController.dispose();
    _communityController.dispose();
    _portController.dispose();
    super.dispose();
  }

  void _selectDevice(SavedSnmpDevice device) {
    setState(() {
      _ipController.text = device.host;
      _portController.text = device.port.toString();
      _communityController.text = device.community;
      _selectedVendor = device.proprietary;
    });
  }

  void _showSavedDevicesDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return BlocProvider(
          create: (_) =>
              di.sl<SavedSnmpDeviceBloc>()..add(const LoadSavedDevices()),
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            expand: false,
            builder: (_, scrollController) {
              return _SavedDevicesSheet(
                scrollController: scrollController,
                onDeviceSelected: (device) {
                  Navigator.pop(bottomSheetContext);
                  _selectDevice(device);
                },
                onSaveCurrentDevice: () {
                  Navigator.pop(bottomSheetContext);
                  _showSaveDeviceDialog();
                },
              );
            },
          ),
        );
      },
    );
  }

  void _showSaveDeviceDialog() {
    final nameController = TextEditingController(
      text: _ipController.text.isNotEmpty
          ? '${_ipController.text}:${_portController.text}'
          : '',
    );
    bool setAsDefault = false;
    DeviceVendor dialogVendor = _selectedVendor;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Save SNMP Device'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Device Name',
                        hintText: 'e.g., Switch-1, Cisco Router',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<DeviceVendor>(
                      value: dialogVendor,
                      decoration: const InputDecoration(
                        labelText: 'Vendor/Type',
                        border: OutlineInputBorder(),
                      ),
                      items: DeviceVendor.values.map((vendor) {
                        return DropdownMenuItem(
                          value: vendor,
                          child: Text(vendor.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            dialogVendor = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      value: setAsDefault,
                      onChanged: (value) {
                        setDialogState(() {
                          setAsDefault = value ?? false;
                        });
                      },
                      title: const Text('Set as default'),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        _ipController.text.isNotEmpty &&
                        _communityController.text.isNotEmpty) {
                      final bloc = di.sl<SavedSnmpDeviceBloc>();
                      bloc.add(SaveDevice(
                        name: nameController.text,
                        host: _ipController.text,
                        port: int.tryParse(_portController.text) ?? 161,
                        community: _communityController.text,
                        proprietary: dialogVendor,
                        isDefault: setAsDefault,
                      ));
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Device saved successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _fetchData() {
    final ip = _ipController.text.trim();
    final community = _communityController.text.trim();
    final port = int.tryParse(_portController.text) ?? 161;

    if (ip.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter device IP address')),
      );
      return;
    }

    context.read<SnmpMonitorBloc>().add(
          FetchDataRequested(
            ip: ip,
            community: community.isEmpty ? 'public' : community,
            port: port,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
        title: const Text('SNMP Monitor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: _showSavedDevicesDialog,
            tooltip: 'Saved Devices',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
          ),
        ],
      ),
      body: BlocConsumer<SnmpMonitorBloc, SnmpMonitorState>(
        listener: (context, state) {
          if (state is SnmpMonitorFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInputCard(theme),
                const SizedBox(height: 16),
                if (state is SnmpMonitorLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (state is SnmpMonitorSuccess) ...[
                  _buildDeviceInfoCard(theme, state),
                  const SizedBox(height: 16),
                  if (state.ciscoInfo != null) ...[
                    _buildCiscoInfoCard(theme, state.ciscoInfo!),
                    const SizedBox(height: 16),
                  ],
                  _buildInterfacesCard(theme, state),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputCard(ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Device Connection',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _showSaveDeviceDialog,
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: 'IP Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.router),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _communityController,
                    decoration: const InputDecoration(
                      labelText: 'Community',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.key),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _portController,
                    decoration: const InputDecoration(
                      labelText: 'Port',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<DeviceVendor>(
              value: _selectedVendor,
              decoration: const InputDecoration(
                labelText: 'Device Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: DeviceVendor.values.map((vendor) {
                return DropdownMenuItem(
                  value: vendor,
                  child: Text(vendor.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedVendor = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchData,
              icon: const Icon(Icons.search),
              label: const Text('Query Device'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfoCard(ThemeData theme, SnmpMonitorSuccess state) {
    final info = state.deviceInfo;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Device Information',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (info.sysName != null)
              _buildInfoRow('Name', info.sysName!),
            if (info.sysDescr != null)
              _buildInfoRow('Description', info.sysDescr!),
            if (info.sysLocation != null)
              _buildInfoRow('Location', info.sysLocation!),
            if (info.sysContact != null)
              _buildInfoRow('Contact', info.sysContact!),
            if (info.sysUpTime != null)
              _buildInfoRow('Uptime', info.sysUpTime!),
          ],
        ),
      ),
    );
  }

  Widget _buildInterfacesCard(ThemeData theme, SnmpMonitorSuccess state) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lan, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Interfaces (${state.interfaces.length})',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...state.interfaces.map((iface) {
              final hasPoe = iface.poeEnabled == true;
              final hasConsumption =
                  iface.poePowerConsumption != null && iface.poePowerConsumption! > 0;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: Colors.grey.shade50,
                child: ListTile(
                  leading: Icon(
                    iface.operStatusIcon,
                    color: iface.operStatusColor,
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          iface.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (hasPoe)
                        Tooltip(
                          message: hasConsumption
                              ? 'PoE Active: ${iface.poePowerConsumptionWatts?.toStringAsFixed(1)}W'
                              : 'PoE Enabled',
                          child: Icon(
                            hasConsumption ? Icons.flash_on : Icons.flash_off,
                            size: 18,
                            color: hasConsumption ? Colors.amber : Colors.grey,
                          ),
                        ),
                      if (iface.duplex != null && iface.duplex != 'unknown')
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: iface.duplex == 'full'
                                  ? Colors.green.shade100
                                  : Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              iface.duplex!.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: iface.duplex == 'full'
                                    ? Colors.green.shade800
                                    : Colors.orange.shade800,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${iface.displayOperStatus} | ${iface.displaySpeed ?? "N/A"}',
                      ),
                      if (hasPoe && hasConsumption)
                        Text(
                          'PoE: ${iface.poePowerConsumptionWatts?.toStringAsFixed(1)}W',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.amber.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('↓ ${iface.displayInOctets}'),
                      Text('↑ ${iface.displayOutOctets}'),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCiscoInfoCard(ThemeData theme, CiscoDeviceInfoModel cisco) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.developer_board, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Cisco Device Details',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            
            // Hardware Information
            if (cisco.modelName != null ||
                cisco.serialNumber != null ||
                cisco.iosVersion != null) ...[
              _buildSectionTitle('Hardware Information', Icons.memory),
              const SizedBox(height: 8),
              if (cisco.modelName != null)
                _buildInfoRow('Model', cisco.modelName!),
              if (cisco.serialNumber != null)
                _buildInfoRow('Serial Number', cisco.serialNumber!),
              if (cisco.iosVersion != null)
                _buildInfoRow('IOS Version', cisco.iosVersion!),
              if (cisco.hardwareVersion != null)
                _buildInfoRow('Hardware Rev', cisco.hardwareVersion!),
              const SizedBox(height: 16),
            ],

            // CPU Usage
            if (cisco.cpuUsage5sec != null ||
                cisco.cpuUsage1min != null ||
                cisco.cpuUsage5min != null) ...[
              _buildSectionTitle('CPU Usage', Icons.speed),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (cisco.cpuUsage5sec != null)
                    Expanded(
                      child: _buildMetricCard(
                        '5 sec',
                        '${cisco.cpuUsage5sec}%',
                        _getCpuColor(cisco.cpuUsage5sec!),
                      ),
                    ),
                  if (cisco.cpuUsage1min != null) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMetricCard(
                        '1 min',
                        '${cisco.cpuUsage1min}%',
                        _getCpuColor(cisco.cpuUsage1min!),
                      ),
                    ),
                  ],
                  if (cisco.cpuUsage5min != null) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMetricCard(
                        '5 min',
                        '${cisco.cpuUsage5min}%',
                        _getCpuColor(cisco.cpuUsage5min!),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Memory Usage
            if (cisco.memoryUsed != null || cisco.memoryFree != null) ...[
              _buildSectionTitle('Memory Usage', Icons.storage),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildMemoryInfo(cisco),
                  ),
                  if (cisco.memoryUtilization != null) ...[
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: cisco.memoryUtilization! / 100,
                            strokeWidth: 8,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getMemoryColor(cisco.memoryUtilization!),
                            ),
                          ),
                          Text(
                            '${cisco.memoryUtilization!.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: _getMemoryColor(cisco.memoryUtilization!),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Environmental Status
            if (cisco.environmental != null) ...[
              _buildEnvironmentalStatus(theme, cisco.environmental!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade700),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryInfo(CiscoDeviceInfoModel cisco) {
    final used = cisco.memoryUsed ?? 0;
    final free = cisco.memoryFree ?? 0;
    final total = cisco.memoryTotal ?? (used + free);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Used', '${_formatBytes(used)}'),
        _buildInfoRow('Free', '${_formatBytes(free)}'),
        _buildInfoRow('Total', '${_formatBytes(total)}'),
      ],
    );
  }

  Widget _buildEnvironmentalStatus(
      ThemeData theme, EnvironmentalStatus env) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Environmental Status', Icons.thermostat),
        const SizedBox(height: 8),
        
        // Temperature
        if (env.temperature != null) ...[
          _buildStatusCard(
            'Temperature',
            env.temperature!.value != null
                ? '${env.temperature!.value}°C'
                : 'N/A',
            _getStatusIcon(env.temperature!.state),
            _getStatusColor(env.temperature!.state),
          ),
          const SizedBox(height: 8),
        ],

        // Fans
        if (env.fans != null && env.fans!.isNotEmpty) ...[
          for (final fan in env.fans!)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildStatusCard(
                fan.description ?? 'Fan',
                fan.state?.toUpperCase() ?? 'UNKNOWN',
                _getStatusIcon(fan.state),
                _getStatusColor(fan.state),
              ),
            ),
        ],

        // Power Supplies
        if (env.powerSupplies != null && env.powerSupplies!.isNotEmpty) ...[
          for (final ps in env.powerSupplies!)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildStatusCard(
                ps.description ?? 'Power Supply',
                '${ps.state?.toUpperCase() ?? "UNKNOWN"} (${ps.source ?? "unknown"})',
                _getStatusIcon(ps.state),
                _getStatusColor(ps.state),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildStatusCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCpuColor(int usage) {
    if (usage < 60) return Colors.green;
    if (usage < 80) return Colors.orange;
    return Colors.red;
  }

  Color _getMemoryColor(double usage) {
    if (usage < 70) return Colors.green;
    if (usage < 85) return Colors.orange;
    return Colors.red;
  }

  IconData _getStatusIcon(String? state) {
    switch (state?.toLowerCase()) {
      case 'normal':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'critical':
      case 'shutdown':
        return Icons.error;
      case 'notpresent':
        return Icons.remove_circle_outline;
      case 'notfunctioning':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(String? state) {
    switch (state?.toLowerCase()) {
      case 'normal':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'critical':
      case 'shutdown':
      case 'notfunctioning':
        return Colors.red;
      case 'notpresent':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

// Saved Devices Sheet Widget
class _SavedDevicesSheet extends StatelessWidget {
  final ScrollController scrollController;
  final Function(SavedSnmpDevice) onDeviceSelected;
  final VoidCallback onSaveCurrentDevice;

  const _SavedDevicesSheet({
    required this.scrollController,
    required this.onDeviceSelected,
    required this.onSaveCurrentDevice,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Handle bar
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Saved Devices',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: onSaveCurrentDevice,
                icon: const Icon(Icons.add),
                label: const Text('Save Current'),
              ),
            ],
          ),
        ),
        const Divider(),
        // List
        Expanded(
          child: BlocConsumer<SavedSnmpDeviceBloc, SavedSnmpDeviceState>(
            listener: (context, state) {
              if (state is SavedSnmpDeviceError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is SavedSnmpDeviceOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is SavedSnmpDeviceLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              List<SavedSnmpDevice> devices = [];
              if (state is SavedSnmpDeviceLoaded) {
                devices = state.devices;
              } else if (state is SavedSnmpDeviceOperationSuccess) {
                devices = state.devices;
              }

              if (devices.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.devices, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No saved devices',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Enter device details and tap "Save Current"',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: scrollController,
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  return _SavedDeviceTile(
                    device: device,
                    onTap: () => onDeviceSelected(device),
                    onSetDefault: () {
                      context
                          .read<SavedSnmpDeviceBloc>()
                          .add(SetDefaultDevice(device.id!));
                    },
                    onDelete: () {
                      context
                          .read<SavedSnmpDeviceBloc>()
                          .add(DeleteDevice(device.id!));
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// Saved Device Tile Widget
class _SavedDeviceTile extends StatelessWidget {
  final SavedSnmpDevice device;
  final VoidCallback onTap;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  const _SavedDeviceTile({
    required this.device,
    required this.onTap,
    required this.onSetDefault,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: device.isDefault
              ? Colors.green
              : Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(
            Icons.devices,
            color: device.isDefault
                ? Colors.white
                : Theme.of(context).primaryColor,
          ),
        ),
        title: Row(
          children: [
            Expanded(child: Text(device.name)),
            if (device.isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Default',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${device.host}:${device.port}'),
            Row(
              children: [
                Icon(Icons.key, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  device.community,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 12),
                Icon(Icons.category, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  device.proprietary.displayName,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            if (!device.isDefault)
              const PopupMenuItem(
                value: 'default',
                child: Row(
                  children: [
                    Icon(Icons.star, size: 18),
                    SizedBox(width: 8),
                    Text('Set as Default'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'default') {
              onSetDefault();
            } else if (value == 'delete') {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Delete Device'),
                  content: Text('Are you sure you want to delete "${device.name}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        onDelete();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            }
          },
        ),
        onTap: onTap,
      ),
    );
  }
}
