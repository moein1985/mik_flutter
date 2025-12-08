import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/wireless_bloc.dart';
import '../bloc/wireless_event.dart';
import '../bloc/wireless_state.dart';

class WirelessClientsList extends StatefulWidget {
  const WirelessClientsList({super.key});

  @override
  State<WirelessClientsList> createState() => _WirelessClientsListState();
}

class _WirelessClientsListState extends State<WirelessClientsList> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Load data only once when widget is first created
    Future.microtask(() {
      if (mounted) {
        context.read<WirelessBloc>().add(const LoadWirelessRegistrations());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return BlocBuilder<WirelessBloc, WirelessState>(
      builder: (context, state) {
        if (state is WirelessRegistrationsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is WirelessRegistrationsError) {
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
                    context.read<WirelessBloc>().add(const LoadWirelessRegistrations());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is WirelessRegistrationsLoaded) {
          if (state.registrations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.devices, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('No connected clients found'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<WirelessBloc>().add(const LoadWirelessRegistrations());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.registrations.length,
              itemBuilder: (context, index) {
                final registration = state.registrations[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.device_hub, color: Colors.green),
                    title: Text(registration.macAddress ?? 'Unknown MAC'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Interface: ${registration.interface ?? 'N/A'}'),
                        Text('Uptime: ${registration.uptime ?? 'N/A'}'),
                        Text('TX/RX Rate: ${registration.txRate ?? 'N/A'} / ${registration.rxRate ?? 'N/A'}'),
                        if (registration.signalStrength != null)
                          Text('Signal: ${registration.signalStrength} dBm'),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Connected',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    onTap: () {
                      // TODO: Navigate to client details
                    },
                  ),
                );
              },
            ),
          );
        }

        // Initial state - load data
        context.read<WirelessBloc>().add(const LoadWirelessRegistrations());
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}