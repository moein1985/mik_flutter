import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../bloc/hotspot_bloc.dart';
import '../bloc/hotspot_event.dart';
import '../bloc/hotspot_state.dart';
import 'hotspot_users_page.dart';
import 'hotspot_active_users_page.dart';
import 'hotspot_servers_page.dart';
import 'hotspot_profiles_page.dart';
import 'hotspot_setup_dialog.dart';
import 'hotspot_ip_bindings_page.dart';
import 'hotspot_hosts_page.dart';
import 'hotspot_walled_garden_page.dart';

final _log = AppLogger.tag('HotspotPage');

class HotspotPage extends StatefulWidget {
  const HotspotPage({super.key});

  @override
  State<HotspotPage> createState() => _HotspotPageState();
}

class _HotspotPageState extends State<HotspotPage> {
  // Track if we've shown an error/success message to avoid duplicates
  String? _lastShownMessage;
  // Cache the last known server count for smooth UI
  int _lastServerCount = 0;
  
  @override
  void initState() {
    super.initState();
    _log.i('HotspotPage initState - Loading servers');
    // Check HotSpot status by loading servers
    context.read<HotspotBloc>().add(const LoadHotspotServers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HotSpot Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _log.i('Refresh button pressed');
              context.read<HotspotBloc>().add(const LoadHotspotServers());
            },
          ),
        ],
      ),
      body: BlocConsumer<HotspotBloc, HotspotState>(
        listener: (context, state) {
          _log.i('HotspotPage state changed: ${state.runtimeType}');
          
          // Update cached server count
          if (state is HotspotLoaded && state.servers != null) {
            _lastServerCount = state.servers!.length;
          }
          
          if (state is HotspotError) {
            // Only show if this is a new message
            if (_lastShownMessage != state.message) {
              _lastShownMessage = state.message;
              _log.e('HotspotPage error: ${state.message}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } else if (state is HotspotOperationSuccess) {
            // Only show if this is a new message
            if (_lastShownMessage != state.message) {
              _lastShownMessage = state.message;
              _log.i('HotspotPage success: ${state.message}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            // Reset message tracking for other states
            _lastShownMessage = null;
          }
        },
        builder: (context, state) {
          _log.d('HotspotPage building with state: ${state.runtimeType}');
          
          if (state is HotspotLoading) {
            // Show loading but keep the UI stable if we have cached data
            if (_lastServerCount > 0) {
              return Stack(
                children: [
                  _buildHotspotGrid(context, _lastServerCount),
                  const Center(child: CircularProgressIndicator()),
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is HotspotPackageDisabled) {
            return _buildPackageDisabledView(context);
          }
          
          if (state is HotspotError) {
            // Check if error is related to trap (package disabled)
            if (state.message.contains('trap')) {
              return _buildPackageDisabledView(context);
            }
            // Keep showing the grid if we have servers, just show the error via snackbar
            if (_lastServerCount > 0) {
              return _buildHotspotGrid(context, _lastServerCount);
            }
            return _buildErrorView(context, state.message);
          }
          
          if (state is HotspotLoaded) {
            final servers = state.servers ?? [];
            _log.i('HotspotLoaded with ${servers.length} servers');
            _lastServerCount = servers.length;
            if (servers.isEmpty) {
              return _buildNoHotspotView(context);
            }
            return _buildHotspotGrid(context, servers.length);
          }
          
          // HotspotOperationSuccess - keep showing the last known state
          if (state is HotspotOperationSuccess) {
            if (_lastServerCount > 0) {
              return _buildHotspotGrid(context, _lastServerCount);
            }
            // Will be updated after LoadHotspotServers completes
            return const Center(child: CircularProgressIndicator());
          }
          
          // HotspotSetupDataLoaded - this is for dialog, main page continues with last known state
          if (state is HotspotSetupDataLoaded) {
            if (_lastServerCount > 0) {
              return _buildHotspotGrid(context, _lastServerCount);
            }
            return _buildNoHotspotView(context);
          }
          
          // Initial state
          _log.d('HotspotPage initial state, showing grid');
          return _buildHotspotGrid(context, 0);
        },
      ),
    );
  }

  Widget _buildNoHotspotView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'HotSpot is not configured',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            'No HotSpot server found on this router.',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showSetupDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Setup HotSpot'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageDisabledView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.orange[400],
          ),
          const SizedBox(height: 24),
          Text(
            'HotSpot Package Disabled',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'The HotSpot package is disabled on your router. '
              'Please enable it from System → Packages in WinBox or WebFig.',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              context.read<HotspotBloc>().add(const CheckHotspotPackage());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Check Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading HotSpot',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<HotspotBloc>().add(const LoadHotspotServers());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showSetupDialog(BuildContext context) {
    final bloc = context.read<HotspotBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: bloc,
          child: const HotspotSetupDialog(),
        );
      },
    ).then((result) {
      if (result == true && mounted) {
        // Reload servers after successful setup
        bloc.add(const LoadHotspotServers());
      }
    });
  }

  Widget _buildHotspotGrid(BuildContext context, int serverCount) {
    return Column(
      children: [
        if (serverCount > 0)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.green[50],
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[700]),
                const SizedBox(width: 12),
                Text(
                  '$serverCount HotSpot server(s) configured',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
              _buildCard(
                context,
                icon: Icons.people,
                title: 'Users',
                subtitle: 'Manage hotspot users',
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<HotspotBloc>(),
                        child: const HotspotUsersPage(),
                      ),
                    ),
                  );
                },
              ),
              _buildCard(
                context,
                icon: Icons.person,
                title: 'Active Users',
                subtitle: 'Online users',
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<HotspotBloc>(),
                        child: const HotspotActiveUsersPage(),
                      ),
                    ),
                  );
                },
              ),
              _buildCard(
                context,
                icon: Icons.router,
                title: 'Servers',
                subtitle: 'HotSpot servers',
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<HotspotBloc>(),
                        child: const HotspotServersPage(),
                      ),
                    ),
                  );
                },
              ),
              _buildCard(
                context,
                icon: Icons.settings,
                title: 'Profiles',
                subtitle: 'User profiles',
                color: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<HotspotBloc>(),
                        child: const HotspotProfilesPage(),
                      ),
                    ),
                  );
                },
              ),
              _buildCard(
                context,
                icon: Icons.link,
                title: 'IP Bindings',
                subtitle: 'MAC/IP bindings',
                color: Colors.indigo,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<HotspotBloc>(),
                        child: const HotspotIpBindingsPage(),
                      ),
                    ),
                  );
                },
              ),
              _buildCard(
                context,
                icon: Icons.devices_other,
                title: 'Hosts',
                subtitle: 'Connected devices',
                color: Colors.cyan,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<HotspotBloc>(),
                        child: const HotspotHostsPage(),
                      ),
                    ),
                  );
                },
              ),
              _buildCard(
                context,
                icon: Icons.fence,
                title: 'Walled Garden',
                subtitle: 'Allowed sites',
                color: Colors.teal,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<HotspotBloc>(),
                        child: const HotspotWalledGardenPage(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
