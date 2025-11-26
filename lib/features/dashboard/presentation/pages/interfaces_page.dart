import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';

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
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isActive ? Colors.green : Colors.grey,
                        child: Icon(
                          Icons.settings_ethernet,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        interface.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Type: ${interface.type}'),
                          if (interface.macAddress != null)
                            Text('MAC: ${interface.macAddress}'),
                          if (interface.comment != null)
                            Text('Comment: ${interface.comment}'),
                          const SizedBox(height: 4),
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
                            ],
                          ),
                        ],
                      ),
                      trailing: Switch(
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
