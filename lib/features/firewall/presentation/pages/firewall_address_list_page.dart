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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedListName ?? 'Address List'),
        leading: _selectedListName != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedListName = null;
                    _searchQuery = '';
                  });
                },
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
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
          ? _buildListNameSelector()
          : _buildAddressListView(),
    );
  }

  /// Build the list name selector (first screen)
  Widget _buildListNameSelector() {
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
        }
      },
      builder: (context, state) {
        List<String> listNames = [];
        bool isLoading = false;

        if (state is FirewallLoaded) {
          listNames = state.addressListNames;
          isLoading = state.loadingType == FirewallRuleType.addressList;
        } else if (state is FirewallError && state.previousData != null) {
          listNames = state.previousData!.addressListNames;
        } else if (state is FirewallOperationSuccess && state.previousData != null) {
          listNames = state.previousData!.addressListNames;
        }

        if (isLoading && listNames.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (listNames.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No address lists found',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
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
            // Info card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Select a list to view its addresses.\n'
                      '${listNames.length} lists available.',
                      style: TextStyle(color: Colors.blue[800]),
                    ),
                  ),
                ],
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
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.withValues(alpha: 0.2),
                        child: const Icon(Icons.list_alt, color: Colors.blue),
                      ),
                      title: Text(
                        listName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: const Icon(Icons.chevron_right),
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
  Widget _buildAddressListView() {
    return Column(
      children: [
        _buildSearchBar(),
        _buildStatsBar(),
        Expanded(child: _buildRulesList()),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by address, comment...',
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
          activeCount = state.getActiveCount(FirewallRuleType.addressList);
          disabledCount = state.getDisabledCount(FirewallRuleType.addressList);
          totalCount = state.getTotalCount(FirewallRuleType.addressList);
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
        // Get rules from state
        List<FirewallRule> rules = [];
        bool isLoading = false;

        if (state is FirewallLoaded) {
          rules = state.getRulesForType(FirewallRuleType.addressList);
          isLoading = state.loadingType == FirewallRuleType.addressList;
        } else if (state is FirewallError && state.previousData != null) {
          rules = state.previousData!.getRulesForType(FirewallRuleType.addressList);
        } else if (state is FirewallOperationSuccess && state.previousData != null) {
          rules = state.previousData!.getRulesForType(FirewallRuleType.addressList);
        }

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
                  style: TextStyle(color: Colors.grey[600]),
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
                Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'No addresses found matching "$_searchQuery"'
                      : 'No addresses in this list',
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
