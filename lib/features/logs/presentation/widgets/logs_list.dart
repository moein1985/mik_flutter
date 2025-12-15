import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/logs_bloc.dart';
import '../bloc/logs_event.dart';
import '../bloc/logs_state.dart';
import 'log_entry_widget.dart';

class LogsList extends StatelessWidget {
  final bool isFollowing;

  const LogsList({
    super.key,
    required this.isFollowing,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LogsBloc, LogsState>(
      builder: (context, state) {
        return switch (state) {
          LogsInitial() => _buildInitialState(context),
          LogsLoading() => const Center(child: CircularProgressIndicator()),
          LogsError(:final message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<LogsBloc>().add(const LoadLogs());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          LogsLoaded(:final logs) => _buildLogsList(context, logs),
          LogsFollowing(:final logs) => _buildLogsList(context, logs),
          LogsOperationSuccess() => const Center(child: CircularProgressIndicator()),
        };
      },
    );
  }

  Widget _buildInitialState(BuildContext context) {
    // Initial state - load data
    if (!isFollowing) {
      context.read<LogsBloc>().add(const LoadLogs());
    }
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildLogsList(BuildContext context, List logs) {
    if (logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.article_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(isFollowing ? 'No live logs available' : 'No logs found'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<LogsBloc>().add(const RefreshLogs());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final logEntry = logs[index];
          return LogEntryWidget(logEntry: logEntry);
        },
      ),
    );
  }
}