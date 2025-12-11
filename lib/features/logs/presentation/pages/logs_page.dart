import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../injection_container.dart';
import '../bloc/logs_bloc.dart';
import '../bloc/logs_event.dart';
import '../bloc/logs_state.dart';
import '../widgets/logs_list.dart';
import '../widgets/logs_filter_sheet.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedTopics;
  late LogsBloc _logsBloc;
  late LogsBloc _liveLogBloc;

  @override
  void initState() {
    super.initState();
    _logsBloc = sl<LogsBloc>();
    _liveLogBloc = sl<LogsBloc>();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!mounted) return;
    
    // Only handle tab changes when animation is not happening
    // This prevents double-firing of the listener
    if (_tabController.indexIsChanging) return;
    
    // Tab 1: Live Log - start following automatically
    if (_tabController.index == 1) {
      // Switched to Live Log tab - only start if not already following
      if (_liveLogBloc.state is! LogsFollowing) {
        _liveLogBloc.add(StartFollowingLogs(topics: _selectedTopics));
      }
    } else {
      // Switched away from Live Log tab
      if (_liveLogBloc.state is LogsFollowing) {
        _liveLogBloc.add(const StopFollowingLogs());
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    
    // Stop following when page is disposed
    if (_liveLogBloc.state is LogsFollowing) {
      _liveLogBloc.add(const StopFollowingLogs());
    }
    
    _logsBloc.close();
    _liveLogBloc.close();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.systemLogs ?? 'System Logs'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppLocalizations.of(context)?.logs ?? 'Logs'),
            Tab(text: AppLocalizations.of(context)?.liveLog ?? 'Live Log'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _showClearConfirmation,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          BlocProvider.value(
            value: _logsBloc,
            child: const LogsList(isFollowing: false),
          ),
          BlocProvider.value(
            value: _liveLogBloc,
            child: const LogsList(isFollowing: true),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => LogsFilterSheet(
        selectedTopics: _selectedTopics,
        onTopicsChanged: (topics) {
          setState(() => _selectedTopics = topics);
          // Apply filter to current tab
          if (_tabController.index == 0) {
            _logsBloc.add(LoadLogs(topics: topics));
          } else {
            // Restart following with new filter
            _liveLogBloc.add(const StopFollowingLogs());
            _liveLogBloc.add(StartFollowingLogs(topics: topics));
          }
        },
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.search ?? 'Search'),
        content: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)?.searchLogs ?? 'Search logs...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              final query = _searchController.text.trim();
              if (query.isNotEmpty) {
                // Search in current tab
                if (_tabController.index == 0) {
                  _logsBloc.add(SearchLogs(
                    query: query,
                    topics: _selectedTopics,
                  ));
                } else {
                  _liveLogBloc.add(SearchLogs(
                    query: query,
                    topics: _selectedTopics,
                  ));
                }
              }
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)?.search ?? 'Search'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.blue),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)?.systemLogs ?? 'System Logs'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)?.logs ?? 'Logs',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)?.logsTabInfo ?? 
                'Shows router system logs (last 100 entries). Logs are displayed from oldest (top) to newest (bottom). Pull down to refresh.',
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)?.liveLog ?? 'Live Log',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)?.liveLogTabInfo ?? 
                'Shows real-time log updates as they occur on the router. Starts empty and displays only new logs (max 100). Logs are displayed from oldest (top) to newest (bottom).',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)?.close ?? 'Close'),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.clearLogs ?? 'Clear Logs'),
        content: Text(AppLocalizations.of(context)?.clearLogsConfirmation ??
            'Are you sure you want to clear all logs?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Clear logs from router (affects both tabs)
              _logsBloc.add(const ClearLogs());
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)?.clear ?? 'Clear'),
          ),
        ],
      ),
    );
  }
}