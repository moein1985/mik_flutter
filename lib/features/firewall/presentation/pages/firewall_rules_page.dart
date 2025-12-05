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

  @override
  void initState() {
    super.initState();
    _log.i('FirewallRulesPage initState for ${widget.type.displayName}');
    // Load rules when page opens
    context.read<FirewallBloc>().add(LoadFirewallRules(widget.type));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type.displayName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<FirewallBloc>().add(LoadFirewallRules(widget.type));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildStatsBar(),
          Expanded(child: _buildRulesList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search rules...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[100],
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
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

  Widget _buildStatsBar() {
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

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.grey[100],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total', totalCount, Colors.blue),
              _buildStatItem('Active', activeCount, Colors.green),
              _buildStatItem('Disabled', disabledCount, Colors.red),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildRulesList() {
    return BlocConsumer<FirewallBloc, FirewallState>(
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
        // Check if we're loading this specific type
        if (state is FirewallLoading && state.type == widget.type) {
          return const Center(child: CircularProgressIndicator());
        }

        // Get rules from state
        List<FirewallRule> rules = [];
        bool isLoading = false;

        if (state is FirewallLoaded) {
          rules = state.getRulesForType(widget.type);
          isLoading = state.loadingType == widget.type;
        } else if (state is FirewallError && state.previousData != null) {
          rules = state.previousData!.getRulesForType(widget.type);
        } else if (state is FirewallOperationSuccess && state.previousData != null) {
          rules = state.previousData!.getRulesForType(widget.type);
        }

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
                Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'No rules found matching "$_searchQuery"'
                      : 'No ${widget.type.displayName} rules found',
                  style: TextStyle(color: Colors.grey[600]),
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
