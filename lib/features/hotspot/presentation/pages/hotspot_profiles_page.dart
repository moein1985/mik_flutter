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
  @override
  void initState() {
    super.initState();
    context.read<HotspotBloc>().add(const LoadHotspotProfiles());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HotSpot Profiles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is HotspotOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Reload after successful operation
            context.read<HotspotBloc>().add(const LoadHotspotProfiles());
          }
        },
        builder: (context, state) {
          if (state is HotspotLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HotspotLoaded && state.profiles != null) {
            final profiles = state.profiles!;

            if (profiles.isEmpty) {
              return _buildEmptyView();
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<HotspotBloc>().add(const LoadHotspotProfiles());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: profiles.length,
                itemBuilder: (context, index) {
                  final profile = profiles[index];
                  return _buildProfileCard(profile);
                },
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(state is HotspotError
                    ? state.message
                    : 'Unable to load profiles'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<HotspotBloc>().add(const LoadHotspotProfiles());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.settings_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Profiles Found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add a new profile',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(HotspotProfile profile) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.purple,
          child: Icon(Icons.settings, color: Colors.white),
        ),
        title: Text(
          profile.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _showAddEditDialog(context, profile: profile),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () => _showDeleteConfirmation(context, profile),
            ),
            const Icon(Icons.expand_more),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (profile.sessionTimeout != null)
                  _buildInfoRow('Session Timeout', profile.sessionTimeout!),
                if (profile.idleTimeout != null)
                  _buildInfoRow('Idle Timeout', profile.idleTimeout!),
                if (profile.sharedUsers != null)
                  _buildInfoRow('Shared Users', profile.sharedUsers!),
                if (profile.rateLimit != null)
                  _buildInfoRow('Rate Limit', profile.rateLimit!),
                if (profile.keepaliveTimeout != null)
                  _buildInfoRow('Keepalive Timeout', profile.keepaliveTimeout!),
                if (profile.statusAutorefresh != null)
                  _buildInfoRow('Status Autorefresh', profile.statusAutorefresh!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
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

  void _showAddEditDialog(BuildContext context, {HotspotProfile? profile}) {
    final isEditing = profile != null;
    final nameController = TextEditingController(text: profile?.name ?? '');
    final sessionTimeoutController = TextEditingController(text: profile?.sessionTimeout ?? '');
    final idleTimeoutController = TextEditingController(text: profile?.idleTimeout ?? '');
    final sharedUsersController = TextEditingController(text: profile?.sharedUsers ?? '1');
    final rateLimitController = TextEditingController(text: profile?.rateLimit ?? '');
    final keepaliveTimeoutController = TextEditingController(text: profile?.keepaliveTimeout ?? '');
    final statusAutorefreshController = TextEditingController(text: profile?.statusAutorefresh ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Edit Profile' : 'Add Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  hintText: 'Profile name',
                ),
                enabled: !isEditing, // Can't change name when editing
              ),
              const SizedBox(height: 12),
              TextField(
                controller: sessionTimeoutController,
                decoration: const InputDecoration(
                  labelText: 'Session Timeout',
                  hintText: '1d 00:00:00',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: idleTimeoutController,
                decoration: const InputDecoration(
                  labelText: 'Idle Timeout',
                  hintText: '00:05:00',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: sharedUsersController,
                decoration: const InputDecoration(
                  labelText: 'Shared Users',
                  hintText: '1',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: rateLimitController,
                decoration: const InputDecoration(
                  labelText: 'Rate Limit',
                  hintText: '1M/2M',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: keepaliveTimeoutController,
                decoration: const InputDecoration(
                  labelText: 'Keepalive Timeout',
                  hintText: '00:02:00',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: statusAutorefreshController,
                decoration: const InputDecoration(
                  labelText: 'Status Autorefresh',
                  hintText: '00:01:00',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty && !isEditing) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile name is required'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(ctx);

              final data = <String, dynamic>{
                'name': nameController.text,
                'session-timeout': sessionTimeoutController.text,
                'idle-timeout': idleTimeoutController.text,
                'shared-users': sharedUsersController.text,
                'rate-limit': rateLimitController.text,
                'keepalive-timeout': keepaliveTimeoutController.text,
                'status-autorefresh': statusAutorefreshController.text,
              };

              // Remove empty values
              data.removeWhere((key, value) => value == null || value.toString().isEmpty);

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
          ),
        ],
      ),
    );
  }
}
