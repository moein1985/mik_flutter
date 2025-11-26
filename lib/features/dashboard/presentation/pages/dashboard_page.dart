import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import 'interfaces_page.dart';
import 'ip_addresses_page.dart';
import 'firewall_rules_page.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('MikroTik Manager'),
        actions: [
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
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is DashboardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is DashboardOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DashboardLoaded) {
            final systemResource = state.systemResource;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(const RefreshSystemResources());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // System Info Card
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
                                    'System Information',
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
                      const SizedBox(height: 16),
                    ],

                    // Management Cards
                    Text(
                      'Management',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _buildManagementCard(
                          context,
                          'Interfaces',
                          Icons.settings_ethernet,
                          Colors.blue,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<DashboardBloc>(),
                                  child: const InterfacesPage(),
                                ),
                              ),
                            );
                          },
                        ),
                        _buildManagementCard(
                          context,
                          'IP Addresses',
                          Icons.public,
                          Colors.green,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<DashboardBloc>(),
                                  child: const IpAddressesPage(),
                                ),
                              ),
                            );
                          },
                        ),
                        _buildManagementCard(
                          context,
                          'Firewall',
                          Icons.security,
                          Colors.red,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<DashboardBloc>(),
                                  child: const FirewallRulesPage(),
                                ),
                              ),
                            );
                          },
                        ),
                        _buildManagementCard(
                          context,
                          'DHCP',
                          Icons.dns,
                          Colors.purple,
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('DHCP management coming soon')),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Unable to load dashboard'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<DashboardBloc>().add(const LoadDashboardData());
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
          backgroundColor: color.withOpacity(0.2),
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
          backgroundColor: color.withOpacity(0.2),
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

  Widget _buildManagementCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
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
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
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
