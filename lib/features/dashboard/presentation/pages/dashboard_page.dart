import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../main.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const LoadDashboardData());
  }

  String _formatBytes(String bytes) {
    final value = int.tryParse(bytes) ?? 0;
    if (value < 1024) return '$value B';
    if (value < 1048576) return '${(value / 1024).toStringAsFixed(1)} KB';
    if (value < 1073741824) return '${(value / 1048576).toStringAsFixed(1)} MB';
    return '${(value / 1073741824).toStringAsFixed(2)} GB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              final currentLocale = Localizations.localeOf(context);
              final newLocale = currentLocale.languageCode == 'en'
                  ? const Locale('fa', '')
                  : const Locale('en', '');
              MyApp.of(context)?.setLocale(newLocale);
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              context.push(AppRoutes.about);
            },
            tooltip: 'About',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DashboardBloc>().add(const RefreshSystemResources());
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const LogoutRequested());
              context.go(AppRoutes.login);
            },
          ),
        ],
      ),
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          switch (state) {
            case DashboardLoaded(:final errorMessage?) when errorMessage.isNotEmpty:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMessage),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              context.read<DashboardBloc>().add(const ClearError());
            case DashboardLoaded():
              // No error message
              break;
            case DashboardError(:final message):
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: Colors.red,
                ),
              );
            case DashboardOperationSuccess(:final message):
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: Colors.green,
                ),
              );
            case DashboardInitial():
            case DashboardLoading():
            case DashboardOperationLoading():
              // No action needed
              break;
          }
        },
        builder: (context, state) {
          return switch (state) {
            DashboardLoading() => const Center(child: CircularProgressIndicator()),
            DashboardLoaded(:final systemResource) => RefreshIndicator(
                onRefresh: () async {
                  context.read<DashboardBloc>().add(const RefreshSystemResources());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // System Info Card (Full Width)
                      if (systemResource != null) ...[
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.router, color: theme.colorScheme.primary),
                                    const SizedBox(width: 8),
                                    Text(
                                      l10n.systemResources,
                                      style: theme.textTheme.titleLarge,
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                _buildInfoRow('Version', systemResource.version),
                                _buildInfoRow('Uptime', systemResource.uptime),
                                _buildInfoRow('Platform', systemResource.platform),
                                _buildInfoRow('Board', systemResource.boardName),
                                _buildInfoRow('Architecture', systemResource.architectureName),
                                const SizedBox(height: 16),
                                _buildProgressRow(
                                  'CPU Load',
                                  systemResource.cpuLoad,
                                  theme.colorScheme.primary,
                                ),
                                const SizedBox(height: 8),
                                _buildMemoryRow(
                                  'Memory',
                                  systemResource.freeMemory,
                                  systemResource.totalMemory,
                                  theme.colorScheme.secondary,
                                ),
                                const SizedBox(height: 8),
                                _buildMemoryRow(
                                  'Storage',
                                  systemResource.freeHddSpace,
                                  systemResource.totalHddSpace,
                                  Colors.orange,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Sectioned Dashboard Layout
                      _buildDashboardSection(
                        context,
                        l10n.networkManagement,
                        Icons.settings_ethernet,
                        Colors.blue,
                        [
                          _buildSectionCard(
                            context,
                            l10n.interfaces,
                            Icons.settings_ethernet,
                            Colors.blue.shade100,
                            () => context.push(AppRoutes.interfaces),
                          ),
                          _buildSectionCard(
                            context,
                            l10n.ipAddresses,
                            Icons.public,
                            Colors.green.shade100,
                            () => context.push(AppRoutes.ipAddresses),
                          ),
                          _buildSectionCard(
                            context,
                            l10n.dhcpServer,
                            Icons.dns,
                            Colors.purple.shade100,
                            () => context.push(AppRoutes.dhcp),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      _buildDashboardSection(
                        context,
                        l10n.securityAccess,
                        Icons.security,
                        Colors.red,
                        [
                          _buildSectionCard(
                            context,
                            l10n.firewall,
                            Icons.security,
                            Colors.red.shade100,
                            () => context.push(AppRoutes.firewall),
                          ),
                          _buildSectionCard(
                            context,
                            'HotSpot',
                            Icons.wifi,
                            Colors.orange.shade100,
                            () => context.push(AppRoutes.hotspot),
                          ),
                          _buildSectionCard(
                            context,
                            'Certificates',
                            Icons.verified_user,
                            Colors.indigo.shade100,
                            () => context.push(AppRoutes.certificates),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      _buildDashboardSection(
                        context,
                        l10n.monitoringTools,
                        Icons.monitor,
                        Colors.purple,
                        [
                          _buildSectionCard(
                            context,
                            'Network Tools',
                            Icons.build,
                            Colors.indigo.shade100,
                            () => context.push(AppRoutes.tools),
                          ),
                          _buildSectionCard(
                            context,
                            l10n.systemLogs,
                            Icons.article,
                            Colors.blueGrey.shade100,
                            () => context.push(AppRoutes.logs),
                          ),
                          _buildSectionCard(
                            context,
                            'Cloud',
                            Icons.cloud,
                            Colors.lightBlue.shade100,
                            () => context.push(AppRoutes.cloud),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      _buildDashboardSection(
                        context,
                        l10n.advancedFeatures,
                        Icons.settings,
                        Colors.teal,
                        [
                          _buildSectionCard(
                            context,
                            l10n.queues,
                            Icons.queue,
                            Colors.deepOrange.shade100,
                            () => context.push(AppRoutes.queues),
                          ),
                          _buildSectionCard(
                            context,
                            l10n.wirelessManagement,
                            Icons.wifi,
                            Colors.cyan.shade100,
                            () => context.push(AppRoutes.wireless),
                          ),
                          _buildSectionCard(
                            context,
                            'Backup & Restore',
                            Icons.backup,
                            Colors.amber.shade100,
                            () => context.push(AppRoutes.backup),
                          ),
                          _buildSectionCard(
                            context,
                            'Services',
                            Icons.dns,
                            Colors.teal.shade100,
                            () => context.push(AppRoutes.services),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            DashboardInitial() || DashboardError() || DashboardOperationSuccess() || DashboardOperationLoading() => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(l10n.error),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<DashboardBloc>().add(const LoadDashboardData());
                      },
                      child: Text(l10n.confirm),
                    ),
                  ],
                ),
              ),
          };
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

  Widget _buildMemoryRow(
    String label,
    String free,
    String total,
    Color color,
  ) {
    final freeBytes = int.tryParse(free) ?? 0;
    final totalBytes = int.tryParse(total) ?? 1;
    final usedBytes = totalBytes - freeBytes;
    final percentage = (usedBytes / totalBytes * 100).toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(
              '${_formatBytes(usedBytes.toString())} / ${_formatBytes(total)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: usedBytes / totalBytes,
          backgroundColor: color.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
        const SizedBox(height: 2),
        Text(
          '$percentage% used',
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildDashboardSection(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    List<Widget> cards,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.0,
          children: cards,
        ),
      ],
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color backgroundColor,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 1,
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
