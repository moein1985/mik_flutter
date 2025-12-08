import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/queues_bloc.dart';
import '../bloc/queues_event.dart';
import '../bloc/queues_state.dart';

class AddEditQueuePage extends StatefulWidget {
  final String? queueId; // null for add, not null for edit

  const AddEditQueuePage({super.key, this.queueId});

  @override
  State<AddEditQueuePage> createState() => _AddEditQueuePageState();
}

class _AddEditQueuePageState extends State<AddEditQueuePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _maxLimitController = TextEditingController();
  final _burstLimitController = TextEditingController();
  final _burstThresholdController = TextEditingController();
  final _burstTimeController = TextEditingController();
  final _priorityController = TextEditingController(text: '8');
  final _parentController = TextEditingController();
  final _commentController = TextEditingController();

  // Advanced settings
  final _limitAtController = TextEditingController();
  final _queueTypeController = TextEditingController(text: 'default');
  final _totalQueueLimitController = TextEditingController();
  final _totalMaxLimitController = TextEditingController();
  final _totalBurstLimitController = TextEditingController();
  final _totalBurstThresholdController = TextEditingController();
  final _totalBurstTimeController = TextEditingController();
  final _totalLimitAtController = TextEditingController();
  final _bucketSizeController = TextEditingController();

  bool _showAdvancedSettings = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.queueId != null) {
      // Load existing queue data for editing
      context.read<QueuesBloc>().add(LoadQueueForEdit(widget.queueId!));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _maxLimitController.dispose();
    _burstLimitController.dispose();
    _burstThresholdController.dispose();
    _burstTimeController.dispose();
    _priorityController.dispose();
    _parentController.dispose();
    _commentController.dispose();
    _limitAtController.dispose();
    _queueTypeController.dispose();
    _totalQueueLimitController.dispose();
    _totalMaxLimitController.dispose();
    _totalBurstLimitController.dispose();
    _totalBurstThresholdController.dispose();
    _totalBurstTimeController.dispose();
    _totalLimitAtController.dispose();
    _bucketSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.queueId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Queue' : l10n.addQueue),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveQueue,
              child: Text(
                l10n.saveQueue,
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: BlocConsumer<QueuesBloc, QueuesState>(
        listener: (context, state) {
          if (state is QueueOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isEditing ? l10n.queueUpdated : l10n.queueAdded),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is QueuesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
            setState(() => _isLoading = false);
          } else if (state is QueueLoadedForEdit) {
            _populateForm(state.queue);
          }
        },
        builder: (context, state) {
          if (state is QueuesLoading && widget.queueId != null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Settings
                  _buildSectionTitle('Basic Settings'),
                  const SizedBox(height: 16),

                  // Name
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l10n.queueName,
                      hintText: 'e.g., Office Network',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Queue name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Target
                  TextFormField(
                    controller: _targetController,
                    decoration: InputDecoration(
                      labelText: l10n.target,
                      hintText: 'e.g., 192.168.1.0/24 or 192.168.1.100',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Target is required';
                      }
                      // Basic IP/Subnet validation
                      final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}(\/\d{1,2})?$');
                      if (!ipRegex.hasMatch(value!)) {
                        return 'Invalid IP address or subnet format';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Max Limit
                  TextFormField(
                    controller: _maxLimitController,
                    decoration: InputDecoration(
                      labelText: l10n.maxLimit,
                      hintText: 'e.g., 10M or 1000k',
                      border: const OutlineInputBorder(),
                      suffixText: 'bits/s',
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9kKmMgG]')),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Priority
                  DropdownButtonFormField<String>(
                    value: _priorityController.text,
                    decoration: InputDecoration(
                      labelText: l10n.priority,
                      border: const OutlineInputBorder(),
                    ),
                    items: List.generate(8, (index) {
                      final priority = (index + 1).toString();
                      return DropdownMenuItem(
                        value: priority,
                        child: Text('Priority $priority'),
                      );
                    }),
                    onChanged: (value) {
                      _priorityController.text = value ?? '8';
                    },
                  ),
                  const SizedBox(height: 16),

                  // Comment
                  TextFormField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      labelText: 'Comment',
                      hintText: 'Optional description',
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),

                  // Burst Settings
                  _buildSectionTitle('Burst Settings (Optional)'),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _burstLimitController,
                          decoration: InputDecoration(
                            labelText: l10n.burstLimit,
                            hintText: 'e.g., 20M',
                            border: const OutlineInputBorder(),
                            suffixText: 'bits/s',
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9kKmMgG]')),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _burstThresholdController,
                          decoration: InputDecoration(
                            labelText: l10n.burstThreshold,
                            hintText: 'e.g., 5M',
                            border: const OutlineInputBorder(),
                            suffixText: 'bits/s',
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9kKmMgG]')),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _burstTimeController,
                    decoration: InputDecoration(
                      labelText: l10n.burstTime,
                      hintText: 'e.g., 8s',
                      border: const OutlineInputBorder(),
                      suffixText: 'seconds',
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9s]')),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Advanced Settings Toggle
                  ExpansionTile(
                    title: Text(l10n.advancedSettings),
                    initiallyExpanded: _showAdvancedSettings,
                    onExpansionChanged: (expanded) {
                      setState(() => _showAdvancedSettings = expanded);
                    },
                    children: [
                      const SizedBox(height: 16),
                      // Advanced fields would go here
                      TextFormField(
                        controller: _limitAtController,
                        decoration: InputDecoration(
                          labelText: l10n.limitAt,
                          hintText: 'Advanced limit setting',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _queueTypeController,
                        decoration: InputDecoration(
                          labelText: l10n.queueType,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _bucketSizeController,
                        decoration: InputDecoration(
                          labelText: l10n.bucketSize,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveQueue,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(l10n.saveQueue),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _populateForm(dynamic queue) {
    // This would populate the form with existing queue data
    // For now, we'll leave it empty as the queue structure needs to be defined
    _nameController.text = queue.name ?? '';
    _targetController.text = queue.target ?? '';
    _maxLimitController.text = queue.maxLimit ?? '';
    _priorityController.text = queue.priority?.toString() ?? '8';
    _commentController.text = queue.comment ?? '';
  }

  void _saveQueue() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Create queue data map
    final queueData = {
      'name': _nameController.text.trim(),
      'target': _targetController.text.trim(),
      'max-limit': _maxLimitController.text.isNotEmpty ? _maxLimitController.text : '0',
      'priority': _priorityController.text,
      if (_commentController.text.isNotEmpty) 'comment': _commentController.text.trim(),
      if (_burstLimitController.text.isNotEmpty) 'burst-limit': _burstLimitController.text,
      if (_burstThresholdController.text.isNotEmpty) 'burst-threshold': _burstThresholdController.text,
      if (_burstTimeController.text.isNotEmpty) 'burst-time': _burstTimeController.text,
    };

    if (widget.queueId != null) {
      // Edit existing queue
      context.read<QueuesBloc>().add(UpdateQueue(widget.queueId!, queueData));
    } else {
      // Add new queue
      context.read<QueuesBloc>().add(AddQueue(queueData));
    }
  }
}