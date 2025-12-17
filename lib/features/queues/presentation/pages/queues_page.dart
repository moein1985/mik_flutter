import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../bloc/queues_bloc.dart';
import '../bloc/queues_event.dart';
import '../bloc/queues_state.dart';
import '../widgets/queue_list_item.dart';

class QueuesPage extends StatefulWidget {
  const QueuesPage({super.key});

  @override
  State<QueuesPage> createState() => _QueuesPageState();
}

class _QueuesPageState extends State<QueuesPage> {
  String? _lastShownMessage;

  @override
  void initState() {
    super.initState();
    context.read<QueuesBloc>().add(const LoadQueues());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.speedLimitTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refresh,
            onPressed: () {
              context.read<QueuesBloc>().add(const RefreshQueues());
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(AppRoutes.addQueue);
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.addSpeedLimit),
      ),
      body: BlocConsumer<QueuesBloc, QueuesState>(
        listener: (context, state) {
          switch (state) {
            case QueueOperationSuccess(:final message):
              if (_lastShownMessage != message) {
                _lastShownMessage = message;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            case QueuesError(:final error):
              if (_lastShownMessage != error) {
                _lastShownMessage = error;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            case QueuesInitial():
            case QueuesLoading():
            case QueuesLoaded():
            case QueueOperationInProgress():
            case QueueLoadedForEdit():
              _lastShownMessage = null;
          }
        },
        builder: (context, state) {
          return switch (state) {
            QueuesLoading() || QueueOperationInProgress() => 
              const Center(child: CircularProgressIndicator()),
            QueuesLoaded(queues: final queues) when queues.isEmpty => 
              _buildEmptyView(l10n, colorScheme),
            QueuesLoaded(queues: _) => 
              _buildQueuesList(state, l10n, colorScheme),
            QueuesError(error: final error) => 
              _buildErrorView(l10n, colorScheme, error),
            QueuesInitial() || QueueOperationSuccess() || QueueLoadedForEdit() => 
              const Center(child: CircularProgressIndicator()),
          };
        },
      ),
    );
  }

  Widget _buildEmptyView(AppLocalizations l10n, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.speed,
              size: 80,
              color: colorScheme.primary.withAlpha(128),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noSpeedLimits,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.speedLimitDescription,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.push(AppRoutes.addQueue),
              icon: const Icon(Icons.add),
              label: Text(l10n.addSpeedLimit),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(AppLocalizations l10n, ColorScheme colorScheme, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: colorScheme.error.withAlpha(128),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.error,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                context.read<QueuesBloc>().add(const LoadQueues());
              },
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueuesList(QueuesLoaded state, AppLocalizations l10n, ColorScheme colorScheme) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<QueuesBloc>().add(const RefreshQueues());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.queues.length,
        itemBuilder: (context, index) {
          final queue = state.queues[index];
          return QueueListItem(
            queue: queue,
            onTap: () {
              context.push('${AppRoutes.queues}/edit/${queue.id}');
            },
            onToggle: (enabled) {
              context.read<QueuesBloc>().add(ToggleQueue(queue.id, enabled));
            },
            onDelete: () => _showDeleteDialog(context, queue.id, queue.name, l10n),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String queueId, String queueName, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteSpeedLimit),
        content: Text('${l10n.deleteSpeedLimitConfirm} "$queueName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<QueuesBloc>().add(DeleteQueue(queueId));
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
