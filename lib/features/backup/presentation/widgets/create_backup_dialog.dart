import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/backup_bloc.dart';
import '../bloc/backup_event.dart';

class CreateBackupDialog extends StatefulWidget {
  const CreateBackupDialog({super.key});

  @override
  State<CreateBackupDialog> createState() => _CreateBackupDialogState();
}

class _CreateBackupDialogState extends State<CreateBackupDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)?.createBackup ?? 'Create Backup'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)?.backupName ?? 'Backup Name',
                hintText: 'e.g., config_backup_2024',
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)?.backupNameRequired ?? 'Backup name is required';
                }
                if (value.contains(' ')) {
                  return AppLocalizations.of(context)?.backupNameNoSpaces ?? 'Backup name cannot contain spaces';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)?.backupDescription ??
              'Create a backup of the current RouterOS configuration.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createBackup,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(AppLocalizations.of(context)?.create ?? 'Create'),
        ),
      ],
    );
  }

  void _createBackup() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final backupName = _nameController.text.trim();
    context.read<BackupBloc>().add(CreateBackupEvent(name: backupName));

    // Close dialog after a short delay to allow the operation to start
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }
}