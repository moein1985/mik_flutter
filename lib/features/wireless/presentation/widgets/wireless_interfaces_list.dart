import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/wireless_bloc.dart';
import '../bloc/wireless_event.dart';
import '../bloc/wireless_state.dart';

class WirelessInterfacesList extends StatefulWidget {
  const WirelessInterfacesList({super.key});

  @override
  State<WirelessInterfacesList> createState() => _WirelessInterfacesListState();
}

class _WirelessInterfacesListState extends State<WirelessInterfacesList> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Load data only once when widget is first created
    Future.microtask(() {
      if (mounted) {
        context.read<WirelessBloc>().add(const LoadWirelessInterfaces());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return BlocBuilder<WirelessBloc, WirelessState>(
      builder: (context, state) {
        if (state is WirelessInterfacesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is WirelessInterfacesError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<WirelessBloc>().add(const LoadWirelessInterfaces());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is WirelessInterfacesLoaded) {
          if (state.interfaces.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('No wireless interfaces found'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<WirelessBloc>().add(const LoadWirelessInterfaces());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.interfaces.length,
              itemBuilder: (context, index) {
                final interface = state.interfaces[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(
                      interface.disabled == 'true' ? Icons.wifi_off : Icons.wifi,
                      color: interface.disabled == 'true' ? Colors.grey : Colors.blue,
                    ),
                    title: Text(interface.name ?? 'Unknown'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SSID: ${interface.ssid ?? 'N/A'}'),
                        Text('Band: ${interface.band ?? 'N/A'}'),
                        Text('Frequency: ${interface.frequency ?? 'N/A'} MHz'),
                        if (interface.txPower != null)
                          Text('TX Power: ${interface.txPower} dBm'),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: interface.disabled == 'true' ? Colors.red : Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        interface.disabled == 'true' ? 'Disabled' : 'Enabled',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    onTap: () {
                      // TODO: Navigate to interface details
                    },
                  ),
                );
              },
            ),
          );
        }

        // Initial state - load data
        context.read<WirelessBloc>().add(const LoadWirelessInterfaces());
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}