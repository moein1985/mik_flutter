import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/hotspot_profile.dart';
import '../bloc/hotspot_bloc.dart';
import '../bloc/hotspot_event.dart';
import '../bloc/hotspot_state.dart';

class HotspotProfilesPage extends StatefulWidget {
  const HotspotProfilesPage({super.key});

  @override
  State<HotspotProfilesPage> createState() => _HotspotProfilesPageState();
}

class _HotspotProfilesPageState extends State<HotspotProfilesPage> {
  String? _lastShownMessage;

  @override
  void initState() {
    super.initState();
    context.read<HotspotBloc>().add(const LoadHotspotProfiles());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('HotSpot Profiles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              context.read<HotspotBloc>().add(const LoadHotspotProfiles());
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<HotspotBloc, HotspotState>(
        listener: (context, state) {
          if (state is HotspotError) {
            if (_lastShownMessage != state.message) {
              _lastShownMessage = state.message;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
              // Reload to return to normal state
              context.read<HotspotBloc>().add(const LoadHotspotProfiles());
            }
          } else if (state is HotspotOperationSuccess) {
            if (_lastShownMessage != state.message) {
              _lastShownMessage = state.message;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              // Reload after successful operation with a small delay
              Future.delayed(const Duration(milliseconds: 1000), () {
                if (mounted) {
                  context.read<HotspotBloc>().add(const LoadHotspotProfiles());
                }
              });
            }
          } else {
            _lastShownMessage = null;
          }
        },
        builder: (context, state) {
          return switch (state) {
            HotspotLoading() => const Center(child: CircularProgressIndicator()),
            HotspotLoaded(:final profiles) => profiles == null || profiles.isEmpty
                ? _buildEmptyView(colorScheme)
                : _buildProfilesList(context, profiles, colorScheme),
            _ => _buildEmptyView(colorScheme),
          };

        },
      ),
    );
  }

  Widget _buildQuickTipCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.settings, color: Colors.purple.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Profiles define session limits, bandwidth restrictions, and timeout settings for users.',
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

  Widget _buildProfilesList(BuildContext context, List<dynamic> profiles, ColorScheme colorScheme) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HotspotBloc>().add(const LoadHotspotProfiles());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Quick Tip
            _buildQuickTipCard(),
            
            const SizedBox(height: 16),
            
            // Profile count
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                '${profiles.length} profile${profiles.length > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            
            // Profile cards
            ...profiles.map((profile) => _buildProfileCard(profile, colorScheme)),
            
            // Bottom spacing for FAB
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildQuickTipCard(),
          
          const SizedBox(height: 48),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withAlpha(77),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.settings_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Profiles Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add a new profile',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(HotspotProfile profile, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline.withAlpha(51)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.purple.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.settings,
              color: Colors.purple.shade700,
              size: 24,
            ),
          ),
          title: Text(
            profile.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(
              spacing: 8,
              children: [
                if (profile.rateLimit != null && profile.rateLimit!.isNotEmpty)
                  _buildTag(profile.rateLimit!, Colors.blue, colorScheme),
                if (profile.sharedUsers != null)
                  _buildTag('${profile.sharedUsers} users', Colors.green, colorScheme),
              ],
            ),
          ),
          children: [
            const Divider(),
            const SizedBox(height: 8),
            
            // Settings Section
            _buildSectionTitle('Settings', Icons.tune, colorScheme),
            const SizedBox(height: 8),
            
            if (profile.sessionTimeout != null)
              _buildInfoRow('Session Timeout', profile.sessionTimeout!, colorScheme),
            if (profile.idleTimeout != null)
              _buildInfoRow('Idle Timeout', profile.idleTimeout!, colorScheme),
            if (profile.sharedUsers != null)
              _buildInfoRow('Shared Users', profile.sharedUsers!, colorScheme),
            if (profile.rateLimit != null)
              _buildInfoRow('Rate Limit', profile.rateLimit!, colorScheme),
            if (profile.keepaliveTimeout != null)
              _buildInfoRow('Keepalive', profile.keepaliveTimeout!, colorScheme),
            if (profile.statusAutorefresh != null)
              _buildInfoRow('Auto Refresh', profile.statusAutorefresh!, colorScheme),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showAddEditDialog(context, profile: profile),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDeleteConfirmation(context, profile),
                    icon: Icon(Icons.delete, size: 18, color: colorScheme.error),
                    label: Text('Delete', style: TextStyle(color: colorScheme.error)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colorScheme.error.withAlpha(128)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, HotspotProfile profile) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Profile'),
        content: Text(
          'Are you sure you want to delete profile "${profile.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<HotspotBloc>().add(DeleteHotspotProfile(profile.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Validators
  String? _validateName(String? value, bool isEditing) {
    if (isEditing) return null; // Name not editable
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  String? _validateTime(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Optional
    // Accept formats: 1h30m, 2d5h, 00:05:00, 1d 00:00:00, or plain seconds
    final patterns = [
      r'^\d+[wdhms](\d+[wdhms])*$', // 1h30m, 2d5h
      r'^\d{1,2}:\d{2}:\d{2}$', // 00:05:00
      r'^\d+d\s+\d{1,2}:\d{2}:\d{2}$', // 1d 00:00:00
      r'^\d+$', // plain seconds
    ];
    final isValid = patterns.any((pattern) => RegExp(pattern).hasMatch(value));
    if (!isValid) {
      return 'Invalid format. Use: 1h30m, 00:05:00, or 1d 00:00:00';
    }
    return null;
  }

  String? _validateSharedUsers(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Optional
    final number = int.tryParse(value);
    if (number == null || number < 1) {
      return 'Must be a positive number';
    }
    return null;
  }

  String? _validateRateLimit(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Optional
    // Format: 10M/5M, 1G/500M, 100k/50k
    final regex = RegExp(r'^\d+[kKmMgGtT]?\/\d+[kKmMgGtT]?$');
    if (!regex.hasMatch(value)) {
      return 'Invalid format. Use: 10M/5M or 1G/500M';
    }
    return null;
  }

  void _showAddEditDialog(BuildContext context, {HotspotProfile? profile}) {
    final isEditing = profile != null;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: profile?.name ?? '');
    final sessionTimeoutController = TextEditingController(text: profile?.sessionTimeout ?? '');
    final idleTimeoutController = TextEditingController(text: profile?.idleTimeout ?? '');
    final sharedUsersController = TextEditingController(text: profile?.sharedUsers ?? '1');
    final rateLimitController = TextEditingController(text: profile?.rateLimit ?? '');
    final keepaliveTimeoutController = TextEditingController(text: profile?.keepaliveTimeout ?? '');
    final statusAutorefreshController = TextEditingController(text: profile?.statusAutorefresh ?? '');
    
    final isFormValid = ValueNotifier<bool>(isEditing); // If editing, start enabled

    void validateForm() {
      isFormValid.value = formKey.currentState?.validate() ?? false;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Edit Profile' : 'Add Profile'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: validateForm,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    hintText: 'Profile name',
                    helperText: 'Required',
                  ),
                  enabled: !isEditing,
                  validator: (value) => _validateName(value, isEditing),
                  onChanged: (_) => validateForm(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: sessionTimeoutController,
                  decoration: const InputDecoration(
                    labelText: 'Session Timeout',
                    hintText: '1d 00:00:00 or 1h30m',
                    helperText: 'Format: 1h30m, 00:05:00, or 1d 00:00:00',
                  ),
                  validator: _validateTime,
                  onChanged: (_) => validateForm(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: idleTimeoutController,
                  decoration: const InputDecoration(
                    labelText: 'Idle Timeout',
                    hintText: '00:05:00 or 5m',
                    helperText: 'Format: 5m, 00:05:00',
                  ),
                  validator: _validateTime,
                  onChanged: (_) => validateForm(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: sharedUsersController,
                  decoration: const InputDecoration(
                    labelText: 'Shared Users',
                    hintText: '1',
                    helperText: 'Positive number',
                  ),
                  keyboardType: TextInputType.number,
                  validator: _validateSharedUsers,
                  onChanged: (_) => validateForm(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: rateLimitController,
                  decoration: const InputDecoration(
                    labelText: 'Rate Limit',
                    hintText: '10M/5M or 1G/500M',
                    helperText: 'Format: upload/download (e.g., 10M/5M)',
                  ),
                  validator: _validateRateLimit,
                  onChanged: (_) => validateForm(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: keepaliveTimeoutController,
                  decoration: const InputDecoration(
                    labelText: 'Keepalive Timeout',
                    hintText: '00:02:00 or 2m',
                    helperText: 'Format: 2m, 00:02:00',
                  ),
                  validator: _validateTime,
                  onChanged: (_) => validateForm(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: statusAutorefreshController,
                  decoration: const InputDecoration(
                    labelText: 'Status Autorefresh',
                    hintText: '00:01:00 or 1m',
                    helperText: 'Format: 1m, 00:01:00',
                  ),
                  validator: _validateTime,
                  onChanged: (_) => validateForm(),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: isFormValid,
            builder: (context, isValid, child) {
              return ElevatedButton(
                onPressed: !isValid ? null : () {
                  if (!formKey.currentState!.validate()) return;

                  Navigator.pop(ctx);

                  if (isEditing) {
                    this.context.read<HotspotBloc>().add(
                      EditHotspotProfile(
                        id: profile.id,
                        name: nameController.text.isNotEmpty ? nameController.text : null,
                        sessionTimeout: sessionTimeoutController.text.isNotEmpty ? sessionTimeoutController.text : null,
                        idleTimeout: idleTimeoutController.text.isNotEmpty ? idleTimeoutController.text : null,
                        sharedUsers: sharedUsersController.text.isNotEmpty ? sharedUsersController.text : null,
                        rateLimit: rateLimitController.text.isNotEmpty ? rateLimitController.text : null,
                        keepaliveTimeout: keepaliveTimeoutController.text.isNotEmpty ? keepaliveTimeoutController.text : null,
                        statusAutorefresh: statusAutorefreshController.text.isNotEmpty ? statusAutorefreshController.text : null,
                      ),
                    );
                  } else {
                    this.context.read<HotspotBloc>().add(
                      AddHotspotProfile(
                        name: nameController.text,
                        sessionTimeout: sessionTimeoutController.text.isNotEmpty ? sessionTimeoutController.text : null,
                        idleTimeout: idleTimeoutController.text.isNotEmpty ? idleTimeoutController.text : null,
                        sharedUsers: sharedUsersController.text.isNotEmpty ? sharedUsersController.text : null,
                        rateLimit: rateLimitController.text.isNotEmpty ? rateLimitController.text : null,
                        keepaliveTimeout: keepaliveTimeoutController.text.isNotEmpty ? keepaliveTimeoutController.text : null,
                        statusAutorefresh: statusAutorefreshController.text.isNotEmpty ? statusAutorefreshController.text : null,
                      ),
                    );
                  }
                },
                child: Text(isEditing ? 'Save' : 'Add'),
              );
            },
          ),
        ],
      ),
    );
  }
}
