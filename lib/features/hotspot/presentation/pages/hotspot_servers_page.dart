import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/hotspot_bloc.dart';
import '../bloc/hotspot_event.dart';
import '../bloc/hotspot_state.dart';

class HotspotServersPage extends StatefulWidget {
  const HotspotServersPage({super.key});

  @override
  State<HotspotServersPage> createState() => _HotspotServersPageState();
}

class _HotspotServersPageState extends State<HotspotServersPage> {
  @override
  void initState() {
    super.initState();
    context.read<HotspotBloc>().add(const LoadHotspotServers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HotSpot Servers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<HotspotBloc>().add(const LoadHotspotServers());
            },
          ),
        ],
      ),
      body: BlocBuilder<HotspotBloc, HotspotState>(
        builder: (context, state) {
          if (state is HotspotLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HotspotLoaded && state.servers != null) {
            final servers = state.servers!;

            if (servers.isEmpty) {
              return const Center(
                child: Text('No servers found'),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<HotspotBloc>().add(const LoadHotspotServers());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: servers.length,
                itemBuilder: (context, index) {
                  final server = servers[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            server.disabled ? Colors.grey : Colors.blue,
                        child: Icon(
                          server.disabled ? Icons.router_outlined : Icons.router,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        server.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Interface: ${server.interfaceName}'),
                          Text('Address Pool: ${server.addressPool}'),
                          if (server.profile != null)
                            Text('Profile: ${server.profile}'),
                          const SizedBox(height: 4),
                          Chip(
                            label: Text(
                              server.disabled ? 'Disabled' : 'Enabled',
                              style: const TextStyle(fontSize: 11),
                            ),
                            backgroundColor:
                                server.disabled ? Colors.red : Colors.green,
                            labelPadding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            visualDensity: VisualDensity.compact,
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
                Text(state is HotspotError
                    ? state.message
                    : 'Unable to load servers'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<HotspotBloc>().add(const LoadHotspotServers());
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
