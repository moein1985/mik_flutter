import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/router/app_router.dart';
import '../blocs/dashboard_bloc.dart';
import '../blocs/dashboard_event.dart';
import '../blocs/dashboard_state.dart';
import '../widgets/modern_card.dart';
import '../widgets/quick_tip_card.dart';

/// Asterisk PBX Dashboard Page
/// 
/// Main dashboard for Asterisk PBX module showing:
/// - Live system statistics
/// - Active calls monitoring
/// - Extension status
/// - Queue information
/// - System resources
class AsteriskDashboardPage extends StatefulWidget {
  const AsteriskDashboardPage({super.key});

  @override
  State<AsteriskDashboardPage> createState() => _AsteriskDashboardPageState();
}

class _AsteriskDashboardPageState extends State<AsteriskDashboardPage> {
  DashboardBloc? _bloc;
  Timer? _refreshTimer;
  bool _autoRefreshEnabled = true;
  final int _refreshSeconds = 30;
  bool _checkingConfig = true;

  @override
  void initState() {
    super.initState();
    _checkConfigAndInit();
  }

  Future<void> _checkConfigAndInit() async {
    // Check if Asterisk is configured
    try {
      final prefs = await SharedPreferences.getInstance();
      final isConfigured = prefs.getBool('asterisk_configured') ?? false;
      
      if (!isConfigured && mounted) {
        // Redirect to login/setup page
        context.go(AppRoutes.asteriskLogin);
        return;
      }
    } catch (e) {
      // On error, proceed to show dashboard (will fail gracefully)
    }
    
    if (mounted) {
      setState(() => _checkingConfig = false);
      _initBloc();
    }
  }

  void _initBloc() {
    final bloc = GetIt.instance<DashboardBloc>();
    setState(() => _bloc = bloc);
    bloc.add(LoadDashboard());
    _startTimer();
  }

  void _startTimer() {
    _refreshTimer?.cancel();
    if (_autoRefreshEnabled && _bloc != null) {
      _refreshTimer = Timer.periodic(
        Duration(seconds: _refreshSeconds),
        (_) => _bloc!.add(RefreshDashboard()),
      );
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _bloc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking config
    if (_checkingConfig) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bloc = _bloc;

    if (bloc == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocProvider.value(
      value: bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Asterisk PBX Dashboard'),
          backgroundColor: const Color(0xFFFF6600),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => context.push(AppRoutes.asteriskLogin),
              tooltip: 'تنظیمات اتصال',
            ),
            IconButton(
              icon: Icon(_autoRefreshEnabled ? Icons.sync : Icons.sync_disabled),
              onPressed: () {
                setState(() {
                  _autoRefreshEnabled = !_autoRefreshEnabled;
                  if (_autoRefreshEnabled) {
                    _startTimer();
                  } else {
                    _refreshTimer?.cancel();
                  }
                });
              },
              tooltip: _autoRefreshEnabled ? 'Disable Auto Refresh' : 'Enable Auto Refresh',
            ),
          ],
        ),
        body: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            final isLoading = state is DashboardLoading;

            return Stack(
              children: [
                switch (state) {
                  DashboardInitial() => const SizedBox.shrink(),
                  DashboardLoading() => const Center(child: CircularProgressIndicator()),
                  DashboardLoaded() => RefreshIndicator(
                    onRefresh: () async => bloc.add(RefreshDashboard()),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // System Resources Card
                          if (state.systemResource != null) ...[
                            _buildSystemResourcesCard(context, state),
                            const SizedBox(height: 24),
                          ],
                          // Quick Tip
                          const QuickTipCard(
                            tip: 'Swipe down to refresh data. Auto-refresh updates every 30 seconds.',
                          ),
                          const SizedBox(height: 16),
                          // Stats Grid
                          _buildStatsGrid(context, state),
                          const SizedBox(height: 24),
                          // Recent Calls
                          _buildRecentCallsSection(context, state),
                        ],
                      ),
                    ),
                  ),
                  DashboardError() => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => bloc.add(LoadDashboard()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                },
                if (isLoading)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSystemResourcesCard(BuildContext context, DashboardLoaded state) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.router, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'System Resources',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Version', state.systemResource!.version),
            _buildInfoRow('Uptime', state.systemResource!.uptime),
            _buildInfoRow('Platform', state.systemResource!.platform),
            const SizedBox(height: 16),
            _buildProgressRow(
              'CPU Load',
              state.systemResource!.cpuLoad,
              Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, DashboardLoaded state) {
    final stats = state.stats;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.bar_chart, size: 24),
            const SizedBox(width: 8),
            const Text('Overall Stats', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Spacer(),
            Text(
              'Updated: ${_formatTime(stats.lastUpdate)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              'Extensions',
              '${stats.onlineExtensions}/${stats.totalExtensions}',
              'online',
              Icons.phone,
              Colors.blue,
            ),
            _buildStatCard(
              'Active Calls',
              '${stats.activeCalls}',
              'calls',
              Icons.call,
              Colors.green,
            ),
            _buildStatCard(
              'Queues',
              '${stats.queuedCalls}',
              'waiting',
              Icons.queue,
              Colors.orange,
            ),
            _buildStatCard(
              'Avg Wait',
              stats.averageWaitTime.toStringAsFixed(1),
              'seconds',
              Icons.timer,
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, Color color) {
    return ModernCard(
      backgroundColor: color.withValues(alpha: 0.1),
      borderColor: color.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentCallsSection(BuildContext context, DashboardLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.phone_in_talk, size: 24),
                SizedBox(width: 8),
                Text('Recent Calls', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to calls page
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (state.recentCalls.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('No active calls', style: TextStyle(color: Colors.grey)),
              ),
            ),
          )
        else
          ...state.recentCalls.map((call) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.call, color: Colors.white, size: 20),
                  ),
                  title: Text('${call.caller} ➜ ${call.callee}'),
                  subtitle: Text(call.channel),
                  trailing: Text(
                    call.duration,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )),
      ],
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String label, String percentage, Color color) {
    final value = double.tryParse(percentage) ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text('$percentage%'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: color.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }
}
