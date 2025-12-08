import 'package:flutter/material.dart';
import '../../domain/entities/log_entry.dart';

class LogEntryWidget extends StatelessWidget {
  final LogEntry logEntry;

  const LogEntryWidget({
    super.key,
    required this.logEntry,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColorForLevel(logEntry.level);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    logEntry.topics ?? 'Unknown',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  logEntry.time ?? '',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              logEntry.message ?? '',
              style: const TextStyle(fontSize: 14),
            ),
            if (logEntry.level != null) ...[
              const SizedBox(height: 4),
              Text(
                'Level: ${logEntry.level!.displayName}',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getColorForLevel(LogLevel? level) {
    switch (level) {
      case LogLevel.info:
        return Colors.blue;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.error:
        return Colors.red;
      case LogLevel.critical:
        return Colors.red[900]!;
      case LogLevel.debug:
        return Colors.grey;
      case LogLevel.unknown:
      default:
        return Colors.grey;
    }
  }
}