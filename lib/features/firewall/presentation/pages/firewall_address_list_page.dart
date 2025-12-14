import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/firewall_rule.dart';
import '../bloc/firewall_bloc.dart';
import '../bloc/firewall_event.dart';
import '../bloc/firewall_state.dart';
import '../widgets/firewall_rule_card.dart';

final _log = AppLogger.tag('FirewallAddressListPage');

class FirewallAddressListPage extends StatefulWidget {
  const FirewallAddressListPage({super.key});

  @override
  State<FirewallAddressListPage> createState() => _FirewallAddressListPageState();
}

class _FirewallAddressListPageState extends State<FirewallAddressListPage> {
  String _searchQuery = '';
  String? _lastShownMessage;
  final TextEditingController _searchController = TextEditingController();
  
  /// Currently selected list name. Null means no selection (show list selector).
  String? _selectedListName;

  @override
  void initState() {
    super.initState();
    _log.i('FirewallAddressListPage initState');
    // Only load list names initially (lightweight operation)
    context.read<FirewallBloc>().add(const LoadAddressListNames());
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
          title: Text(_selectedListName ?? 'Address List'),
          leading: _selectedListName != null
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _selectedListName = null;
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                )
              : null,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () {
                if (_selectedListName != null) {
                  // Refresh current list
                  context.read<FirewallBloc>().add(
                    LoadAddressListByName(_selectedListName!),
                  );
                } else {
                  // Refresh list names
                  context.read<FirewallBloc>().add(const LoadAddressListNames());
                }
              },
            ),
          ],
        ),
        body: _selectedListName == null
            ? _buildListNameSelector(colorScheme)
            : _buildAddressListView(colorScheme),
      ),
    );
  }

  /// Build the list name selector (first screen)
  Widget _buildListNameSelector(ColorScheme colorScheme) {
    return BlocBuilder<FirewallBloc, FirewallState>(
      builder: (context, state) {
        // Get data using sealed class pattern
        final currentData = state.currentData;
        List<String> listNames = currentData?.addressListNames ?? [];
        bool isLoading = currentData?.loadingType == FirewallRuleType.addressList;

        if (isLoading && listNames.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (listNames.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.folder_off_outlined,
                    size: 48,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No address lists found',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: () {
                    context.read<FirewallBloc>().add(const LoadAddressListNames());
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Tip Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.list_alt, color: Colors.indigo.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Select a list to view its addresses. ${listNames.length} lists available.',
                      style: TextStyle(
                        color: Colors.indigo.shade800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Section Title
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 8),
              child: Text(
                'Available Lists',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            
            // List of address list names
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: listNames.length,
                itemBuilder: (context, index) {
                  final listName = listNames[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.list_alt, color: Colors.indigo, size: 20),
                      ),
                      title: Text(
                        listName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onTap: () {
                        setState(() {
                          _selectedListName = listName;
                        });
                        // Load addresses for this list
                        context.read<FirewallBloc>().add(
                          LoadAddressListByName(listName),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build the address list view (second screen)
  Widget _buildAddressListView(ColorScheme colorScheme) {
    return Column(
      children: [
        _buildSearchBar(colorScheme),
        _buildStatsCard(colorScheme),
        Expanded(child: _buildRulesList(colorScheme)),
      ],
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by address, comment...',
          prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
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
          activeCount = state.getActiveCount(FirewallRuleType.addressList);
          disabledCount = state.getDisabledCount(FirewallRuleType.addressList);
          totalCount = state.getTotalCount(FirewallRuleType.addressList);
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
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
            color: color.withOpacity(0.1),
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
        // Get rules from state using sealed class pattern
        final currentData = state.currentData;
        List<FirewallRule> rules = currentData?.getRulesForType(FirewallRuleType.addressList) ?? [];
        bool isLoading = currentData?.loadingType == FirewallRuleType.addressList;

        // Show loading when first loading this list
        if (isLoading && rules.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Loading addresses...',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          );
        }

        // Filter by search query
        List<FirewallRule> filteredRules = rules;
        if (_searchQuery.isNotEmpty) {
          filteredRules = rules.where((rule) {
            // Search in listName
            if (rule.listName?.toLowerCase().contains(_searchQuery) == true) {
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

        if (filteredRules.isEmpty && !isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
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
                      ? 'No addresses found matching "$_searchQuery"'
                      : 'No addresses in this list',
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
              itemCount: filteredRules.length,
              itemBuilder: (context, index) {
                final rule = filteredRules[index];
                return FirewallRuleCard(
                  rule: rule,
                  index: index + 1,
                  onToggle: (enabled) {
                    context.read<FirewallBloc>().add(
                          ToggleFirewallRule(
                            type: FirewallRuleType.addressList,
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
