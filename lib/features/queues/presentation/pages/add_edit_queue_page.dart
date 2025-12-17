import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/queues_bloc.dart';
import '../bloc/queues_event.dart';
import '../bloc/queues_state.dart';

/// Speed limit template for quick setup
class SpeedLimitTemplate {
  final String name;
  final String emoji;
  final String downloadSpeed;
  final String uploadSpeed;
  final int priority;
  final String description;

  const SpeedLimitTemplate({
    required this.name,
    required this.emoji,
    required this.downloadSpeed,
    required this.uploadSpeed,
    required this.priority,
    required this.description,
  });
}

class AddEditQueuePage extends StatefulWidget {
  final String? queueId;

  const AddEditQueuePage({super.key, this.queueId});

  @override
  State<AddEditQueuePage> createState() => _AddEditQueuePageState();
}

class _AddEditQueuePageState extends State<AddEditQueuePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _downloadController = TextEditingController();
  final _uploadController = TextEditingController();
  final _commentController = TextEditingController();

  int _selectedPriority = 5; // متوسط
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    debugPrint('[AddEditQueuePage] 🟢 Init with queueId: ${widget.queueId}');
    if (widget.queueId != null) {
      debugPrint('[AddEditQueuePage] 🟢 Loading queue for edit: ${widget.queueId}');
      context.read<QueuesBloc>().add(LoadQueueForEdit(widget.queueId!));
    } else {
      debugPrint('[AddEditQueuePage] 🟢 New queue mode');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _downloadController.dispose();
    _uploadController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _populateForm(dynamic queue) {
    debugPrint('[AddEditQueuePage] 📋 Populating form with queue data:');
    debugPrint('  - name: ${queue.name}');
    debugPrint('  - priority: ${queue.priority}');
    debugPrint('  - upload: ${queue.formattedUploadLimit}');
    debugPrint('  - download: ${queue.formattedDownloadLimit}');
    
    _nameController.text = queue.name;
    _targetController.text = queue.target;
    _downloadController.text = queue.formattedDownloadLimit;
    _uploadController.text = queue.formattedUploadLimit;
    _commentController.text = queue.comment;
    setState(() {
      _selectedPriority = queue.priority;
    });
  }

  void _saveQueue() {
    debugPrint('[AddEditQueuePage] 💾 Save button pressed');
    if (!_formKey.currentState!.validate()) {
      debugPrint('[AddEditQueuePage] ❌ Validation failed');
      return;
    }

    setState(() => _isLoading = true);
    debugPrint('[AddEditQueuePage] 💾 Saving queue...');

    final uploadLimit = _uploadController.text.trim();
    final downloadLimit = _downloadController.text.trim();
    
    final queueData = {
      'name': _nameController.text.trim(),
      'target': _targetController.text.trim(),
      'priority': _selectedPriority.toString(),
      'comment': _commentController.text.trim(),
    };
    
    // Only add max-limit if both upload and download are provided
    if (uploadLimit.isNotEmpty && downloadLimit.isNotEmpty) {
      queueData['max-limit'] = '$uploadLimit/$downloadLimit';
    }

    if (widget.queueId != null) {
      context.read<QueuesBloc>().add(UpdateQueue(widget.queueId!, queueData));
    } else {
      context.read<QueuesBloc>().add(AddQueue(queueData));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final isEditing = widget.queueId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editSpeedLimit : l10n.addSpeedLimit),
      ),
      body: BlocConsumer<QueuesBloc, QueuesState>(
        listener: (context, state) {
          if (state is QueueOperationSuccess) {
            Navigator.of(context).pop(true);
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // راهنمای سریع
                  _buildQuickGuide(l10n, colorScheme),
                  const SizedBox(height: 24),

                  // 1️⃣ نام
                  _buildSectionTitle('1️⃣ ${l10n.nameLabel}'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: l10n.nameExample,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.label),
                    ),
                    validator: (value) {
                      if (value?.trim().isEmpty ?? true) {
                        return l10n.nameRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // 2️⃣ IP یا شبکه
                  _buildSectionTitle('2️⃣ ${l10n.targetLabel}'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _targetController,
                    decoration: InputDecoration(
                      hintText: l10n.targetExample,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.devices),
                    ),
                    validator: (value) {
                      if (value?.trim().isEmpty ?? true) {
                        return l10n.targetRequired;
                      }
                      // Simple IP validation: X.X.X.X or X.X.X.X/Y
                      final ipRegex = RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(\/\d{1,2})?$');
                      if (!ipRegex.hasMatch(value!.trim())) {
                        return l10n.invalidIPFormat;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // 3️⃣ محدودیت سرعت
                  _buildSectionTitle('3️⃣ ${l10n.speedLimit}'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // دانلود
                      Expanded(
                        child: TextFormField(
                          controller: _downloadController,
                          decoration: InputDecoration(
                            labelText: '⬇️ ${l10n.download}',
                            hintText: '10M',
                            border: const OutlineInputBorder(),
                            suffixText: 'bps',
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9kKmMgG]')),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // آپلود
                      Expanded(
                        child: TextFormField(
                          controller: _uploadController,
                          decoration: InputDecoration(
                            labelText: '⬆️ ${l10n.upload}',
                            hintText: '5M',
                            border: const OutlineInputBorder(),
                            suffixText: 'bps',
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9kKmMgG]')),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 4️⃣ اولویت
                  _buildSectionTitle('4️⃣ ${l10n.priorityLabel}'),
                  const SizedBox(height: 12),
                  _buildPrioritySelector(),
                  const SizedBox(height: 20),

                  // توضیحات (اختیاری)
                  _buildSectionTitle('💬 ${l10n.commentOptional}'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: l10n.commentHint,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.comment),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 32),

                  // دکمه ذخیره
                  FilledButton.icon(
                    onPressed: _isLoading ? null : _saveQueue,
                    icon: _isLoading 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check),
                    label: Text(
                      _isLoading ? l10n.saving : l10n.save,
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.all(16),
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

  Widget _buildQuickGuide(AppLocalizations l10n, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.cyan.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                l10n.quickGuide,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildGuideRow('🎯', l10n.singleDevice, '192.168.1.100'),
          const SizedBox(height: 6),
          _buildGuideRow('🌐', l10n.networkDevices, '192.168.1.0/24'),
          const SizedBox(height: 6),
          _buildGuideRow('⚡', l10n.speedUnits, '512k, 5M, 100M'),
        ],
      ),
    );
  }

  Widget _buildGuideRow(String emoji, String label, String example) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: example,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrioritySelector() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          _buildPriorityOption(
            value: 2,
            emoji: '⚡',
            label: l10n.priorityHigh,
            description: l10n.priorityHighDesc,
            color: Colors.red,
          ),
          const SizedBox(height: 8),
          _buildPriorityOption(
            value: 5,
            emoji: '➡️',
            label: l10n.priorityMedium,
            description: l10n.priorityMediumDesc,
            color: Colors.orange,
          ),
          const SizedBox(height: 8),
          _buildPriorityOption(
            value: 8,
            emoji: '⬇️',
            label: l10n.priorityLow,
            description: l10n.priorityLowDesc,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityOption({
    required int value,
    required String emoji,
    required String label,
    required String description,
    required Color color,
  }) {
    final isSelected = _selectedPriority == value;
    
    return InkWell(
      onTap: () {
        debugPrint('[AddEditQueuePage] 🎯 Priority changed: $_selectedPriority → $value ($label)');
        setState(() => _selectedPriority = value);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(26) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : Colors.grey.shade400,
                  width: 2,
                ),
                color: isSelected ? color : Colors.transparent,
              ),
              child: isSelected 
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected ? color : Colors.black87,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
