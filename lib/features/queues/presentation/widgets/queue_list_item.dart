import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
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
                        Text(
                          queue.target,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Switch(
                        value: queue.isEnabled,
                        onChanged: onToggle,
                        activeColor: Colors.green,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildLimitChip(
                    '↑ ${queue.formattedUploadLimit}',
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildLimitChip(
                    '↓ ${queue.formattedDownloadLimit}',
                    Colors.green,
                  ),
                  if (queue.priority != 8) ...[
                    const SizedBox(width: 8),
                    _buildLimitChip(
                      'P${queue.priority}',
                      Colors.orange,
                    ),
                  ],
                ],
              ),
              if (queue.comment.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  queue.comment,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLimitChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}