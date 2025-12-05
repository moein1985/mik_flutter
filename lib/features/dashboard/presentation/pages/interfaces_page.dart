import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../auth/data/datasources/auth_remote_data_source.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import 'interface_monitoring_page.dart';

class InterfacesPage extends StatefulWidget {
  const InterfacesPage({super.key});

  @override
  State<InterfacesPage> createState() => _InterfacesPageState();
}

class _InterfacesPageState extends State<InterfacesPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const LoadInterfaces());
  }

  void _openMonitoring(BuildContext context, String interfaceName) {
    final authDataSource = GetIt.instance<AuthRemoteDataSource>();
    final client = authDataSource.client;

    if (client == null || !client.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not connected to router'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InterfaceMonitoringPage(
          interfaceName: interfaceName,
          client: client,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interfaces'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DashboardBloc>().add(const LoadInterfaces());
            },
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DashboardLoaded && state.interfaces != null) {
            final interfaces = state.interfaces!;

            if (interfaces.isEmpty) {
              return const Center(
                child: Text('No interfaces found'),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(const LoadInterfaces());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: interfaces.length,
                itemBuilder: (context, index) {
                  final interface = interfaces[index];
                  final isActive = interface.running && !interface.disabled;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header row with icon, name, and switch
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: isActive ? Colors.green : Colors.grey,
                                radius: 20,
                                child: const Icon(
                                  Icons.settings_ethernet,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      interface.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'Type: ${interface.type}',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: !interface.disabled,
                                onChanged: (value) {
                                  context.read<DashboardBloc>().add(
                                        ToggleInterface(
                                          id: interface.id,
                                          enable: value,
                                        ),
                                      );
                                },
                              ),
                            ],
                          ),

                          // Details
                          if (interface.macAddress != null || interface.comment != null) ...[
                            const SizedBox(height: 8),
                            if (interface.macAddress != null)
                              Text(
                                'MAC: ${interface.macAddress}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            if (interface.comment != null)
                              Text(
                                'Comment: ${interface.comment}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                          ],

                          const SizedBox(height: 8),

                          // Status chips and Monitor button row
                          Row(
                            children: [
                              if (interface.running)
                                const Chip(
                                  label: Text('Running', style: TextStyle(fontSize: 11)),
                                  backgroundColor: Colors.green,
                                  labelPadding: EdgeInsets.symmetric(horizontal: 4),
                                  visualDensity: VisualDensity.compact,
                                ),
                              if (!interface.running)
                                const Chip(
                                  label: Text('Stopped', style: TextStyle(fontSize: 11)),
                                  backgroundColor: Colors.grey,
                                  labelPadding: EdgeInsets.symmetric(horizontal: 4),
                                  visualDensity: VisualDensity.compact,
                                ),
                              const SizedBox(width: 4),
                              if (interface.disabled)
                                const Chip(
                                  label: Text('Disabled', style: TextStyle(fontSize: 11)),
                                  backgroundColor: Colors.red,
                                  labelPadding: EdgeInsets.symmetric(horizontal: 4),
                                  visualDensity: VisualDensity.compact,
                                ),
                              const Spacer(),
                              // Monitor button
                              OutlinedButton.icon(
                                onPressed: () => _openMonitoring(context, interface.name),
                                icon: const Icon(Icons.show_chart, size: 16),
                                label: const Text('Monitor'),
                                style: OutlinedButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
                Text(state is DashboardError ? state.message : 'Unable to load interfaces'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<DashboardBloc>().add(const LoadInterfaces());
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
}
