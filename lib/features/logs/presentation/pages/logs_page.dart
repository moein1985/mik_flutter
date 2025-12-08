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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LogsBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)?.systemLogs ?? 'System Logs'),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: AppLocalizations.of(context)?.logs ?? 'Logs'),
              Tab(text: AppLocalizations.of(context)?.follow ?? 'Follow'),
            ],
          ),
          actions: [
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
            LogsList(isFollowing: false),
            LogsList(isFollowing: true),
          ],
        ),
        floatingActionButton: BlocBuilder<LogsBloc, LogsState>(
          builder: (context, state) {
            if (state is LogsFollowing) {
              return FloatingActionButton(
                onPressed: () {
                  context.read<LogsBloc>().add(const StopFollowingLogs());
                },
                backgroundColor: Colors.red,
                child: const Icon(Icons.stop),
              );
            } else {
              return FloatingActionButton(
                onPressed: () {
                  context.read<LogsBloc>().add(StartFollowingLogs(
                    topics: _selectedTopics,
                  ));
                },
                child: const Icon(Icons.play_arrow),
              );
            }
          },
        ),
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
          context.read<LogsBloc>().add(LoadLogs(topics: topics));
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
                context.read<LogsBloc>().add(SearchLogs(
                  query: query,
                  topics: _selectedTopics,
                ));
              }
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)?.search ?? 'Search'),
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
              context.read<LogsBloc>().add(const ClearLogs());
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