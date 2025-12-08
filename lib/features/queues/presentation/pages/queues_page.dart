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
  @override
  void initState() {
    super.initState();
    // Load queues when page opens
    context.read<QueuesBloc>().add(const LoadQueues());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.simpleQueues),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<QueuesBloc>().add(const RefreshQueues());
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push(AppRoutes.addQueue);
            },
          ),
        ],
      ),
      body: BlocConsumer<QueuesBloc, QueuesState>(
        listener: (context, state) {
          if (state is QueueOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is QueuesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is QueuesLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(l10n.loadingQueues),
                ],
              ),
            );
          } else if (state is QueuesLoaded) {
            if (state.queues.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.queue,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noQueues,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.queueManagement,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }

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
                      context.read<QueuesBloc>().add(
                        ToggleQueue(queue.id, enabled),
                      );
                    },
                    onDelete: () {
                      _showDeleteConfirmation(context, queue.id, queue.name);
                    },
                  );
                },
              ),
            );
          } else if (state is QueuesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.errorLoadingQueues,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.error,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<QueuesBloc>().add(const LoadQueues());
                    },
                    child: Text(l10n.confirm),
                  ),
                ],
              ),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
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