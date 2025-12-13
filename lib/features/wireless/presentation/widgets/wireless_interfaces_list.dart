import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/wireless_bloc.dart';
import '../bloc/wireless_event.dart';
import '../bloc/wireless_state.dart';

class WirelessInterfacesList extends StatefulWidget {
  const WirelessInterfacesList({super.key});

  @override
  State<WirelessInterfacesList> createState() => _WirelessInterfacesListState();
}

class _WirelessInterfacesListState extends State<WirelessInterfacesList> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Load data only once when widget is first created
    // Note: Only load interfaces here, security profiles will be loaded
    // when needed to avoid race conditions with concurrent API calls
    Future.microtask(() {
      if (mounted) {
        context.read<WirelessBloc>().add(const LoadWirelessInterfaces());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return BlocBuilder<WirelessBloc, WirelessState>(
      buildWhen: (previous, current) {
        // Only rebuild on interface-related state changes
        return previous.interfacesLoading != current.interfacesLoading ||
               previous.interfaces != current.interfaces ||
               previous.interfacesError != current.interfacesError;
      },
      builder: (context, state) {
        if (state.interfacesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.interfacesError != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.interfacesError!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<WirelessBloc>().add(const LoadWirelessInterfaces());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final interfaces = state.interfaces;
        if (interfaces.isEmpty) {
          return Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text('No wireless interfaces found'),
                  ],
                ),
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton(
                  onPressed: () => _showAddVirtualWlanSheet(context, interfaces),
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          );
        }

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                context.read<WirelessBloc>().add(const LoadWirelessInterfaces());
              },
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
                itemCount: interfaces.length,
                itemBuilder: (context, index) {
                  final interface = interfaces[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row with icon, SSID, and actions
                        Row(
                          children: [
                            // Large WiFi icon with signal strength indicator
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: interface.disabled ? Colors.grey.shade200 : Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Icon(
                                Icons.wifi,
                                color: interface.disabled ? Colors.grey : Colors.blue,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // SSID prominently displayed
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    interface.ssid ?? 'No SSID',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    interface.name ?? 'Unknown Interface',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Client count badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.people, size: 16, color: Colors.green.shade700),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${interface.clients}',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Band/Channel info with help icon
                        Row(
                          children: [
                            Icon(Icons.settings_input_antenna, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              '${interface.band ?? 'Unknown'} - ${interface.frequency ?? 'N/A'} MHz',
                              style: const TextStyle(fontSize: 14),
                            ),
                            IconButton(
                              icon: Icon(Icons.help_outline, size: 16, color: Colors.grey.shade600),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => _showFrequencyHelp(context),
                              tooltip: 'What is frequency band?',
                            ),
                            const Spacer(),
                            // Status indicator
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: interface.disabled ? Colors.red.shade100 : Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                interface.disabled ? 'Disabled' : 'Enabled',
                                style: TextStyle(
                                  color: interface.disabled ? Colors.red.shade700 : Colors.green.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Bottom row with toggle and settings
                        Row(
                          children: [
                            // Enable/Disable toggle switch
                            Text(
                              interface.disabled ? 'Disabled' : 'Enabled',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 8),
                            Switch(
                              value: !interface.disabled,
                              onChanged: (value) {
                                if (value) {
                                  context.read<WirelessBloc>().add(EnableWirelessInterface(interface.id));
                                } else {
                                  context.read<WirelessBloc>().add(DisableWirelessInterface(interface.id));
                                }
                              },
                            ),
                            const Spacer(),
                            // Settings/Edit icon button
                            IconButton(
                              icon: const Icon(Icons.settings),
                              onPressed: () {
                                _showQuickSettingsSheet(context, interface);
                              },
                              tooltip: 'Quick Settings',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: () => _showAddVirtualWlanSheet(context, interfaces),
              child: const Icon(Icons.add),
            ),
          ),
        ],
      );
      },
    );
  }

  void _showAddVirtualWlanSheet(BuildContext context, List<dynamic> interfaces) {
    final wirelessBloc = context.read<WirelessBloc>();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => BlocProvider.value(
        value: wirelessBloc,
        child: _AddVirtualWlanSheet(masterInterfaces: interfaces),
      ),
    );
  }

  void _showFrequencyHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.settings_input_antenna, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('Frequency Bands'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '2.4 GHz Band',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 4),
              Text('• Better range and wall penetration\n'
                   '• More interference from other devices\n'
                   '• Lower maximum speed\n'
                   '• Channels: 1-13 (2412-2472 MHz)'),
              SizedBox(height: 12),
              Text(
                '5 GHz Band',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 4),
              Text('• Higher speeds possible\n'
                   '• Less interference\n'
                   '• Shorter range\n'
                   '• More channels available'),
              SizedBox(height: 12),
              Text(
                'Frequency (MHz)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 4),
              Text('The specific channel frequency in megahertz. '
                   'Different channels reduce interference between nearby networks.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showQuickSettingsSheet(BuildContext context, dynamic interface) {
    final wirelessBloc = context.read<WirelessBloc>();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => BlocProvider.value(
        value: wirelessBloc,
        child: _QuickSettingsSheet(interface: interface),
      ),
    );
  }
}

class _QuickSettingsSheet extends StatefulWidget {
  final dynamic interface;

  const _QuickSettingsSheet({required this.interface});

  @override
  State<_QuickSettingsSheet> createState() => _QuickSettingsSheetState();
}

class _QuickSettingsSheetState extends State<_QuickSettingsSheet> {
  bool _isLoadingPassword = false;
  String? _currentPassword;

  @override
  Widget build(BuildContext context) {
    return BlocListener<WirelessBloc, WirelessState>(
      listener: (context, state) {
        if (state.operationSuccess != null) {
          if (state.operationSuccess!.startsWith('PASSWORD:')) {
            setState(() {
              _currentPassword = state.operationSuccess!.substring(9);
              _isLoadingPassword = false;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.operationSuccess!),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          }
        } else if (state.operationError != null) {
          setState(() {
            _isLoadingPassword = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.operationError!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Header
            Row(
              children: [
                Icon(Icons.wifi, color: Theme.of(context).primaryColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Settings',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.interface.name,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Change WiFi Name
            _buildSettingTile(
              icon: Icons.edit,
              title: 'Change WiFi Name (SSID)',
              subtitle: 'Current: ${widget.interface.ssid}',
              onTap: () => _showChangeSsidDialog(context),
            ),
            
            const Divider(height: 1),
            
            // Change WiFi Password
            _buildSettingTile(
              icon: Icons.lock,
              title: 'Change WiFi Password',
              subtitle: 'Security: ${widget.interface.security}',
              onTap: () => _showChangePasswordDialog(context),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Theme.of(context).primaryColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showChangeSsidDialog(BuildContext context) {
    final controller = TextEditingController(text: widget.interface.ssid);
    final wirelessBloc = context.read<WirelessBloc>();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Change WiFi Name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'New SSID',
                hintText: 'Enter new WiFi name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            Text(
              'Note: Connected devices will need to reconnect.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.of(dialogContext).pop();
                wirelessBloc.add(UpdateWirelessSsid(
                  widget.interface.id,
                  controller.text.trim(),
                ));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final controller = TextEditingController();
    final confirmController = TextEditingController();
    final wirelessBloc = context.read<WirelessBloc>();
    
    // Request password
    wirelessBloc.add(GetWirelessPassword(widget.interface.security));
    
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: wirelessBloc,
        child: _ChangePasswordDialog(
          securityProfile: widget.interface.security,
          controller: controller,
          confirmController: confirmController,
        ),
      ),
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  final String securityProfile;
  final TextEditingController controller;
  final TextEditingController confirmController;

  const _ChangePasswordDialog({
    required this.securityProfile,
    required this.controller,
    required this.confirmController,
  });

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  bool _isLoading = true;
  String? _currentPassword;
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<WirelessBloc, WirelessState>(
      listener: (context, state) {
        if (state.operationSuccess != null) {
          if (state.operationSuccess!.startsWith('PASSWORD:')) {
            setState(() {
              _currentPassword = state.operationSuccess!.substring(9);
              _isLoading = false;
            });
          } else if (state.operationSuccess!.contains('password updated')) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.operationSuccess!),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else if (state.operationError != null) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.operationError!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: AlertDialog(
        title: const Text('Change WiFi Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current password display
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Loading current password...'),
                    ],
                  ),
                )
              else if (_currentPassword != null && _currentPassword!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Current Password',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            Text(
                              _showPassword ? _currentPassword! : '••••••••',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              
              TextField(
                controller: widget.controller,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  hintText: 'Enter new WiFi password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: widget.confirmController,
                obscureText: !_showPassword,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Re-enter new password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Password must be at least 8 characters.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
            onPressed: () {
              if (widget.controller.text.length < 8) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password must be at least 8 characters'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              if (widget.controller.text != widget.confirmController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Passwords do not match'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              context.read<WirelessBloc>().add(UpdateWirelessPassword(
                widget.securityProfile,
                widget.controller.text,
              ));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _AddVirtualWlanSheet extends StatefulWidget {
  final List<dynamic> masterInterfaces;

  const _AddVirtualWlanSheet({required this.masterInterfaces});

  @override
  State<_AddVirtualWlanSheet> createState() => _AddVirtualWlanSheetState();
}

class _AddVirtualWlanSheetState extends State<_AddVirtualWlanSheet> {
  final _ssidController = TextEditingController();
  final _nameController = TextEditingController();
  String? _selectedMasterInterface;
  String? _selectedSecurityProfile;
  bool _enabled = true;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    // Auto-suggest name based on existing interfaces
    final existingCount = widget.masterInterfaces.length;
    _nameController.text = 'wlan${existingCount + 1}';
    
    // Pre-select first master interface if available
    if (widget.masterInterfaces.isNotEmpty) {
      _selectedMasterInterface = widget.masterInterfaces.first.name;
    }
    
    // Security profiles should already be loaded from parent widget
    // Only load if not already available
    final state = context.read<WirelessBloc>().state;
    if (state.profiles.isEmpty && !state.profilesLoading) {
      context.read<WirelessBloc>().add(const LoadSecurityProfiles());
    }
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WirelessBloc, WirelessState>(
      listener: (context, state) {
        if (state.operationSuccess != null && 
            state.operationSuccess!.contains('Virtual WiFi')) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.operationSuccess!),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state.operationError != null) {
          setState(() => _isCreating = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.operationError!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Header
              Row(
                children: [
                  Icon(Icons.add_circle, color: Theme.of(context).primaryColor, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Virtual WiFi',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Create a new virtual wireless interface',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Interface Name (optional)
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Interface Name',
                  hintText: 'e.g., wlan2',
                  border: OutlineInputBorder(),
                  helperText: 'Auto-generated, can be changed',
                ),
              ),
              const SizedBox(height: 16),
              
              // SSID (required)
              TextField(
                controller: _ssidController,
                decoration: const InputDecoration(
                  labelText: 'WiFi Name (SSID) *',
                  hintText: 'e.g., Guest Network',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              // Master Interface dropdown
              DropdownButtonFormField<String>(
                value: _selectedMasterInterface,
                decoration: const InputDecoration(
                  labelText: 'Master Interface *',
                  border: OutlineInputBorder(),
                ),
                items: widget.masterInterfaces.map<DropdownMenuItem<String>>((iface) {
                  return DropdownMenuItem<String>(
                    value: iface.name,
                    child: Text('${iface.name} - ${iface.ssid ?? "No SSID"}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedMasterInterface = value);
                },
              ),
              const SizedBox(height: 16),
              
              // Security Profile dropdown
              BlocBuilder<WirelessBloc, WirelessState>(
                buildWhen: (previous, current) => 
                    previous.profiles != current.profiles ||
                    previous.profilesLoading != current.profilesLoading,
                builder: (context, state) {
                  if (state.profilesLoading) {
                    return const LinearProgressIndicator();
                  }
                  
                  return DropdownButtonFormField<String>(
                    value: _selectedSecurityProfile,
                    decoration: const InputDecoration(
                      labelText: 'Security Profile',
                      border: OutlineInputBorder(),
                      helperText: 'Optional - uses default if empty',
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Default'),
                      ),
                      ...state.profiles.map((profile) {
                        return DropdownMenuItem<String>(
                          value: profile.name,
                          child: Text(profile.name),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedSecurityProfile = value);
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              
              // Enable switch
              SwitchListTile(
                title: const Text('Enable interface'),
                subtitle: const Text('Start broadcasting immediately'),
                value: _enabled,
                onChanged: (value) => setState(() => _enabled = value),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isCreating ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isCreating ? null : _createVirtualWlan,
                      child: _isCreating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _createVirtualWlan() {
    // Validation
    if (_ssidController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a WiFi name (SSID)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_selectedMasterInterface == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a master interface'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() => _isCreating = true);
    
    context.read<WirelessBloc>().add(AddVirtualWirelessInterface(
      ssid: _ssidController.text.trim(),
      masterInterface: _selectedMasterInterface!,
      name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
      securityProfile: _selectedSecurityProfile,
      enabled: _enabled,
    ));
  }
}