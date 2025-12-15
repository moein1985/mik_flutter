import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/entities/firewall_rule.dart';
import '../bloc/firewall_bloc.dart';

final _log = AppLogger.tag('FirewallPage');

class FirewallPage extends StatefulWidget {
  const FirewallPage({super.key});

  @override
  State<FirewallPage> createState() => _FirewallPageState();
}

class _FirewallPageState extends State<FirewallPage> {
  @override
  void initState() {
    super.initState();
    _log.i('FirewallPage initState');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firewall'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'About Firewall',
            onPressed: () => _showFirewallInfo(context),
          ),
        ],
      ),
      // Note: No BlocListener here - snackbars are shown in child pages (rules_page, address_list_page)
      // to avoid duplicate snackbars when both pages are in the navigation stack
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Quick Tip Card
            _buildQuickTipCard(colorScheme),
            
            const SizedBox(height: 20),
            
            // Section Title
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'Firewall Tables',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            
            // Firewall Grid
            _buildFirewallGrid(context, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTipCard(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'View firewall rules organized by table type. Tap any category to see its rules.',
              style: TextStyle(
                color: Colors.orange.shade800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirewallGrid(BuildContext context, ColorScheme colorScheme) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        _buildCard(
          context,
          colorScheme: colorScheme,
          icon: Icons.filter_alt,
          title: 'Filter',
          subtitle: 'Packet filtering rules',
          color: Colors.blue,
          type: FirewallRuleType.filter,
        ),
        _buildCard(
          context,
          colorScheme: colorScheme,
          icon: Icons.swap_horiz,
          title: 'NAT',
          subtitle: 'Network Address Translation',
          color: Colors.green,
          type: FirewallRuleType.nat,
        ),
        _buildCard(
          context,
          colorScheme: colorScheme,
          icon: Icons.edit_note,
          title: 'Mangle',
          subtitle: 'Packet marking & QoS',
          color: Colors.orange,
          type: FirewallRuleType.mangle,
        ),
        _buildCard(
          context,
          colorScheme: colorScheme,
          icon: Icons.shield,
          title: 'Raw',
          subtitle: 'Pre-routing rules',
          color: Colors.purple,
          type: FirewallRuleType.raw,
        ),
        _buildCard(
          context,
          colorScheme: colorScheme,
          icon: Icons.list_alt,
          title: 'Address List',
          subtitle: 'IP address groups',
          color: Colors.indigo,
          type: FirewallRuleType.addressList,
        ),
        _buildCard(
          context,
          colorScheme: colorScheme,
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
    required ColorScheme colorScheme,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required FirewallRuleType type,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withAlpha(51)),
      ),
      child: InkWell(
        onTap: () => _navigateToRulePage(context, type),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with colored background
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFirewallInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.shield, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            const Text('Firewall Tables'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoItem(
                title: 'Filter',
                description: 'Main firewall table for accepting, dropping, or rejecting packets.',
              ),
              _InfoItem(
                title: 'NAT',
                description: 'Network Address Translation for srcnat, dstnat, and masquerade.',
              ),
              _InfoItem(
                title: 'Mangle',
                description: 'Packet marking for QoS, routing marks, and connection tracking.',
              ),
              _InfoItem(
                title: 'Raw',
                description: 'Pre-connection tracking rules for notrack and advanced filtering.',
              ),
              _InfoItem(
                title: 'Address List',
                description: 'IP address groups used in firewall rules for easy management.',
              ),
              _InfoItem(
                title: 'Layer7 Protocol',
                description: 'Application layer patterns for deep packet inspection.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
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

class _InfoItem extends StatelessWidget {
  final String title;
  final String description;

  const _InfoItem({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
