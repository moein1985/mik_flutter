import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/router/app_router.dart';
import '../bloc/hotspot_bloc.dart';
import '../bloc/hotspot_event.dart';
import '../bloc/hotspot_state.dart';
import 'hotspot_setup_dialog.dart';
import 'hotspot_reset_dialog.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('HotSpot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'About HotSpot',
            onPressed: () => _showHotspotInfo(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
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
          
          return switch (state) {
            HotspotLoading() => _lastServerCount > 0
                ? Stack(
                    children: [
                      _buildMainContent(context, colorScheme, _lastServerCount),
                      const Center(child: CircularProgressIndicator()),
                    ],
                  )
                : const Center(child: CircularProgressIndicator()),
            HotspotPackageDisabled() => _buildPackageDisabledView(context, colorScheme),
            HotspotError(:final message) => message.contains('trap')
                ? _buildPackageDisabledView(context, colorScheme)
                : _lastServerCount > 0
                    ? _buildMainContent(context, colorScheme, _lastServerCount)
                    : _buildErrorView(context, colorScheme, message),
            HotspotLoaded(:final servers) => () {
                _log.i('HotspotLoaded with ${servers?.length ?? 0} servers');
                final serverList = servers ?? [];
                _lastServerCount = serverList.length;
                return serverList.isEmpty
                    ? _buildNoHotspotView(context, colorScheme)
                    : _buildMainContent(context, colorScheme, serverList.length);
              }(),
            HotspotOperationSuccess() => _lastServerCount > 0
                ? _buildMainContent(context, colorScheme, _lastServerCount)
                : const Center(child: CircularProgressIndicator()),
            HotspotSetupDataLoaded() => _lastServerCount > 0
                ? _buildMainContent(context, colorScheme, _lastServerCount)
                : _buildNoHotspotView(context, colorScheme),
            HotspotResetInProgress() => _lastServerCount > 0
                ? _buildMainContent(context, colorScheme, _lastServerCount)
                : const Center(child: CircularProgressIndicator()),
            HotspotResetSuccess() => _lastServerCount > 0
                ? _buildMainContent(context, colorScheme, _lastServerCount)
                : _buildNoHotspotView(context, colorScheme),
            HotspotInitial() => () {
                _log.d('HotspotPage initial state, showing grid');
                return _buildMainContent(context, colorScheme, 0);
              }(),
          };
        },
      ),
    );
  }

  Widget _buildNoHotspotView(BuildContext context, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Quick Tip Card
          _buildQuickTipCard(colorScheme),
          
          const SizedBox(height: 48),
          
          // No HotSpot Content
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withAlpha(77),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.wifi_off,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'HotSpot is not configured',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No HotSpot server found on this router.',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => _showSetupDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Setup HotSpot'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageDisabledView(BuildContext context, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Warning Tip Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'The HotSpot package needs to be enabled to use this feature.',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 48),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.extension_off,
              size: 64,
              color: Colors.orange.shade700,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'HotSpot Package Disabled',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Please enable it from System → Packages in WinBox or WebFig.',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
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

  Widget _buildErrorView(BuildContext context, ColorScheme colorScheme, String message) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 48),
          
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
          const SizedBox(height: 24),
          Text(
            'Error loading HotSpot',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
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

  Widget _buildQuickTipCard(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_tethering, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Manage your HotSpot configuration, users, and connected devices.',
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

  Widget _buildStatusBanner(ColorScheme colorScheme, int serverCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, color: Colors.green.shade700, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HotSpot Active',
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '$serverCount server${serverCount > 1 ? 's' : ''} configured',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Status dot
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

  Widget _buildMainContent(BuildContext context, ColorScheme colorScheme, int serverCount) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Quick Tip Card
          _buildQuickTipCard(colorScheme),
          
          const SizedBox(height: 16),
          
          // Status Banner (only if servers configured)
          if (serverCount > 0) ...[
            _buildStatusBanner(colorScheme, serverCount),
            const SizedBox(height: 20),
          ],
          
          // Section Title
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'HotSpot Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          
          // HotSpot Grid
          _buildHotspotGrid(context, colorScheme),
        ],
      ),
    );
  }

  Widget _buildHotspotGrid(BuildContext context, ColorScheme colorScheme) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        _buildCard(
          context,
          colorScheme: colorScheme,
          icon: Icons.people,
          title: 'Users',
          subtitle: 'Manage hotspot users',
          color: Colors.blue,
          onTap: () => context.push(
            AppRoutes.hotspotUsers,
            extra: context.read<HotspotBloc>(),
          ),
        ),
        _buildCard(
          context,
          colorScheme: colorScheme,
          icon: Icons.person,
          title: 'Active Users',
          subtitle: 'Online users',
          color: Colors.green,
          onTap: () => context.push(
            AppRoutes.hotspotActiveUsers,
            extra: context.read<HotspotBloc>(),
          ),
        ),
        _buildCard(
          context,
          colorScheme: colorScheme,
          icon: Icons.router,
          title: 'Servers',
          subtitle: 'HotSpot servers',
          color: Colors.orange,
          onTap: () => context.push(
            AppRoutes.hotspotServers,
            extra: context.read<HotspotBloc>(),
          ),
        ),
        _buildCard(
          context,
          colorScheme: colorScheme,
          icon: Icons.settings,
          title: 'Profiles',
          subtitle: 'User profiles',
          color: Colors.purple,
          onTap: () => context.push(
            AppRoutes.hotspotProfiles,
            extra: context.read<HotspotBloc>(),
          ),
        ),
        _buildCard(
          context,
          colorScheme: colorScheme,
          icon: Icons.link,
          title: 'IP Bindings',
          subtitle: 'MAC/IP bindings',
          color: Colors.indigo,
          onTap: () => context.push(
            AppRoutes.hotspotIpBindings,
            extra: context.read<HotspotBloc>(),
          ),
        ),
        _buildCard(
          context,
          colorScheme: colorScheme,
          icon: Icons.devices_other,
          title: 'Hosts',
          subtitle: 'Connected devices',
          color: Colors.cyan,
          onTap: () => context.push(
            AppRoutes.hotspotHosts,
            extra: context.read<HotspotBloc>(),
          ),
        ),
        _buildCard(
          context,
          colorScheme: colorScheme,
          icon: Icons.fence,
          title: 'Walled Garden',
          subtitle: 'Allowed sites',
          color: Colors.teal,
          onTap: () => context.push(
            AppRoutes.hotspotWalledGarden,
            extra: context.read<HotspotBloc>(),
          ),
        ),
        // Reset HotSpot Card
        _buildCard(
          context,
          colorScheme: colorScheme,
          icon: Icons.delete_forever,
          title: 'Reset HotSpot',
          subtitle: 'Remove & rebuild',
          color: Colors.red,
          onTap: () => _showResetDialog(context),
        ),
      ],
    );
  }

  void _showResetDialog(BuildContext context) {
    final bloc = context.read<HotspotBloc>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: bloc,
          child: const HotspotResetDialog(),
        );
      },
    ).then((result) {
      if (result == true && mounted) {
        // Reload servers after successful reset
        bloc.add(const LoadHotspotServers());
      }
    });
  }

  Widget _buildCard(
    BuildContext context, {
    required ColorScheme colorScheme,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withAlpha(51)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with colored background
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHotspotInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.wifi_tethering, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            const Text('HotSpot Features'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoItem(
                title: 'Users',
                description: 'Create and manage HotSpot user accounts with credentials.',
              ),
              _InfoItem(
                title: 'Active Users',
                description: 'View currently connected users and their session details.',
              ),
              _InfoItem(
                title: 'Servers',
                description: 'Configure HotSpot servers on different interfaces.',
              ),
              _InfoItem(
                title: 'Profiles',
                description: 'Set bandwidth limits, session timeouts, and shared users.',
              ),
              _InfoItem(
                title: 'IP Bindings',
                description: 'Bypass authentication for specific MAC/IP addresses.',
              ),
              _InfoItem(
                title: 'Hosts',
                description: 'View all devices that have connected to the HotSpot.',
              ),
              _InfoItem(
                title: 'Walled Garden',
                description: 'Allow access to specific sites without authentication.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String title;
  final String description;

  const _InfoItem({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
