import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/entities/firewall_rule.dart';
import '../bloc/firewall_bloc.dart';
import '../bloc/firewall_state.dart';

final _log = AppLogger.tag('FirewallPage');

class FirewallPage extends StatefulWidget {
  const FirewallPage({super.key});

  @override
  State<FirewallPage> createState() => _FirewallPageState();
}

class _FirewallPageState extends State<FirewallPage> {
  String? _lastShownMessage;

  @override
  void initState() {
    super.initState();
    _log.i('FirewallPage initState');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firewall Management'),
      ),
      body: BlocConsumer<FirewallBloc, FirewallState>(
        listener: (context, state) {
          if (state is FirewallError) {
            if (_lastShownMessage != state.message) {
              _lastShownMessage = state.message;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } else if (state is FirewallOperationSuccess) {
            if (_lastShownMessage != state.message) {
              _lastShownMessage = state.message;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            _lastShownMessage = null;
          }
        },
        builder: (context, state) {
          return _buildFirewallGrid(context);
        },
      ),
    );
  }

  Widget _buildFirewallGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildCard(
          context,
          icon: Icons.filter_alt,
          title: 'Filter',
          subtitle: 'Packet filtering rules',
          color: Colors.blue,
          type: FirewallRuleType.filter,
        ),
        _buildCard(
          context,
          icon: Icons.swap_horiz,
          title: 'NAT',
          subtitle: 'Network Address Translation',
          color: Colors.green,
          type: FirewallRuleType.nat,
        ),
        _buildCard(
          context,
          icon: Icons.edit_note,
          title: 'Mangle',
          subtitle: 'Packet marking & QoS',
          color: Colors.orange,
          type: FirewallRuleType.mangle,
        ),
        _buildCard(
          context,
          icon: Icons.shield,
          title: 'Raw',
          subtitle: 'Pre-routing rules',
          color: Colors.purple,
          type: FirewallRuleType.raw,
        ),
        _buildCard(
          context,
          icon: Icons.list_alt,
          title: 'Address List',
          subtitle: 'IP address groups',
          color: Colors.indigo,
          type: FirewallRuleType.addressList,
        ),
        _buildCard(
          context,
          icon: Icons.code,
          title: 'Layer7 Protocol',
          subtitle: 'App-layer patterns',
          color: Colors.teal,
          type: FirewallRuleType.layer7Protocol,
        ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required FirewallRuleType type,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToRulePage(context, type),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToRulePage(BuildContext context, FirewallRuleType type) {
    final bloc = context.read<FirewallBloc>();
    // For Address List, use the special page with filtering
    if (type == FirewallRuleType.addressList) {
      context.push(AppRoutes.firewallAddressList, extra: bloc);
    } else {
      context.push('${AppRoutes.firewall}/rules/${type.name}', extra: bloc);
    }
  }
}
