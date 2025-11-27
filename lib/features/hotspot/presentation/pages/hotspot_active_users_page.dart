import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/hotspot_bloc.dart';
import '../bloc/hotspot_event.dart';
import '../bloc/hotspot_state.dart';

class HotspotActiveUsersPage extends StatefulWidget {
  const HotspotActiveUsersPage({super.key});

  @override
  State<HotspotActiveUsersPage> createState() => _HotspotActiveUsersPageState();
}

class _HotspotActiveUsersPageState extends State<HotspotActiveUsersPage> {
  @override
  void initState() {
    super.initState();
    context.read<HotspotBloc>().add(const LoadHotspotActiveUsers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active HotSpot Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<HotspotBloc>().add(const LoadHotspotActiveUsers());
            },
          ),
        ],
      ),
      body: BlocConsumer<HotspotBloc, HotspotState>(
        listener: (context, state) {
          if (state is HotspotError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is HotspotOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is HotspotLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HotspotLoaded && state.activeUsers != null) {
            final users = state.activeUsers!;

            if (users.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No active users'),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<HotspotBloc>().add(const LoadHotspotActiveUsers());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        user.user,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${user.address} (${user.macAddress})'),
                      trailing: IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () {
                          _showDisconnectDialog(context, user.id, user.user);
                        },
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow('Server', user.server),
                              _buildInfoRow('Login By', user.loginBy),
                              _buildInfoRow('Uptime', user.uptime),
                              _buildInfoRow(
                                  'Session Time Left', user.sessionTimeLeft),
                              _buildInfoRow('Idle Time', user.idleTime),
                              const Divider(),
                              _buildInfoRow('Bytes In', _formatBytes(user.bytesIn)),
                              _buildInfoRow(
                                  'Bytes Out', _formatBytes(user.bytesOut)),
                              _buildInfoRow('Packets In', user.packetsIn),
                              _buildInfoRow('Packets Out', user.packetsOut),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
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
                    : 'Unable to load active users'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context
                        .read<HotspotBloc>()
                        .add(const LoadHotspotActiveUsers());
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

  String _formatBytes(String bytes) {
    try {
      final value = int.parse(bytes);
      if (value < 1024) return '$value B';
      if (value < 1024 * 1024) return '${(value / 1024).toStringAsFixed(2)} KB';
      if (value < 1024 * 1024 * 1024) {
        return '${(value / (1024 * 1024)).toStringAsFixed(2)} MB';
      }
      return '${(value / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    } catch (e) {
      return bytes;
    }
  }

  void _showDisconnectDialog(BuildContext context, String id, String username) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Disconnect User'),
          content: Text('Are you sure you want to disconnect "$username"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<HotspotBloc>().add(DisconnectHotspotUser(id));
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Disconnect'),
            ),
          ],
        );
      },
    );
  }
}
