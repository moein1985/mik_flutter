import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';

class IpAddressesPage extends StatefulWidget {
  const IpAddressesPage({super.key});

  @override
  State<IpAddressesPage> createState() => _IpAddressesPageState();
}

class _IpAddressesPageState extends State<IpAddressesPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const LoadIpAddresses());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IP Addresses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DashboardBloc>().add(const LoadIpAddresses());
            },
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DashboardLoaded && state.ipAddresses != null) {
            final ipAddresses = state.ipAddresses!;

            if (ipAddresses.isEmpty) {
              return const Center(
                child: Text('No IP addresses found'),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(const LoadIpAddresses());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: ipAddresses.length,
                itemBuilder: (context, index) {
                  final ip = ipAddresses[index];
                  final isActive = !ip.disabled && !ip.invalid;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isActive ? Colors.blue : Colors.grey,
                        child: const Icon(
                          Icons.public,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        ip.address,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Interface: ${ip.interfaceName}'),
                          Text('Network: ${ip.network}'),
                          if (ip.comment != null && ip.comment!.isNotEmpty)
                            Text('Comment: ${ip.comment}'),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 4,
                            children: [
                              if (ip.dynamic)
                                const Chip(
                                  label: Text('Dynamic', style: TextStyle(fontSize: 11)),
                                  backgroundColor: Colors.orange,
                                  labelPadding: EdgeInsets.symmetric(horizontal: 4),
                                  visualDensity: VisualDensity.compact,
                                ),
                              if (ip.disabled)
                                const Chip(
                                  label: Text('Disabled', style: TextStyle(fontSize: 11)),
                                  backgroundColor: Colors.red,
                                  labelPadding: EdgeInsets.symmetric(horizontal: 4),
                                  visualDensity: VisualDensity.compact,
                                ),
                              if (ip.invalid)
                                const Chip(
                                  label: Text('Invalid', style: TextStyle(fontSize: 11)),
                                  backgroundColor: Colors.grey,
                                  labelPadding: EdgeInsets.symmetric(horizontal: 4),
                                  visualDensity: VisualDensity.compact,
                                ),
                            ],
                          ),
                        ],
                      ),
                      isThreeLine: true,
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
                const Text('Unable to load IP addresses'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<DashboardBloc>().add(const LoadIpAddresses());
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
