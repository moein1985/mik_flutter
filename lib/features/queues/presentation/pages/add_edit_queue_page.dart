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

  List<SpeedLimitTemplate> _getTemplates(AppLocalizations l10n) {
    return [
      SpeedLimitTemplate(
        name: l10n.templateRegularUser,
        emoji: '📱',
        downloadSpeed: '5M',
        uploadSpeed: '2M',
        priority: 5,
        description: l10n.templateRegularUserDesc,
      ),
      SpeedLimitTemplate(
        name: l10n.templateGuestNetwork,
        emoji: '🏠',
        downloadSpeed: '3M',
        uploadSpeed: '1M',
        priority: 7,
        description: l10n.templateGuestNetworkDesc,
      ),
      SpeedLimitTemplate(
        name: l10n.templateVIPUser,
        emoji: '💼',
        downloadSpeed: '20M',
        uploadSpeed: '10M',
        priority: 3,
        description: l10n.templateVIPUserDesc,
      ),
      SpeedLimitTemplate(
        name: l10n.templateServer,
        emoji: '🖥️',
        downloadSpeed: '50M',
        uploadSpeed: '20M',
        priority: 2,
        description: l10n.templateServerDesc,
      ),
      SpeedLimitTemplate(
        name: l10n.templateCamera,
        emoji: '📹',
        downloadSpeed: '2M',
        uploadSpeed: '512k',
        priority: 2,
        description: l10n.templateCameraDesc,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    if (widget.queueId != null) {
      context.read<QueuesBloc>().add(LoadQueueForEdit(widget.queueId!));
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

  void _applyTemplate(SpeedLimitTemplate template) {
    setState(() {
      _nameController.text = template.name;
      _downloadController.text = template.downloadSpeed;
      _uploadController.text = template.uploadSpeed;
      _selectedPriority = template.priority;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${template.emoji} قالب "${template.name}" اعمال شد'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _populateForm(dynamic queue) {
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final queueData = {
      'name': _nameController.text.trim(),
      'target': _targetController.text.trim(),
      'max-limit-download': _downloadController.text.trim(),
      'max-limit-upload': _uploadController.text.trim(),
      'priority': _selectedPriority.toString(),
      'comment': _commentController.text.trim(),
    };

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
        title: Row(
          children: [
            const Text('⚡'),
            const SizedBox(width: 8),
            Text(isEditing ? l10n.editSpeedLimit : l10n.addSpeedLimit),
          ],
        ),
      ),
      body: BlocConsumer<QueuesBloc, QueuesState>(
        listener: (context, state) {
          if (state is QueueOperationSuccess) {
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // قالب‌های آماده
                  if (!isEditing) ...[
                    _buildTemplatesSection(l10n, colorScheme),
                    const SizedBox(height: 24),
                    Divider(color: colorScheme.outline.withAlpha(77)),
                    const SizedBox(height: 24),
                  ],

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
                      final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}(\/\d{1,2})?$');
                      if (!ipRegex.hasMatch(value!)) {
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

  Widget _buildTemplatesSection(AppLocalizations l10n, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('✨', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.readyTemplates,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          l10n.templatesDescription,
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _getTemplates(l10n).map((template) => _buildTemplateChip(template)).toList(),
        ),
      ],
    );
  }

  Widget _buildTemplateChip(SpeedLimitTemplate template) {
    return ActionChip(
      avatar: Text(template.emoji, style: const TextStyle(fontSize: 18)),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            template.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            '⬇️${template.downloadSpeed} ⬆️${template.uploadSpeed}',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
      onPressed: () => _applyTemplate(template),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
      onTap: () => setState(() => _selectedPriority = value),
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
