import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/firewall_rule.dart';
import '../bloc/firewall_bloc.dart';
import '../bloc/firewall_event.dart';
import '../bloc/firewall_state.dart';
import '../widgets/firewall_rule_card.dart';

final _log = AppLogger.tag('FirewallRulesPage');

class FirewallRulesPage extends StatefulWidget {
  final FirewallRuleType type;

  const FirewallRulesPage({super.key, required this.type});

  @override
  State<FirewallRulesPage> createState() => _FirewallRulesPageState();
}

class _FirewallRulesPageState extends State<FirewallRulesPage> {
  String _searchQuery = '';
  String? _lastShownMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _log.i('FirewallRulesPage initState for ${widget.type.displayName}');
    // Load rules when page opens
    context.read<FirewallBloc>().add(LoadFirewallRules(widget.type));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return BlocListener<FirewallBloc, FirewallState>(
      listener: (context, state) {
        if (state is FirewallError) {
          if (_lastShownMessage != state.message) {
            _lastShownMessage = state.message;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
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
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          _lastShownMessage = null;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.type.displayName),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () {
                context.read<FirewallBloc>().add(LoadFirewallRules(widget.type));
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Quick Tip Card
            _buildQuickTipCard(colorScheme),
            // Search Bar
            _buildSearchBar(colorScheme),
            // Stats Card
            _buildStatsCard(colorScheme),
            // Rules List
            Expanded(child: _buildRulesList(colorScheme)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTipCard(ColorScheme colorScheme) {
    final tipData = _getTipForType(widget.type);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tipData.color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tipData.color.withAlpha(77)),
      ),
      child: Row(
        children: [
          Icon(tipData.icon, color: tipData.color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tipData.message,
              style: TextStyle(
                color: tipData.color.withAlpha(230),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ({IconData icon, Color color, String message}) _getTipForType(FirewallRuleType type) {
    switch (type) {
      case FirewallRuleType.filter:
        return (
          icon: Icons.filter_alt,
          color: Colors.blue.shade700,
          message: 'Filter rules control packet flow by accepting, dropping, or rejecting traffic.',
        );
      case FirewallRuleType.nat:
        return (
          icon: Icons.swap_horiz,
          color: Colors.green.shade700,
          message: 'NAT rules translate network addresses for srcnat, dstnat, and masquerade.',
        );
      case FirewallRuleType.mangle:
        return (
          icon: Icons.edit_note,
          color: Colors.orange.shade700,
          message: 'Mangle rules mark packets for QoS, policy routing, and connection tracking.',
        );
      case FirewallRuleType.raw:
        return (
          icon: Icons.shield,
          color: Colors.purple.shade700,
          message: 'Raw rules operate before connection tracking for notrack and advanced filtering.',
        );
      case FirewallRuleType.addressList:
        return (
          icon: Icons.list_alt,
          color: Colors.indigo.shade700,
          message: 'Address lists group IPs for use in firewall rules.',
        );
      case FirewallRuleType.layer7Protocol:
        return (
          icon: Icons.code,
          color: Colors.teal.shade700,
          message: 'Layer7 protocols define patterns for deep packet inspection.',
        );
    }
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search rules...',
          prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outline.withAlpha(77)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outline.withAlpha(77)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withAlpha(77),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildStatsCard(ColorScheme colorScheme) {
    return BlocBuilder<FirewallBloc, FirewallState>(
      builder: (context, state) {
        int activeCount = 0;
        int disabledCount = 0;
        int totalCount = 0;

        if (state is FirewallLoaded) {
          activeCount = state.getActiveCount(widget.type);
          disabledCount = state.getDisabledCount(widget.type);
          totalCount = state.getTotalCount(widget.type);
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colorScheme.outline.withAlpha(51)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.layers,
                  label: 'Total',
                  count: totalCount,
                  color: Colors.blue,
                ),
                _buildStatItem(
                  icon: Icons.check_circle,
                  label: 'Active',
                  count: activeCount,
                  color: Colors.green,
                ),
                _buildStatItem(
                  icon: Icons.cancel,
                  label: 'Disabled',
                  count: disabledCount,
                  color: Colors.red,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRulesList(ColorScheme colorScheme) {
    return BlocBuilder<FirewallBloc, FirewallState>(
      builder: (context, state) {
        // Check if we're loading this specific type
        if (state is FirewallLoading && state.type == widget.type) {
          return const Center(child: CircularProgressIndicator());
        }

        // Get rules from state using sealed class pattern
        final currentData = state.currentData;
        List<FirewallRule> rules = currentData?.getRulesForType(widget.type) ?? [];
        bool isLoading = currentData?.loadingType == widget.type;

        // Filter rules by search query
        if (_searchQuery.isNotEmpty) {
          rules = rules.where((rule) {
            // Search in displayTitle
            if (rule.displayTitle.toLowerCase().contains(_searchQuery)) {
              return true;
            }
            // Search in summary
            if (rule.summary.toLowerCase().contains(_searchQuery)) {
              return true;
            }
            // Search in all parameters
            for (final entry in rule.allParameters.entries) {
              if (entry.key.toLowerCase().contains(_searchQuery) ||
                  entry.value.toLowerCase().contains(_searchQuery)) {
                return true;
              }
            }
            return false;
          }).toList();
        }

        if (rules.isEmpty && !isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withAlpha(128),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.inbox_outlined,
                    size: 48,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'No rules found matching "$_searchQuery"'
                      : 'No ${widget.type.displayName} rules found',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rules.length,
              itemBuilder: (context, index) {
                final rule = rules[index];
                return FirewallRuleCard(
                  rule: rule,
                  index: index + 1,
                  onToggle: (enabled) {
                    context.read<FirewallBloc>().add(
                          ToggleFirewallRule(
                            type: widget.type,
                            id: rule.id,
                            enable: enabled,
                          ),
                        );
                  },
                );
              },
            ),
            if (isLoading)
              Container(
                color: Colors.black12,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }
}
