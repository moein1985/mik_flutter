import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/wireless_bloc.dart';
import '../bloc/wireless_event.dart';
import '../bloc/wireless_state.dart';
import 'signal_monitor_widget.dart';

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
      buildWhen: (previous, current) {
        // Only rebuild on registration-related states
        return current is WirelessInitial ||
               current is WirelessRegistrationsLoading ||
               current is WirelessRegistrationsLoaded ||
               current is WirelessRegistrationsError;
      },
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
                final signalStrength = registration.signalStrength ?? 0;
                
                // Determine signal color (green: > -70, yellow: -70 to -85, red: < -85)
                Color signalColor;
                if (signalStrength > -70) {
                  signalColor = Colors.green;
                } else if (signalStrength > -85) {
                  signalColor = Colors.orange;
                } else {
                  signalColor = Colors.red;
                }
                
                // Calculate signal percentage for visual bar (assuming -100 to -30 range)
                double signalPercentage = ((signalStrength + 100) / 70).clamp(0.0, 1.0);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: InkWell(
                    onTap: () {
                      // Show signal monitor bottom sheet
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => DraggableScrollableSheet(
                          initialChildSize: 0.9,
                          minChildSize: 0.5,
                          maxChildSize: 0.95,
                          builder: (_, controller) => SignalMonitorWidget(
                            client: registration,
                            onRefresh: () {
                              context.read<WirelessBloc>().add(
                                const LoadWirelessRegistrations(),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header row with device icon and MAC address
                          Row(
                            children: [
                              // Device icon
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              child: Icon(
                                Icons.devices,
                                color: Colors.blue.shade700,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // MAC address and hostname
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          registration.macAddress ?? 'Unknown MAC',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      // Copy button
                                      IconButton(
                                        icon: const Icon(Icons.copy, size: 18),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(
                                            text: registration.macAddress ?? '',
                                          ));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('MAC address copied'),
                                              duration: Duration(seconds: 1),
                                            ),
                                          );
                                        },
                                        tooltip: 'Copy MAC address',
                                      ),
                                    ],
                                  ),
                                  if (registration.hostname?.isNotEmpty ?? false)
                                    Text(
                                      registration.hostname!,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Connected badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Connected',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Signal strength visual bar
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Signal Strength',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.help_outline, size: 14, color: Colors.grey.shade600),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () => _showSignalHelp(context),
                                      tooltip: 'What is signal strength?',
                                    ),
                                  ],
                                ),
                                Text(
                                  '$signalStrength dBm',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: signalColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: signalPercentage,
                                backgroundColor: Colors.grey.shade200,
                                color: signalColor,
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Info grid
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoItem(
                                icon: Icons.upload,
                                label: 'TX Rate',
                                value: '${registration.txRate ?? 0} Mbps',
                                onHelp: () => _showTxRxHelp(context),
                              ),
                            ),
                            Expanded(
                              child: _buildInfoItem(
                                icon: Icons.download,
                                label: 'RX Rate',
                                value: '${registration.rxRate ?? 0} Mbps',
                                onHelp: () => _showTxRxHelp(context),
                              ),
                            ),
                            Expanded(
                              child: _buildInfoItem(
                                icon: Icons.access_time,
                                label: 'Uptime',
                                value: registration.uptime ?? 'N/A',
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Interface info
                        Row(
                          children: [
                            Icon(Icons.router, size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              'Interface: ${registration.interface ?? 'N/A'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const Spacer(),
                            // Disconnect button
                            TextButton.icon(
                              onPressed: () {
                                _showDisconnectDialog(context, registration);
                              },
                              icon: const Icon(Icons.power_settings_new, size: 16),
                              label: const Text('Disconnect'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onHelp,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Colors.blue.shade700),
            if (onHelp != null)
              IconButton(
                icon: Icon(Icons.help_outline, size: 12, color: Colors.grey.shade600),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                onPressed: onHelp,
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showSignalHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.signal_cellular_alt, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('Signal Strength'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Signal strength is measured in dBm (decibel-milliwatts):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('🟢 Excellent: -30 to -67 dBm',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              Text('  Ideal for all activities'),
              SizedBox(height: 8),
              Text('🟢 Good: -67 to -70 dBm',
                  style: TextStyle(color: Colors.green)),
              Text('  Suitable for most activities'),
              SizedBox(height: 8),
              Text('🟡 Fair: -70 to -85 dBm',
                  style: TextStyle(color: Colors.orange)),
              Text('  May experience some issues'),
              SizedBox(height: 8),
              Text('🔴 Poor: -85 to -100 dBm',
                  style: TextStyle(color: Colors.red)),
              Text('  Unstable connection'),
              SizedBox(height: 12),
              Text(
                'Note: Higher values (closer to 0) are better',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
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

  void _showTxRxHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.swap_vert, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('TX/RX Rates'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'TX Rate (Transmit)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 4),
              Text('• Data upload speed from client to router\n'
                   '• How fast the client sends data\n'
                   '• Measured in Mbps (Megabits per second)'),
              SizedBox(height: 12),
              Text(
                'RX Rate (Receive)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 4),
              Text('• Data download speed from router to client\n'
                   '• How fast the client receives data\n'
                   '• Measured in Mbps (Megabits per second)'),
              SizedBox(height: 12),
              Text(
                'These rates show the negotiated connection speed, not actual throughput. '
                'Actual speeds depend on signal quality, interference, and network load.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
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

  void _showDisconnectDialog(BuildContext context, dynamic registration) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Disconnect Client'),
        content: Text(
          'Are you sure you want to disconnect this client?\n\nMAC: ${registration.macAddress}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<WirelessBloc>().add(
                DisconnectWirelessClient(
                  registration.macAddress ?? '',
                  registration.interface ?? '',
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Disconnecting client...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }
}