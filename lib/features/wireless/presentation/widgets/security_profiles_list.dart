import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';import '../../domain/entities/security_profile.dart';import '../bloc/wireless_bloc.dart';
import '../bloc/wireless_event.dart';
import '../bloc/wireless_state.dart';

class SecurityProfilesList extends StatefulWidget {
  const SecurityProfilesList({super.key});

  @override
  State<SecurityProfilesList> createState() => _SecurityProfilesListState();
}

class _SecurityProfilesListState extends State<SecurityProfilesList> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Load data only once when widget is first created
    Future.microtask(() {
      if (mounted) {
        context.read<WirelessBloc>().add(const LoadSecurityProfiles());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return BlocBuilder<WirelessBloc, WirelessState>(
      buildWhen: (previous, current) {
        // Only rebuild on security profile-related state changes
        return previous.profilesLoading != current.profilesLoading ||
               previous.profiles != current.profiles ||
               previous.profilesError != current.profilesError;
      },
      builder: (context, state) {
        if (state.profilesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.profilesError != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.profilesError!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<WirelessBloc>().add(const LoadSecurityProfiles());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final profiles = state.profiles;
        if (profiles.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text('No security profiles found'),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<WirelessBloc>().add(const LoadSecurityProfiles());
          },
          child: Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: profiles.length,
                itemBuilder: (context, index) {
                  final profile = profiles[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(Icons.shield, color: Colors.blue),
                      title: Text(profile.name ?? 'Unknown Profile'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mode: ${profile.mode}'),
                          Text('Authentication: ${profile.authentication.isNotEmpty ? profile.authentication : 'N/A'}'),
                          Text('Encryption: ${profile.encryption.isNotEmpty ? profile.encryption : 'N/A'}'),
                          if (profile.password.isNotEmpty)
                            Text('WPA Key: ${profile.password}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _showEditProfileDialog(context, profile);
                            },
                          ),
                          if (profile.name != 'default')
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _showDeleteConfirmation(context, profile);
                              },
                            ),
                        ],
                      ),
                      onTap: () {
                        _showEditProfileDialog(context, profile);
                      },
                    ),
                  );
                },
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton(
                  onPressed: () {
                    _showAddProfileDialog(context);
                  },
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditProfileDialog(BuildContext context, SecurityProfile profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<WirelessBloc>(),
        child: _EditSecurityProfileSheet(profile: profile),
      ),
    );
  }

  void _showAddProfileDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<WirelessBloc>(),
        child: const _AddSecurityProfileSheet(),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, SecurityProfile profile) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Security Profile'),
        content: Text('Are you sure you want to delete "${profile.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<WirelessBloc>().add(DeleteSecurityProfile(profile.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _EditSecurityProfileSheet extends StatefulWidget {
  final SecurityProfile profile;

  const _EditSecurityProfileSheet({required this.profile});

  @override
  State<_EditSecurityProfileSheet> createState() => _EditSecurityProfileSheetState();
}

class _EditSecurityProfileSheetState extends State<_EditSecurityProfileSheet> {
  late TextEditingController _nameController;
  late TextEditingController _passwordController;
  late String _selectedAuthentication;
  late String _selectedEncryption;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final List<String> _authenticationTypes = [
    'wpa-psk',
    'wpa2-psk',
    'wpa-psk,wpa2-psk',
  ];

  final List<String> _encryptionTypes = [
    'aes-ccm',
    'tkip',
    'aes-ccm,tkip',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _passwordController = TextEditingController(text: widget.profile.password);
    _selectedAuthentication = widget.profile.authentication.isNotEmpty 
        ? widget.profile.authentication 
        : 'wpa2-psk';
    _selectedEncryption = widget.profile.encryption.isNotEmpty 
        ? widget.profile.encryption 
        : 'aes-ccm';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WirelessBloc, WirelessState>(
      listenWhen: (previous, current) =>
          previous.operationSuccess != current.operationSuccess ||
          previous.operationError != current.operationError,
      listener: (context, state) {
        if (state.operationSuccess != null) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.operationSuccess!),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (state.operationError != null) {
          setState(() => _isLoading = false);
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Security Profile',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Profile Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                enabled: widget.profile.name != 'default',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _authenticationTypes.contains(_selectedAuthentication) 
                    ? _selectedAuthentication 
                    : 'wpa2-psk',
                decoration: const InputDecoration(
                  labelText: 'Authentication',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.security),
                ),
                items: _authenticationTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getAuthDisplayName(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedAuthentication = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _encryptionTypes.contains(_selectedEncryption) 
                    ? _selectedEncryption 
                    : 'aes-ccm',
                decoration: const InputDecoration(
                  labelText: 'Encryption',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                items: _encryptionTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getEncryptionDisplayName(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedEncryption = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'WPA Pre-Shared Key',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.vpn_key),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  helperText: 'Minimum 8 characters',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Changes'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _getAuthDisplayName(String type) {
    switch (type) {
      case 'wpa-psk':
        return 'WPA PSK';
      case 'wpa2-psk':
        return 'WPA2 PSK';
      case 'wpa-psk,wpa2-psk':
        return 'WPA/WPA2 PSK';
      default:
        return type;
    }
  }

  String _getEncryptionDisplayName(String type) {
    switch (type) {
      case 'aes-ccm':
        return 'AES-CCM';
      case 'tkip':
        return 'TKIP';
      case 'aes-ccm,tkip':
        return 'AES-CCM + TKIP';
      default:
        return type;
    }
  }

  void _saveProfile() {
    final name = _nameController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile name is required')),
      );
      return;
    }

    if (password.isNotEmpty && password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 8 characters')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final updatedProfile = SecurityProfile(
      id: widget.profile.id,
      name: name,
      authentication: _selectedAuthentication,
      encryption: _selectedEncryption,
      password: password,
      mode: widget.profile.mode,
      managementProtection: widget.profile.managementProtection,
      wpaPreSharedKey: widget.profile.wpaPreSharedKey,
      wpa2PreSharedKey: widget.profile.wpa2PreSharedKey,
    );

    context.read<WirelessBloc>().add(UpdateSecurityProfile(updatedProfile));
  }
}

class _AddSecurityProfileSheet extends StatefulWidget {
  const _AddSecurityProfileSheet();

  @override
  State<_AddSecurityProfileSheet> createState() => _AddSecurityProfileSheetState();
}

class _AddSecurityProfileSheetState extends State<_AddSecurityProfileSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedAuthentication = 'wpa2-psk';
  String _selectedEncryption = 'aes-ccm';
  bool _isLoading = false;
  bool _obscurePassword = true;

  final List<String> _authenticationTypes = [
    'wpa-psk',
    'wpa2-psk',
    'wpa-psk,wpa2-psk',
  ];

  final List<String> _encryptionTypes = [
    'aes-ccm',
    'tkip',
    'aes-ccm,tkip',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WirelessBloc, WirelessState>(
      listenWhen: (previous, current) =>
          previous.operationSuccess != current.operationSuccess ||
          previous.operationError != current.operationError,
      listener: (context, state) {
        if (state.operationSuccess != null) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.operationSuccess!),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (state.operationError != null) {
          setState(() => _isLoading = false);
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add Security Profile',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Profile Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                  hintText: 'e.g., my-profile',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedAuthentication,
                decoration: const InputDecoration(
                  labelText: 'Authentication',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.security),
                ),
                items: _authenticationTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getAuthDisplayName(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedAuthentication = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedEncryption,
                decoration: const InputDecoration(
                  labelText: 'Encryption',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                items: _encryptionTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getEncryptionDisplayName(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedEncryption = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'WPA Pre-Shared Key',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.vpn_key),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  helperText: 'Minimum 8 characters',
                  hintText: 'Enter password',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _createProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Profile'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _getAuthDisplayName(String type) {
    switch (type) {
      case 'wpa-psk':
        return 'WPA PSK';
      case 'wpa2-psk':
        return 'WPA2 PSK';
      case 'wpa-psk,wpa2-psk':
        return 'WPA/WPA2 PSK';
      default:
        return type;
    }
  }

  String _getEncryptionDisplayName(String type) {
    switch (type) {
      case 'aes-ccm':
        return 'AES-CCM';
      case 'tkip':
        return 'TKIP';
      case 'aes-ccm,tkip':
        return 'AES-CCM + TKIP';
      default:
        return type;
    }
  }

  void _createProfile() {
    final name = _nameController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile name is required')),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password is required')),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 8 characters')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final newProfile = SecurityProfile(
      id: '',
      name: name,
      authentication: _selectedAuthentication,
      encryption: _selectedEncryption,
      password: password,
      mode: 'dynamic-keys',
      managementProtection: false,
      wpaPreSharedKey: 0,
      wpa2PreSharedKey: 0,
    );

    context.read<WirelessBloc>().add(CreateSecurityProfile(newProfile));
  }
}