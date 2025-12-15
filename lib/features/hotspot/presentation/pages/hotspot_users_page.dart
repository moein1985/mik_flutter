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
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<HotspotBloc>().add(const LoadHotspotUsers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  List<HotspotUser> _filterUsers(List<HotspotUser> users) {
    if (_searchQuery.isEmpty) return users;
    return users.where((user) {
      final query = _searchQuery.toLowerCase();
      return user.name.toLowerCase().contains(query) ||
          (user.comment?.toLowerCase().contains(query) ?? false) ||
          (user.profile?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('HotSpot Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              context.read<HotspotBloc>().add(const LoadHotspotUsers());
            },
          ),
        ],
      ),
      floatingActionButton: _buildSpeedDialFAB(context),
      body: BlocConsumer<HotspotBloc, HotspotState>(
        listener: (context, state) {
          if (state is HotspotOperationSuccess) {
            _showSnackBarOnce(state.message);
            // Reload users after operation
            context.read<HotspotBloc>().add(const LoadHotspotUsers());
          } else if (state is HotspotError) {
            _showSnackBarOnce(state.message, isError: true);
          }
        },
        builder: (context, state) {
          return switch (state) {
            HotspotLoading() => const Center(child: CircularProgressIndicator()),
            HotspotLoaded(:final users) => users == null || users.isEmpty
                ? _buildEmptyView(colorScheme)
                : _buildUsersView(context, users, colorScheme),
            HotspotError(:final previousData) => previousData != null && previousData.users != null && previousData.users!.isNotEmpty
                ? _buildUsersView(context, previousData.users!, colorScheme)
                : _buildEmptyView(colorScheme),
            HotspotOperationSuccess(:final previousData) => previousData != null && previousData.users != null
                ? (previousData.users!.isEmpty
                    ? _buildEmptyView(colorScheme)
                    : _buildUsersView(context, previousData.users!, colorScheme))
                : _buildEmptyView(colorScheme),
            _ => _buildEmptyView(colorScheme),
          };
        },
      ),
    );
  }

  Widget _buildUsersView(BuildContext context, List<HotspotUser> users, ColorScheme colorScheme) {
    final filteredUsers = _filterUsers(users);

    return RefreshIndicator(
      onRefresh: () async {
        context.read<HotspotBloc>().add(const LoadHotspotUsers());
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
            
            // Search Bar
            _buildSearchBar(colorScheme),
            
            const SizedBox(height: 16),

            // User count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                _searchQuery.isEmpty 
                    ? '${users.length} user${users.length > 1 ? 's' : ''}'
                    : '${filteredUsers.length} of ${users.length} users',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            
            // User cards
            if (filteredUsers.isEmpty && _searchQuery.isNotEmpty)
              _buildNoResultsView(colorScheme)
            else
              ...filteredUsers.map((user) => _buildUserCard(context, user, colorScheme)),
            
            // Bottom spacing for FAB
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTipCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.people, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Manage HotSpot user accounts, set limits, and track usage statistics.',
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

  Widget _buildSearchBar(ColorScheme colorScheme) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search users...',
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
          borderSide: BorderSide(color: colorScheme.outline.withAlpha(51)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withAlpha(51)),
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withAlpha(77),
      ),
      onChanged: (value) => setState(() => _searchQuery = value),
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
              Icons.people_outline,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Users Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add a new HotSpot user',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsView(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 48, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              'No users match "$_searchQuery"',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, HotspotUser user, ColorScheme colorScheme) {
    final isEnabled = !user.disabled;
    final statusColor = isEnabled ? Colors.green : Colors.grey;
    
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
              color: statusColor.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEnabled ? Icons.person : Icons.person_off,
              color: statusColor,
              size: 24,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Status dot
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              // Toggle switch
              Switch(
                value: isEnabled,
                onChanged: (value) {
                  context.read<HotspotBloc>().add(
                    ToggleHotspotUser(id: user.id, enable: value),
                  );
                },
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (user.profile != null)
                  _buildTag(user.profile!, Colors.purple, colorScheme),
                _buildTag(
                  isEnabled ? 'Enabled' : 'Disabled',
                  statusColor,
                  colorScheme,
                ),
              ],
            ),
          ),
          children: [
            const Divider(),
            const SizedBox(height: 8),
            
            // Basic Info Section
            _buildSectionTitle('Basic Info', Icons.info_outline, colorScheme),
            const SizedBox(height: 8),
            _buildInfoRow('Server', user.server ?? 'all', colorScheme),
            if (user.comment != null && user.comment!.isNotEmpty)
              _buildInfoRow('Comment', user.comment!, colorScheme),

            const SizedBox(height: 16),

            // Limits Section
            _buildSectionTitle('Limits', Icons.speed, colorScheme),
            const SizedBox(height: 8),
            if (user.hasLimits) ...[
              if (user.limitUptime != null && user.limitUptime!.isNotEmpty)
                _buildInfoRow('Uptime', user.limitUptime!, colorScheme),
              if (user.limitBytesIn != null && user.limitBytesIn!.isNotEmpty)
                _buildInfoRow('Download', _formatBytes(user.limitBytesIn!), colorScheme),
              if (user.limitBytesOut != null && user.limitBytesOut!.isNotEmpty)
                _buildInfoRow('Upload', _formatBytes(user.limitBytesOut!), colorScheme),
              if (user.limitBytesTotal != null && user.limitBytesTotal!.isNotEmpty)
                _buildInfoRow('Total', _formatBytes(user.limitBytesTotal!), colorScheme),
            ] else
              Text(
                'No limits set',
                style: TextStyle(color: colorScheme.onSurfaceVariant, fontStyle: FontStyle.italic, fontSize: 13),
              ),

            const SizedBox(height: 16),

            // Statistics Section
            _buildSectionTitle('Statistics', Icons.bar_chart, colorScheme),
            const SizedBox(height: 8),
            if (user.hasStatistics) ...[
              Row(
                children: [
                  if (user.bytesIn != null && user.bytesIn!.isNotEmpty)
                    Expanded(
                      child: _buildStatCard('Download', _formatBytes(user.bytesIn!), Icons.download, Colors.blue, colorScheme),
                    ),
                  if (user.bytesIn != null && user.bytesOut != null)
                    const SizedBox(width: 12),
                  if (user.bytesOut != null && user.bytesOut!.isNotEmpty)
                    Expanded(
                      child: _buildStatCard('Upload', _formatBytes(user.bytesOut!), Icons.upload, Colors.orange, colorScheme),
                    ),
                ],
              ),
              if (user.uptime != null && user.uptime!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _buildInfoRow('Uptime', user.uptime!, colorScheme),
                ),
            ] else
              Text(
                'No usage statistics',
                style: TextStyle(color: colorScheme.onSurfaceVariant, fontStyle: FontStyle.italic, fontSize: 13),
              ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showEditUserDialog(context, user),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 8),
                if (user.hasStatistics)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showResetCountersDialog(context, user),
                      icon: Icon(Icons.refresh, size: 18, color: Colors.orange.shade700),
                      label: Text('Reset', style: TextStyle(color: Colors.orange.shade700)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.orange.shade300),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDeleteUserDialog(context, user),
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

  Widget _buildStatCard(String label, String value, IconData icon, Color color, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant,
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
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      if (bytes < 1024 * 1024 * 1024) {
        return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
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

  Widget _buildSpeedDialFAB(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Reset All Counters Button
        BlocBuilder<HotspotBloc, HotspotState>(
          builder: (context, state) {
            final users = state is HotspotLoaded ? state.users : null;
            final hasStats = users?.any((u) => u.hasStatistics) ?? false;

            if (!hasStats) return const SizedBox.shrink();

            return FloatingActionButton.small(
              heroTag: 'reset_all',
              onPressed: () => _showResetAllCountersDialog(context),
              backgroundColor: Colors.orange,
              child: const Icon(Icons.restore, size: 20),
            );
          },
        ),
        const SizedBox(height: 12),
        // Add User Button
        FloatingActionButton(
          heroTag: 'add_user',
          onPressed: () => _showAddUserDialog(context),
          child: const Icon(Icons.add),
        ),
      ],
    );
  }

  void _showResetAllCountersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 8),
              Text('Reset All Counters'),
            ],
          ),
          content: const Text(
            'Are you sure you want to reset usage statistics for ALL users?\n\n'
            'This will reset:\n'
            '• Uptime counters\n'
            '• Downloaded bytes\n'
            '• Uploaded bytes\n\n'
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
                      const ResetAllUserCounters(),
                    );
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reset All'),
            ),
          ],
        );
      },
    );
  }
}
