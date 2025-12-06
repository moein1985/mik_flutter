import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/cloud_bloc.dart';
import '../bloc/cloud_event.dart';
import '../bloc/cloud_state.dart';

class CloudPage extends StatelessWidget {
  const CloudPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CloudBloc(repository: sl())..add(const LoadCloudStatus()),
      child: const CloudPageContent(),
    );
  }
}

class CloudPageContent extends StatelessWidget {
  const CloudPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MikroTik Cloud'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => context.read<CloudBloc>().add(const LoadCloudStatus()),
          ),
        ],
      ),
      body: BlocConsumer<CloudBloc, CloudState>(
        listener: (context, state) {
          if (state is CloudOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is CloudError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CloudLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CloudOperationInProgress) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(state.operation),
                ],
              ),
            );
          }

          if (state is CloudLoaded) {
            return _buildContent(context, state);
          }

          if (state is CloudError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.read<CloudBloc>().add(const LoadCloudStatus()),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, CloudLoaded state) {
    final status = state.status;

    // Check if cloud is not supported (x86/CHR)
    if (!status.isSupported) {
      return _buildNotSupportedView(context, status);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<CloudBloc>().add(const LoadCloudStatus());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            _buildStatusCard(context, status),
            const SizedBox(height: 16),

            // DDNS Info Card (only when enabled)
            if (status.ddnsEnabled) ...[
              _buildDdnsInfoCard(context, status),
              const SizedBox(height: 16),
            ],

            // Settings Card
            _buildSettingsCard(context, status),
          ],
        ),
      ),
    );
  }

  Widget _buildNotSupportedView(BuildContext context, status) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              size: 80,
              color: Colors.orange[300],
            ),
            const SizedBox(height: 24),
            const Text(
              'Cloud Not Supported',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'MikroTik Cloud services are not available on x86/CHR (virtual) routers.\n\n'
              'This feature is only available on hardware RouterBOARD devices.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[700]),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      status.warning ?? 'Cloud services not supported on x86',
                      style: TextStyle(color: Colors.orange[700]),
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

  Widget _buildStatusCard(BuildContext context, status) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  status.ddnsEnabled ? Icons.cloud_done : Icons.cloud_off,
                  size: 32,
                  color: status.ddnsEnabled ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DDNS Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        status.ddnsEnabled ? 'Enabled' : 'Disabled',
                        style: TextStyle(
                          color: status.ddnsEnabled ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: status.ddnsEnabled,
                  onChanged: (value) {
                    if (value) {
                      context.read<CloudBloc>().add(const EnableCloudDdns());
                    } else {
                      context.read<CloudBloc>().add(const DisableCloudDdns());
                    }
                  },
                ),
              ],
            ),
            if (status.status != null) ...[
              const Divider(height: 24),
              _buildInfoRow('Status', status.status!, _getStatusColor(status.status!)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDdnsInfoCard(BuildContext context, status) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.dns, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'DDNS Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.sync),
                  tooltip: 'Force Update',
                  onPressed: () {
                    context.read<CloudBloc>().add(const ForceUpdateDdns());
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // DNS Name (the important one for Let's Encrypt)
            if (status.dnsName != null && status.dnsName!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DNS Name',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SelectableText(
                            status.dnsName!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      tooltip: 'Copy DNS Name',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: status.dnsName!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('DNS name copied to clipboard'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '💡 Use this DNS name for Let\'s Encrypt certificates',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Public Address
            if (status.publicAddress != null && status.publicAddress!.isNotEmpty)
              _buildCopyableInfoRow(context, 'Public IP', status.publicAddress!),

            // Update Interval
            if (status.ddnsUpdateInterval != null)
              _buildInfoRow('Update Interval', status.ddnsUpdateInterval!, null),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, status) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.settings, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Update Time Switch
            SwitchListTile(
              title: const Text('Update Time from Cloud'),
              subtitle: const Text('Sync router time with MikroTik cloud'),
              value: status.updateTime,
              onChanged: (value) {
                context.read<CloudBloc>().add(SetCloudUpdateTime(value));
              },
            ),

            // Back to Home VPN status (if available)
            if (status.backToHomeVpn != null) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.vpn_key),
                title: const Text('Back to Home VPN'),
                subtitle: Text(status.backToHomeVpn!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color? valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyableInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label copied to clipboard'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'updated':
        return Colors.green;
      case 'updating':
        return Colors.orange;
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
