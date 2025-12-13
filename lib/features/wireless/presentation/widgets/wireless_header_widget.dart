import 'package:flutter/material.dart';

class WirelessHeaderWidget extends StatelessWidget {
  final int interfacesCount;
  final int clientsCount;
  final int profilesCount;

  const WirelessHeaderWidget({
    super.key,
    required this.interfacesCount,
    required this.clientsCount,
    required this.profilesCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.wifi, color: colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Wireless Management',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.help_outline),
                  onPressed: () => _showHelpDialog(context),
                  tooltip: 'Help',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Manage wireless interfaces, clients, and security profiles',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            // Quick Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  context,
                  icon: Icons.router,
                  label: 'Interfaces',
                  value: interfacesCount.toString(),
                  color: colorScheme.primary,
                ),
                _buildStatItem(
                  context,
                  icon: Icons.devices,
                  label: 'Clients',
                  value: clientsCount.toString(),
                  color: colorScheme.secondary,
                ),
                _buildStatItem(
                  context,
                  icon: Icons.security,
                  label: 'Profiles',
                  value: profilesCount.toString(),
                  color: colorScheme.tertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Wireless Management'),
        content: Text(
          'This section allows you to manage wireless interfaces, monitor connected clients, configure security profiles, and perform wireless network scans.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}