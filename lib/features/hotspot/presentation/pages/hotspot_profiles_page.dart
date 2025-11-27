import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      body: BlocBuilder<HotspotBloc, HotspotState>(
        builder: (context, state) {
          if (state is HotspotLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HotspotLoaded && state.profiles != null) {
            final profiles = state.profiles!;

            if (profiles.isEmpty) {
              return const Center(
                child: Text('No profiles found'),
              );
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
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (profile.sessionTimeout != null)
                                _buildInfoRow('Session Timeout',
                                    profile.sessionTimeout!),
                              if (profile.idleTimeout != null)
                                _buildInfoRow(
                                    'Idle Timeout', profile.idleTimeout!),
                              if (profile.sharedUsers != null)
                                _buildInfoRow(
                                    'Shared Users', profile.sharedUsers!),
                              if (profile.rateLimit != null)
                                _buildInfoRow('Rate Limit', profile.rateLimit!),
                              if (profile.keepaliveTimeout != null)
                                _buildInfoRow('Keepalive Timeout',
                                    profile.keepaliveTimeout!),
                              if (profile.statusAutorefresh != null)
                                _buildInfoRow('Status Autorefresh',
                                    profile.statusAutorefresh!),
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
}
