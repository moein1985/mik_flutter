import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/hotspot_user.dart';
import '../bloc/hotspot_bloc.dart';
import '../bloc/hotspot_event.dart';
import '../bloc/hotspot_state.dart';

class HotspotUsersPage extends StatefulWidget {
  const HotspotUsersPage({super.key});

  @override
  State<HotspotUsersPage> createState() => _HotspotUsersPageState();
}

class _HotspotUsersPageState extends State<HotspotUsersPage> {
  String? _lastShownMessage;

  @override
  void initState() {
    super.initState();
    context.read<HotspotBloc>().add(const LoadHotspotUsers());
  }

  void _showSnackBarOnce(String message, {bool isError = false}) {
    if (_lastShownMessage != message) {
      _lastShownMessage = message;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _lastShownMessage == message) {
          _lastShownMessage = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HotSpot Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<HotspotBloc>().add(const LoadHotspotUsers());
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserDialog(context),
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<HotspotBloc, HotspotState>(
        listener: (context, state) {
          if (state is HotspotOperationSuccess) {
            _showSnackBarOnce(state.message);
          } else if (state is HotspotError) {
            _showSnackBarOnce(state.message, isError: true);
          }
        },
        builder: (context, state) {
          if (state is HotspotLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = state is HotspotLoaded ? state.users : null;

          if (users != null) {
            if (users.isEmpty) {
              return const Center(
                child: Text('No users found'),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<HotspotBloc>().add(const LoadHotspotUsers());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return _buildUserCard(context, user);
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
                    : 'Unable to load users'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<HotspotBloc>().add(const LoadHotspotUsers());
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

  Widget _buildUserCard(BuildContext context, HotspotUser user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: user.disabled ? Colors.grey : Colors.green,
          child: Icon(
            user.disabled ? Icons.person_off : Icons.person,
            color: Colors.white,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Switch(
              value: !user.disabled,
              onChanged: (value) {
                context.read<HotspotBloc>().add(
                      ToggleHotspotUser(id: user.id, enable: value),
                    );
              },
            ),
          ],
        ),
        subtitle: Row(
          children: [
            if (user.profile != null)
              Chip(
                label: Text(user.profile!, style: const TextStyle(fontSize: 11)),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
            const SizedBox(width: 8),
            Chip(
              label: Text(
                user.disabled ? 'Disabled' : 'Enabled',
                style: const TextStyle(fontSize: 11, color: Colors.white),
              ),
              backgroundColor: user.disabled ? Colors.red : Colors.green,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Info Section
                _buildSectionTitle('Basic Info'),
                _buildInfoRow('Server', user.server ?? 'all'),
                if (user.comment != null && user.comment!.isNotEmpty)
                  _buildInfoRow('Comment', user.comment!),

                const Divider(height: 24),

                // Limits Section
                _buildSectionTitle('Limits', icon: Icons.speed),
                if (user.hasLimits) ...[
                  if (user.limitUptime != null && user.limitUptime!.isNotEmpty)
                    _buildInfoRow('Uptime Limit', user.limitUptime!),
                  if (user.limitBytesIn != null && user.limitBytesIn!.isNotEmpty)
                    _buildInfoRow('Download Limit', _formatBytes(user.limitBytesIn!)),
                  if (user.limitBytesOut != null && user.limitBytesOut!.isNotEmpty)
                    _buildInfoRow('Upload Limit', _formatBytes(user.limitBytesOut!)),
                  if (user.limitBytesTotal != null && user.limitBytesTotal!.isNotEmpty)
                    _buildInfoRow('Total Limit', _formatBytes(user.limitBytesTotal!)),
                ] else
                  const Text(
                    'No limits set',
                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                  ),

                const Divider(height: 24),

                // Statistics Section
                _buildSectionTitle('Statistics', icon: Icons.bar_chart),
                if (user.hasStatistics) ...[
                  if (user.uptime != null && user.uptime!.isNotEmpty)
                    _buildInfoRow('Uptime', user.uptime!),
                  if (user.bytesIn != null && user.bytesIn!.isNotEmpty)
                    _buildInfoRow('Downloaded', _formatBytes(user.bytesIn!)),
                  if (user.bytesOut != null && user.bytesOut!.isNotEmpty)
                    _buildInfoRow('Uploaded', _formatBytes(user.bytesOut!)),
                ] else
                  const Text(
                    'No usage statistics',
                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                  ),

                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Edit Button
                    ElevatedButton.icon(
                      onPressed: () => _showEditUserDialog(context, user),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    // Reset Statistics Button
                    if (user.hasStatistics)
                      ElevatedButton.icon(
                        onPressed: () => _showResetCountersDialog(context, user),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Reset Stats'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    // Delete Button
                    ElevatedButton.icon(
                      onPressed: () => _showDeleteUserDialog(context, user),
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: Colors.blue),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatBytes(String bytesStr) {
    try {
      final bytes = int.tryParse(bytesStr) ?? 0;
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
      if (bytes < 1024 * 1024 * 1024) {
        return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
      }
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    } catch (e) {
      return bytesStr;
    }
  }

  void _showAddUserDialog(BuildContext context) {
    _showUserFormDialog(context, null);
  }

  void _showEditUserDialog(BuildContext context, HotspotUser user) {
    _showUserFormDialog(context, user);
  }

  void _showUserFormDialog(BuildContext context, HotspotUser? user) {
    final isEditing = user != null;
    final nameController = TextEditingController(text: user?.name ?? '');
    final passwordController = TextEditingController();
    final commentController = TextEditingController(text: user?.comment ?? '');
    final limitUptimeController =
        TextEditingController(text: user?.limitUptime ?? '');
    final limitBytesInController =
        TextEditingController(text: user?.limitBytesIn ?? '');
    final limitBytesOutController =
        TextEditingController(text: user?.limitBytesOut ?? '');
    final limitBytesTotalController =
        TextEditingController(text: user?.limitBytesTotal ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit User: ${user.name}' : 'Add HotSpot User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Fields
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Username *',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !isEditing, // Can't change username when editing
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: isEditing ? 'New Password (leave empty to keep)' : 'Password *',
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    labelText: 'Comment (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),

                const Divider(height: 24),

                // Limits Section
                const Text(
                  'Limits',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Leave empty for no limit',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: limitUptimeController,
                  decoration: const InputDecoration(
                    labelText: 'Uptime Limit',
                    hintText: 'e.g., 1h, 30m, 1d',
                    border: OutlineInputBorder(),
                    helperText: 'Format: 1h, 30m, 1d, etc.',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: limitBytesInController,
                  decoration: const InputDecoration(
                    labelText: 'Download Limit (bytes)',
                    hintText: 'e.g., 1073741824 for 1GB',
                    border: OutlineInputBorder(),
                    helperText: '1GB = 1073741824',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: limitBytesOutController,
                  decoration: const InputDecoration(
                    labelText: 'Upload Limit (bytes)',
                    hintText: 'e.g., 1073741824 for 1GB',
                    border: OutlineInputBorder(),
                    helperText: '1GB = 1073741824',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: limitBytesTotalController,
                  decoration: const InputDecoration(
                    labelText: 'Total Traffic Limit (bytes)',
                    hintText: 'e.g., 1073741824 for 1GB',
                    border: OutlineInputBorder(),
                    helperText: '1GB = 1073741824',
                  ),
                  keyboardType: TextInputType.number,
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
                final name = nameController.text.trim();
                final password = passwordController.text;
                final comment = commentController.text.trim();
                final limitUptime = limitUptimeController.text.trim();
                final limitBytesIn = limitBytesInController.text.trim();
                final limitBytesOut = limitBytesOutController.text.trim();
                final limitBytesTotal = limitBytesTotalController.text.trim();

                if (isEditing) {
                  // Editing existing user
                  context.read<HotspotBloc>().add(
                        EditHotspotUser(
                          id: user.id,
                          name: name.isEmpty ? null : name,
                          password: password.isEmpty ? null : password,
                          comment: comment.isEmpty ? null : comment,
                          limitUptime: limitUptime.isEmpty ? null : limitUptime,
                          limitBytesIn: limitBytesIn.isEmpty ? null : limitBytesIn,
                          limitBytesOut: limitBytesOut.isEmpty ? null : limitBytesOut,
                          limitBytesTotal: limitBytesTotal.isEmpty ? null : limitBytesTotal,
                        ),
                      );
                } else {
                  // Adding new user
                  if (name.isNotEmpty && password.isNotEmpty) {
                    context.read<HotspotBloc>().add(
                          AddHotspotUser(
                            name: name,
                            password: password,
                            comment: comment.isEmpty ? null : comment,
                            limitUptime: limitUptime.isEmpty ? null : limitUptime,
                            limitBytesIn: limitBytesIn.isEmpty ? null : limitBytesIn,
                            limitBytesOut: limitBytesOut.isEmpty ? null : limitBytesOut,
                            limitBytesTotal: limitBytesTotal.isEmpty ? null : limitBytesTotal,
                          ),
                        );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Username and password are required'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                }
                Navigator.pop(dialogContext);
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  void _showResetCountersDialog(BuildContext context, HotspotUser user) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reset Statistics'),
          content: Text(
            'Are you sure you want to reset all usage statistics for "${user.name}"?\n\n'
            'This will reset:\n'
            '• Uptime counter\n'
            '• Downloaded bytes\n'
            '• Uploaded bytes',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<HotspotBloc>().add(
                      ResetHotspotUserCounters(user.id),
                    );
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteUserDialog(BuildContext context, HotspotUser user) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete User'),
          content: Text(
            'Are you sure you want to delete user "${user.name}"?\n\n'
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<HotspotBloc>().add(
                      DeleteHotspotUser(user.id),
                    );
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
