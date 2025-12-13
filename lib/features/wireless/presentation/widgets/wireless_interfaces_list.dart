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
      buildWhen: (previous, current) {
        // Only rebuild on interface-related states
        return current is WirelessInitial ||
               current is WirelessInterfacesLoading ||
               current is WirelessInterfacesLoaded ||
               current is WirelessInterfacesError;
      },
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
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row with icon, SSID, and actions
                        Row(
                          children: [
                            // Large WiFi icon with signal strength indicator
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: interface.disabled ? Colors.grey.shade200 : Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Icon(
                                Icons.wifi,
                                color: interface.disabled ? Colors.grey : Colors.blue,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // SSID prominently displayed
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    interface.ssid ?? 'No SSID',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    interface.name ?? 'Unknown Interface',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Client count badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.people, size: 16, color: Colors.green.shade700),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${interface.clients}',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Band/Channel info with help icon
                        Row(
                          children: [
                            Icon(Icons.settings_input_antenna, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              '${interface.band ?? 'Unknown'} - ${interface.frequency ?? 'N/A'} MHz',
                              style: const TextStyle(fontSize: 14),
                            ),
                            IconButton(
                              icon: Icon(Icons.help_outline, size: 16, color: Colors.grey.shade600),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => _showFrequencyHelp(context),
                              tooltip: 'What is frequency band?',
                            ),
                            const Spacer(),
                            // Status indicator
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: interface.disabled ? Colors.red.shade100 : Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                interface.disabled ? 'Disabled' : 'Enabled',
                                style: TextStyle(
                                  color: interface.disabled ? Colors.red.shade700 : Colors.green.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Bottom row with toggle and settings
                        Row(
                          children: [
                            // Enable/Disable toggle switch
                            Text(
                              interface.disabled ? 'Disabled' : 'Enabled',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 8),
                            Switch(
                              value: !interface.disabled,
                              onChanged: (value) {
                                if (value) {
                                  context.read<WirelessBloc>().add(EnableWirelessInterface(interface.id));
                                } else {
                                  context.read<WirelessBloc>().add(DisableWirelessInterface(interface.id));
                                }
                              },
                            ),
                            const Spacer(),
                            // Settings/Edit icon button
                            IconButton(
                              icon: const Icon(Icons.settings),
                              onPressed: () {
                                // TODO: Navigate to interface settings
                              },
                              tooltip: 'Settings',
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

        // Initial/other state - show loading (data will be loaded by initState)
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  void _showFrequencyHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.settings_input_antenna, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('Frequency Bands'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '2.4 GHz Band',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 4),
              Text('• Better range and wall penetration\n'
                   '• More interference from other devices\n'
                   '• Lower maximum speed\n'
                   '• Channels: 1-13 (2412-2472 MHz)'),
              SizedBox(height: 12),
              Text(
                '5 GHz Band',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 4),
              Text('• Higher speeds possible\n'
                   '• Less interference\n'
                   '• Shorter range\n'
                   '• More channels available'),
              SizedBox(height: 12),
              Text(
                'Frequency (MHz)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 4),
              Text('The specific channel frequency in megahertz. '
                   'Different channels reduce interference between nearby networks.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}