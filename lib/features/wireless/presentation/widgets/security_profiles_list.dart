import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/wireless_bloc.dart';
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
        // Only rebuild on security profile-related states
        return current is WirelessInitial ||
               current is SecurityProfilesLoading ||
               current is SecurityProfilesLoaded ||
               current is SecurityProfilesError;
      },
      builder: (context, state) {
        if (state is SecurityProfilesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is SecurityProfilesError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.message),
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

        if (state is SecurityProfilesLoaded) {
          if (state.profiles.isEmpty) {
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
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.profiles.length,
              itemBuilder: (context, index) {
                final profile = state.profiles[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.shield, color: Colors.blue),
                    title: Text(profile.name ?? 'Unknown Profile'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mode: ${profile.mode ?? 'N/A'}'),
                        Text('Authentication: ${profile.authentication ?? 'N/A'}'),
                        Text('Encryption: ${profile.encryption ?? 'N/A'}'),
                        if (profile.wpaPreSharedKey != null)
                          Text('WPA Key: ${'*' * (profile.wpaPreSharedKey!.length > 8 ? 8 : profile.wpaPreSharedKey!.length)}'),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: profile.disabled == 'true' ? Colors.red : Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        profile.disabled == 'true' ? 'Disabled' : 'Enabled',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    onTap: () {
                      // TODO: Navigate to profile details
                    },
                  ),
                );
              },
            ),
          );
        }

        // Initial/other state - show loading (data will be loaded by initState)
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}