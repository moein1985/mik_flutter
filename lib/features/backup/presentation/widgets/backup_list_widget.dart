import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/backup_file.dart';
import '../bloc/backup_bloc.dart';
import '../bloc/backup_event.dart';

class BackupListWidget extends StatelessWidget {
  final List<BackupFile> backups;

  const BackupListWidget({super.key, required this.backups});

  @override
  Widget build(BuildContext context) {
    if (backups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.backup, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)?.noBackupsFound ?? 'No backups found'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<BackupBloc>().add(LoadBackupsEvent());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: backups.length,
        itemBuilder: (context, index) {
          final backup = backups[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.backup, color: Colors.blue),
              title: Text(backup.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Size: ${backup.size}'),
                  Text('Created: ${_formatDate(backup.created)}'),
                  Text('Type: ${backup.type}'),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) => _handleAction(context, value, backup.name),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'restore',
                    child: ListTile(
                      leading: const Icon(Icons.restore, color: Colors.green),
                      title: Text(AppLocalizations.of(context)?.restore ?? 'Restore'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: const Icon(Icons.delete, color: Colors.red),
                      title: Text(AppLocalizations.of(context)?.delete ?? 'Delete'),
                      contentPadding: EdgeInsets.zero,
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

  void _handleAction(BuildContext context, String action, String backupName) {
    switch (action) {
      case 'restore':
        _showRestoreConfirmation(context, backupName);
        break;
      case 'delete':
        _showDeleteConfirmation(context, backupName);
        break;
    }
  }

  void _showRestoreConfirmation(BuildContext context, String backupName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.confirmRestore ?? 'Confirm Restore'),
        content: Text(
          AppLocalizations.of(context)?.restoreBackupWarning ??
          'Are you sure you want to restore from "$backupName"? This will overwrite current configuration.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<BackupBloc>().add(RestoreBackupEvent(name: backupName));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)?.restore ?? 'Restore'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String backupName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.confirmDelete ?? 'Confirm Delete'),
        content: Text(
          AppLocalizations.of(context)?.deleteBackupWarning ??
          'Are you sure you want to delete "$backupName"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<BackupBloc>().add(DeleteBackupEvent(backupName));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)?.delete ?? 'Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
           '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}