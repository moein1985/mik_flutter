import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';

class FirewallRulesPage extends StatefulWidget {
  const FirewallRulesPage({super.key});

  @override
  State<FirewallRulesPage> createState() => _FirewallRulesPageState();
}

class _FirewallRulesPageState extends State<FirewallRulesPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const LoadFirewallRules());
  }

  String _formatBytes(int? bytes) {
    if (bytes == null) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1073741824) return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    return '${(bytes / 1073741824).toStringAsFixed(2)} GB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firewall Rules'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DashboardBloc>().add(const LoadFirewallRules());
            },
          ),
        ],
      ),
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is DashboardLoaded && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.read<DashboardBloc>().add(const ClearError());
          }
          if (state is DashboardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DashboardLoaded && state.firewallRules != null) {
            final rules = state.firewallRules!;

            if (rules.isEmpty) {
              return const Center(
                child: Text('No firewall rules found'),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(const LoadFirewallRules());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: rules.length,
                itemBuilder: (context, index) {
                  final rule = rules[index];
                  final isActive = !rule.disabled && !rule.invalid;

                  Color getActionColor() {
                    switch (rule.action.toLowerCase()) {
                      case 'accept':
                        return Colors.green;
                      case 'drop':
                      case 'reject':
                        return Colors.red;
                      default:
                        return Colors.orange;
                    }
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: isActive ? getActionColor() : Colors.grey,
                        child: const Icon(
                          Icons.security,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${rule.chain} / ${rule.action}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Switch(
                            value: !rule.disabled,
                            onChanged: (value) {
                              context.read<DashboardBloc>().add(
                                    ToggleFirewallRule(
                                      id: rule.id,
                                      enable: value,
                                    ),
                                  );
                            },
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (rule.comment != null && rule.comment!.isNotEmpty)
                            Text(rule.comment!),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 4,
                            children: [
                              if (rule.dynamic)
                                const Chip(
                                  label: Text('Dynamic', style: TextStyle(fontSize: 10)),
                                  backgroundColor: Colors.blue,
                                  labelPadding: EdgeInsets.symmetric(horizontal: 4),
                                  visualDensity: VisualDensity.compact,
                                ),
                              if (rule.disabled)
                                const Chip(
                                  label: Text('Disabled', style: TextStyle(fontSize: 10)),
                                  backgroundColor: Colors.grey,
                                  labelPadding: EdgeInsets.symmetric(horizontal: 4),
                                  visualDensity: VisualDensity.compact,
                                ),
                              if (rule.invalid)
                                const Chip(
                                  label: Text('Invalid', style: TextStyle(fontSize: 10)),
                                  backgroundColor: Colors.red,
                                  labelPadding: EdgeInsets.symmetric(horizontal: 4),
                                  visualDensity: VisualDensity.compact,
                                ),
                            ],
                          ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (rule.srcAddress != null)
                                _buildDetailRow('Source', rule.srcAddress!),
                              if (rule.dstAddress != null)
                                _buildDetailRow('Destination', rule.dstAddress!),
                              if (rule.protocol != null)
                                _buildDetailRow('Protocol', rule.protocol!),
                              if (rule.dstPort != null)
                                _buildDetailRow('Dst Port', rule.dstPort!),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      const Text(
                                        'Packets',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        '${rule.packets ?? 0}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Text(
                                        'Bytes',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        _formatBytes(rule.bytes),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
                const Text('Unable to load firewall rules'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<DashboardBloc>().add(const LoadFirewallRules());
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
