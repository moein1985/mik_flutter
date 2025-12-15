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
    // Load queues when page opens
    context.read<QueuesBloc>().add(const LoadQueues());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.simpleQueues),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              context.read<QueuesBloc>().add(const RefreshQueues());
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(AppRoutes.addQueue);
        },
        child: const Icon(Icons.add),
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

  Widget _buildQuickTipCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.cyan.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyan.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.speed, color: Colors.cyan.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Simple Queues allow you to limit bandwidth for specific targets (IP, network, or interface).',
              style: TextStyle(
                color: Colors.cyan.shade800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(AppLocalizations l10n, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildQuickTipCard(),
          
          const SizedBox(height: 48),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withAlpha(77),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.queue,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noQueues,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.queueManagement,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(AppLocalizations l10n, ColorScheme colorScheme, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withAlpha(77),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.errorLoadingQueues,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              context.read<QueuesBloc>().add(const LoadQueues());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildQueuesList(QueuesLoaded state, AppLocalizations l10n, ColorScheme colorScheme) {
    // Count enabled/disabled
    final enabledCount = state.queues.where((q) => q.isEnabled).length;
    final disabledCount = state.queues.length - enabledCount;
    
    return RefreshIndicator(
      onRefresh: () async {
        context.read<QueuesBloc>().add(const RefreshQueues());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildQuickTipCard(),
            
            const SizedBox(height: 16),
            
            // Count summary
            _buildCountSummary(state.queues.length, enabledCount, disabledCount, colorScheme),
            
            const SizedBox(height: 16),
            
            // Queue cards
            ...state.queues.map((queue) => QueueListItem(
              queue: queue,
              onTap: () {
                context.push('${AppRoutes.queues}/edit/${queue.id}');
              },
              onToggle: (enabled) {
                context.read<QueuesBloc>().add(
                  ToggleQueue(queue.id, enabled),
                );
              },
              onDelete: () {
                _showDeleteConfirmation(context, queue.id, queue.name);
              },
            )),
            
            // Bottom spacing for FAB
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildCountSummary(int total, int enabled, int disabled, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withAlpha(77),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withAlpha(51)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$total queue${total > 1 ? 's' : ''}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          if (enabled > 0)
            _buildMiniTag('$enabled Active', Colors.green),
          if (disabled > 0) ...[
            const SizedBox(width: 8),
            _buildMiniTag('$disabled Disabled', Colors.grey),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String queueId, String queueName) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteQueue),
        content: Text(
          l10n.deleteQueueConfirm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<QueuesBloc>().add(DeleteQueue(queueId));
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(l10n.deleteQueue),
          ),
        ],
      ),
    );
  }
}