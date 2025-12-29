import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../bloc/snmp_monitor_bloc.dart';
import '../bloc/snmp_monitor_event.dart';
import '../bloc/snmp_monitor_state.dart';

class SnmpDashboardPage extends StatefulWidget {
  const SnmpDashboardPage({super.key});

  @override
  State<SnmpDashboardPage> createState() => _SnmpDashboardPageState();
}

class _SnmpDashboardPageState extends State<SnmpDashboardPage> {
  final _ipController = TextEditingController();
  final _communityController = TextEditingController(text: 'public');
  final _portController = TextEditingController(text: '161');

  @override
  void dispose() {
    _ipController.dispose();
    _communityController.dispose();
    _portController.dispose();
    super.dispose();
  }

  void _fetchData() {
    final ip = _ipController.text.trim();
    final community = _communityController.text.trim();
    final port = int.tryParse(_portController.text) ?? 161;

    if (ip.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter device IP address')),
      );
      return;
    }

    context.read<SnmpMonitorBloc>().add(
          FetchDataRequested(
            ip: ip,
            community: community.isEmpty ? 'public' : community,
            port: port,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
        title: const Text('SNMP Monitor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
          ),
        ],
      ),
      body: BlocConsumer<SnmpMonitorBloc, SnmpMonitorState>(
        listener: (context, state) {
          if (state is SnmpMonitorFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInputCard(theme),
                const SizedBox(height: 16),
                if (state is SnmpMonitorLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (state is SnmpMonitorSuccess) ...[
                  _buildDeviceInfoCard(theme, state),
                  const SizedBox(height: 16),
                  _buildInterfacesCard(theme, state),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputCard(ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Device Connection',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: 'IP Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.router),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _communityController,
                    decoration: const InputDecoration(
                      labelText: 'Community',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.key),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _portController,
                    decoration: const InputDecoration(
                      labelText: 'Port',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchData,
              icon: const Icon(Icons.search),
              label: const Text('Query Device'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfoCard(ThemeData theme, SnmpMonitorSuccess state) {
    final info = state.deviceInfo;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Device Information',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (info.sysName != null)
              _buildInfoRow('Name', info.sysName!),
            if (info.sysDescr != null)
              _buildInfoRow('Description', info.sysDescr!),
            if (info.sysLocation != null)
              _buildInfoRow('Location', info.sysLocation!),
            if (info.sysContact != null)
              _buildInfoRow('Contact', info.sysContact!),
            if (info.sysUpTime != null)
              _buildInfoRow('Uptime', info.sysUpTime!),
          ],
        ),
      ),
    );
  }

  Widget _buildInterfacesCard(ThemeData theme, SnmpMonitorSuccess state) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lan, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Interfaces (${state.interfaces.length})',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...state.interfaces.map((iface) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: Colors.grey.shade50,
                  child: ListTile(
                    leading: Icon(
                      iface.operStatusIcon,
                      color: iface.operStatusColor,
                    ),
                    title: Text(
                      iface.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${iface.displayOperStatus} | ${iface.displaySpeed ?? "N/A"}',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('↓ ${iface.displayInOctets}'),
                        Text('↑ ${iface.displayOutOctets}'),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
