import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/simple_queue.dart';

class QueueListItem extends StatelessWidget {
  final SimpleQueue queue;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const QueueListItem({
    super.key,
    required this.queue,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  String _getPriorityLabel(BuildContext context, int priority) {
    final l10n = AppLocalizations.of(context)!;
    if (priority <= 3) return '⚡ ${l10n.priorityHighShort}';
    if (priority <= 6) return '➡️ ${l10n.priorityMediumShort}';
    return '⬇️ ${l10n.priorityLowShort}';
  }

  Color _getPriorityColor(int priority) {
    if (priority <= 3) return Colors.red;
    if (priority <= 6) return Colors.orange;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEnabled = queue.isEnabled;
    
    return Card(
      elevation: isEnabled ? 2 : 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isEnabled 
              ? Colors.cyan.shade200
              : colorScheme.outline.withAlpha(51),
          width: isEnabled ? 2 : 1,
        ),
      ),
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with name and switch
                Row(
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isEnabled 
                              ? [Colors.cyan.shade100, Colors.blue.shade100]
                              : [Colors.grey.shade200, Colors.grey.shade300],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '⚡',
                        style: TextStyle(
                          fontSize: 24,
                          color: isEnabled ? Colors.cyan.shade700 : Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Name and IP
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            queue.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isEnabled ? Colors.green : Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  queue.target,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                    fontFamily: 'monospace',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Switch
                    Transform.scale(
                      scale: 0.85,
                      child: Switch(
                        value: isEnabled,
                        onChanged: onToggle,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Speed limits in a beautiful card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade50.withValues(alpha: 0.5),
                        Colors.green.shade50.withValues(alpha: 0.5),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Download
                      Expanded(
                        child: _buildSpeedInfo(
                          context,
                          '⬇️',
                          'download',
                          queue.formattedDownloadLimit.isNotEmpty 
                              ? queue.formattedDownloadLimit 
                              : '∞',
                          Colors.green,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey.shade300,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      // Upload
                      Expanded(
                        child: _buildSpeedInfo(
                          context,
                          '⬆️',
                          'upload',
                          queue.formattedUploadLimit.isNotEmpty 
                              ? queue.formattedUploadLimit 
                              : '∞',
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Priority and comment row
                Row(
                  children: [
                    // Priority badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(queue.priority).withAlpha(26),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getPriorityColor(queue.priority).withAlpha(77),
                        ),
                      ),
                      child: Text(
                        _getPriorityLabel(context, queue.priority),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getPriorityColor(queue.priority),
                        ),
                      ),
                    ),
                    if (queue.comment.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.comment,
                              size: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                queue.comment,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.edit, size: 16),
                        label: Text(AppLocalizations.of(context)!.edit),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onDelete,
                        icon: Icon(Icons.delete, size: 16, color: Colors.red.shade400),
                        label: Text(AppLocalizations.of(context)!.delete, style: TextStyle(color: Colors.red.shade400)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.red.shade200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedInfo(BuildContext context, String emoji, String labelKey, String speed, Color color) {
    final l10n = AppLocalizations.of(context)!;
    final label = labelKey == 'download' ? l10n.download : l10n.upload;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          speed,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800]!,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
