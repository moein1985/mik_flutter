import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/wireless_interface.dart';
import '../../domain/entities/wireless_scan_result.dart';
import '../bloc/wireless_bloc.dart';
import '../bloc/wireless_event.dart';
import '../bloc/wireless_state.dart';

class WirelessScannerWidget extends StatefulWidget {
  const WirelessScannerWidget({super.key});

  @override
  State<WirelessScannerWidget> createState() => _WirelessScannerWidgetState();
}

class _WirelessScannerWidgetState extends State<WirelessScannerWidget> {
  String? _selectedInterfaceId;
  int _scanDuration = 5; // Default 5 seconds

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return BlocBuilder<WirelessBloc, WirelessState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              _buildHeaderCard(theme, l10n!),
              const SizedBox(height: 16),

              // Scanner Controls Card
              _buildScannerControlsCard(context, theme, l10n, state),
              const SizedBox(height: 16),

              // Scan Results
              _buildScanResults(context, theme, l10n, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(ThemeData theme, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.wifi_find,
              size: 40,
              color: theme.primaryColor,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WiFi Scanner',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Scan for nearby wireless networks',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerControlsCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    WirelessState state,
  ) {
    List<WirelessInterface> interfaces = [];
    if (state is WirelessInterfacesLoaded) {
      interfaces = state.interfaces.cast<WirelessInterface>();
    }

    // Load interfaces if not loaded yet
    if (interfaces.isEmpty && state is! WirelessInterfacesLoading) {
      context.read<WirelessBloc>().add(const LoadWirelessInterfaces());
    }

    final isScanning = state is WirelessScanLoading;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Scanner Settings',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Interface Selector
            if (interfaces.isEmpty && state is WirelessInterfacesLoading)
              const Center(child: CircularProgressIndicator())
            else if (interfaces.isEmpty)
              Text(
                'No wireless interfaces found',
                style: TextStyle(color: theme.colorScheme.error),
              )
            else
              DropdownButtonFormField<String>(
                initialValue: _selectedInterfaceId,
                decoration: InputDecoration(
                  labelText: 'Select Interface',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.router),
                  helperText: 'Choose the wireless interface to scan with',
                ),
                items: interfaces.map((interface) {
                  return DropdownMenuItem(
                    value: interface.id,
                    child: Text('${interface.name} (${interface.ssid})'),
                  );
                }).toList(),
                onChanged: isScanning
                    ? null
                    : (value) {
                        setState(() {
                          _selectedInterfaceId = value;
                        });
                      },
              ),
            const SizedBox(height: 16),

            // Scan Duration Slider
            Row(
              children: [
                const Icon(Icons.timer_outlined),
                const SizedBox(width: 8),
                Text('Scan Duration: $_scanDuration seconds'),
              ],
            ),
            Slider(
              value: _scanDuration.toDouble(),
              min: 3,
              max: 15,
              divisions: 12,
              label: '$_scanDuration seconds',
              onChanged: isScanning
                  ? null
                  : (value) {
                      setState(() {
                        _scanDuration = value.toInt();
                      });
                    },
            ),
            const SizedBox(height: 16),

            // Scan Button
            ElevatedButton.icon(
              onPressed: _selectedInterfaceId == null || isScanning
                  ? null
                  : () {
                      context.read<WirelessBloc>().add(
                            ScanWirelessNetworks(
                              interfaceId: _selectedInterfaceId!,
                              duration: _scanDuration,
                            ),
                          );
                    },
              icon: isScanning
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: Text(isScanning ? 'Scanning...' : 'Start Scan'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanResults(
    BuildContext context,
    ThemeData theme,
    AppLocalizations? l10n,
    WirelessState state,
  ) {
    if (state is WirelessScanLoaded) {
      final networks = state.scanResults.cast<WirelessScanResult>();
      
      if (networks.isEmpty) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(
                  Icons.wifi_off,
                  size: 64,
                  color: theme.disabledColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'No networks found',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.disabledColor,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              'Found ${networks.length} network${networks.length == 1 ? '' : 's'}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...networks.map((network) => _buildNetworkCard(theme, network)),
        ],
      );
    }

    if (state is WirelessScanError) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 8),
              Text(
                'Scan Failed',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    // Initial state or other states
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.wifi_find,
              size: 64,
              color: theme.disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Ready to scan',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.disabledColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select an interface and click "Start Scan"',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.disabledColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkCard(ThemeData theme, WirelessScanResult network) {
    final signalStrength = network.signalStrength;
    final signalQuality = _getSignalQuality(signalStrength);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getSecurityIcon(network.security),
              size: 32,
              color: network.security.toLowerCase().contains('open')
                  ? Colors.orange
                  : theme.primaryColor,
            ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                network.ssid.isNotEmpty ? network.ssid : '<Hidden SSID>',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            if (network.routerosVersion != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.router,
                      size: 14,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'MikroTik',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'MAC: ${network.macAddress}',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.signal_cellular_alt, size: 14, color: signalQuality.color),
                const SizedBox(width: 4),
                Text(
                  '$signalStrength dBm (${signalQuality.label})',
                  style: TextStyle(
                    fontSize: 12,
                    color: signalQuality.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Signal Strength Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _getSignalStrengthPercentage(signalStrength),
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(signalQuality.color),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoChip(
                  theme,
                  Icons.radio_button_checked,
                  'Ch ${network.channel}',
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  theme,
                  Icons.cell_tower,
                  network.band,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  theme,
                  Icons.lock_outline,
                  network.security,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(ThemeData theme, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: theme.textTheme.bodySmall?.color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSecurityIcon(String security) {
    if (security.toLowerCase().contains('open') || security.toLowerCase().contains('none')) {
      return Icons.lock_open;
    }
    return Icons.lock;
  }

  ({Color color, String label}) _getSignalQuality(int signalStrength) {
    if (signalStrength >= -50) {
      return (color: Colors.green, label: 'Excellent');
    } else if (signalStrength >= -60) {
      return (color: Colors.lightGreen, label: 'Very Good');
    } else if (signalStrength >= -70) {
      return (color: Colors.orange, label: 'Good');
    } else if (signalStrength >= -80) {
      return (color: Colors.deepOrange, label: 'Fair');
    } else {
      return (color: Colors.red, label: 'Poor');
    }
  }

  double _getSignalStrengthPercentage(int signalStrength) {
    // Convert dBm (-100 to -30) to percentage (0 to 1)
    const minSignal = -100;
    const maxSignal = -30;
    final normalized = ((signalStrength - minSignal) / (maxSignal - minSignal)).clamp(0.0, 1.0);
    return normalized;
  }
}
