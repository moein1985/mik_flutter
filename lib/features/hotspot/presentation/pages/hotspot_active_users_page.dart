import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/hotspot_active_user.dart';
import '../bloc/hotspot_bloc.dart';
import '../bloc/hotspot_event.dart';
import '../bloc/hotspot_state.dart';

class HotspotActiveUsersPage extends StatefulWidget {
  const HotspotActiveUsersPage({super.key});

  @override
  State<HotspotActiveUsersPage> createState() => _HotspotActiveUsersPageState();
}

class _HotspotActiveUsersPageState extends State<HotspotActiveUsersPage> {
  String? _lastShownMessage;

  @override
  void initState() {
    super.initState();
    context.read<HotspotBloc>().add(const LoadHotspotActiveUsers());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              context.read<HotspotBloc>().add(const LoadHotspotActiveUsers());
            },
          ),
        ],
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
              context.read<HotspotBloc>().add(const LoadHotspotActiveUsers());
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
              // Reload active users after disconnect with a small delay
              Future.delayed(const Duration(milliseconds: 1000), () {
                if (!mounted) return;
                // ignore: use_build_context_synchronously
                context.read<HotspotBloc>().add(const LoadHotspotActiveUsers());
              });
            }
          } else {
            _lastShownMessage = null;
          }
        },
        builder: (context, state) {
          return switch (state) {
            HotspotLoading() => const Center(child: CircularProgressIndicator()),
            HotspotLoaded(:final activeUsers) => activeUsers == null || activeUsers.isEmpty
                ? _buildEmptyView(colorScheme)
                : _buildActiveUsersList(context, activeUsers, colorScheme),
            _ => _buildErrorView(context, colorScheme, state),
          };
        },
      ),
    );
  }

  Widget _buildActiveUsersList(BuildContext context, List<dynamic> users, ColorScheme colorScheme) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HotspotBloc>().add(const LoadHotspotActiveUsers());
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
            
            // User count banner
            _buildUserCountBanner(users.length, colorScheme),
            
            const SizedBox(height: 16),
            
            // User cards
            ...users.map((user) => _buildUserCard(user, colorScheme)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTipCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.people, color: Colors.green.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'View currently connected users and their session details. Tap to disconnect.',
              style: TextStyle(
                color: Colors.green.shade800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCountBanner(int count, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, color: Colors.blue.shade700, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count Online',
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Active user${count > 1 ? 's' : ''} connected',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Pulse indicator
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              shape: BoxShape.circle,
            ),
          ),
        ],
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
              Icons.person_off,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Active Users',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No users are currently connected to the HotSpot',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, ColorScheme colorScheme, HotspotState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withAlpha(77),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            state is HotspotError ? state.message : 'Unable to load active users',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              context.read<HotspotBloc>().add(const LoadHotspotActiveUsers());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(HotspotActiveUser user, ColorScheme colorScheme) {
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
              color: Colors.green.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: Colors.green.shade700,
              size: 24,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  user.user,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Online status dot
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.address,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      user.uptime,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.logout, color: Colors.red.shade400),
            tooltip: 'Disconnect',
            onPressed: () => _showDisconnectDialog(context, user.id, user.user),
          ),
          children: [
            const Divider(),
            const SizedBox(height: 8),
            // Session Info
            _buildSectionTitle('Session Info', Icons.info_outline, colorScheme),
            const SizedBox(height: 8),
            _buildDetailRow('Server', user.server, colorScheme),
            _buildDetailRow('MAC Address', user.macAddress, colorScheme),
            _buildDetailRow('Login By', user.loginBy, colorScheme),
            _buildDetailRow('Session Time Left', user.sessionTimeLeft, colorScheme),
            _buildDetailRow('Idle Time', user.idleTime, colorScheme),
            
            const SizedBox(height: 16),
            
            // Traffic Stats
            _buildSectionTitle('Traffic', Icons.swap_vert, colorScheme),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('Download', _formatBytes(user.bytesIn), Icons.download, Colors.blue, colorScheme),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('Upload', _formatBytes(user.bytesOut), Icons.upload, Colors.orange, colorScheme),
                ),
              ],
            ),
          ],
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

  Widget _buildDetailRow(String label, String value, ColorScheme colorScheme) {
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

  String _formatBytes(String bytes) {
    try {
      final value = int.parse(bytes);
      if (value < 1024) return '$value B';
      if (value < 1024 * 1024) return '${(value / 1024).toStringAsFixed(1)} KB';
      if (value < 1024 * 1024 * 1024) {
        return '${(value / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
      return '${(value / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    } catch (e) {
      return bytes;
    }
  }

  void _showDisconnectDialog(BuildContext context, String id, String username) {
    final colorScheme = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Icon(Icons.logout, color: Colors.red.shade400),
          title: const Text('Disconnect User'),
          content: Text('Are you sure you want to disconnect "$username"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                context.read<HotspotBloc>().add(DisconnectHotspotUser(id));
                Navigator.pop(dialogContext);
              },
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
              ),
              child: const Text('Disconnect'),
            ),
          ],
        );
      },
    );
  }
}
