import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/backup_file.dart';
import '../bloc/backup_bloc.dart';
import '../bloc/backup_event.dart';
import '../bloc/backup_state.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  final _backupNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _exportNameController = TextEditingController();
  
  bool _showAdvancedOptions = false;
  bool _dontEncrypt = true;
  bool _compactExport = true;
  bool _showSensitive = false;
  bool _isCreating = false;
  bool _isExporting = false;

  @override
  void dispose() {
    _backupNameController.dispose();
    _passwordController.dispose();
    _exportNameController.dispose();
    super.dispose();
  }

  String _generateDefaultName() {
    final now = DateTime.now();
    return 'backup_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
  }

  void _createBackup(BuildContext context) {
    final name = _backupNameController.text.trim().isEmpty 
        ? _generateDefaultName() 
        : _backupNameController.text.trim();
    
    if (name.contains(' ')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backup name cannot contain spaces'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() => _isCreating = true);
    
    context.read<BackupBloc>().add(CreateBackupEvent(
      name: name,
      password: _dontEncrypt ? null : _passwordController.text,
      dontEncrypt: _dontEncrypt,
    ));
  }

  void _exportConfig(BuildContext context) {
    final fileName = _exportNameController.text.trim().isEmpty 
        ? 'export_${_generateDefaultName()}' 
        : _exportNameController.text.trim();
    
    setState(() => _isExporting = true);
    
    context.read<BackupBloc>().add(ExportConfigEvent(
      fileName: fileName,
      compact: _compactExport,
      showSensitive: _showSensitive,
    ));
  }

  void _showRestoreDialog(BuildContext blocContext, BackupFile backup) {
    final passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.restore, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            const Text('Restore Backup'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Warning: The router will reboot after restore!',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Restore from: ${backup.name}'),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password (if encrypted)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              blocContext.read<BackupBloc>().add(RestoreBackupEvent(
                name: backup.name,
                password: passwordController.text.isEmpty ? null : passwordController.text,
              ));
            },
            icon: const Icon(Icons.restore),
            label: const Text('Restore'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext blocContext, BackupFile backup) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.delete_forever, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Delete Backup'),
          ],
        ),
        content: Text('Are you sure you want to delete "${backup.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              blocContext.read<BackupBloc>().add(DeleteBackupEvent(backup.name));
            },
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocProvider(
      create: (_) => sl<BackupBloc>()..add(LoadBackupsEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n?.backupRestore ?? 'Backup & Restore'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<BackupBloc>().add(LoadBackupsEvent());
              },
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: BlocConsumer<BackupBloc, BackupState>(
          listener: (context, state) {
            if (state is BackupOperationSuccess) {
              setState(() {
                _isCreating = false;
                _isExporting = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              // Clear inputs
              _backupNameController.clear();
              _exportNameController.clear();
              _passwordController.clear();
            } else if (state is BackupError) {
              setState(() {
                _isCreating = false;
                _isExporting = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is BackupLoaded) {
              setState(() {
                _isCreating = false;
                _isExporting = false;
              });
            }
          },
          builder: (context, state) {
            List<BackupFile> backups = [];
            if (state is BackupLoaded) {
              backups = state.backups;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Quick Tip Card
                  _buildQuickTipCard(colorScheme),
                  
                  const SizedBox(height: 16),
                  
                  // Create Backup Section
                  _buildCreateBackupCard(context, colorScheme, l10n),
                  
                  const SizedBox(height: 16),
                  
                  // Advanced Options
                  _buildAdvancedOptionsCard(colorScheme, l10n),
                  
                  const SizedBox(height: 16),
                  
                  // Export Config Section
                  _buildExportConfigCard(context, colorScheme, l10n),
                  
                  const SizedBox(height: 24),
                  
                  // Backup List Section
                  _buildBackupListSection(context, state, backups, colorScheme, l10n),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickTipCard(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Create regular backups before making major changes. Binary backups (.backup) include all settings, while exports (.rsc) are text-based and editable.',
              style: TextStyle(
                color: Colors.blue.shade800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateBackupCard(BuildContext context, ColorScheme colorScheme, AppLocalizations? l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.backup, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n?.createBackup ?? 'Create Backup',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _backupNameController,
              enabled: !_isCreating,
              decoration: InputDecoration(
                labelText: l10n?.backupName ?? 'Backup Name',
                hintText: 'Leave empty for auto-generated name',
                prefixIcon: const Icon(Icons.label_outline),
                border: const OutlineInputBorder(),
                suffixIcon: _backupNameController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _backupNameController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isCreating ? null : () => _createBackup(context),
                icon: _isCreating 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save),
                label: Text(_isCreating 
                    ? 'Creating...' 
                    : (l10n?.createBackup ?? 'Create Backup')),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedOptionsCard(ColorScheme colorScheme, AppLocalizations? l10n) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.tune),
            title: Text(l10n?.advancedOptions ?? 'Advanced Options'),
            subtitle: Text(l10n?.forAdvancedUsers ?? 'Encryption settings'),
            trailing: Icon(
              _showAdvancedOptions 
                  ? Icons.keyboard_arrow_up 
                  : Icons.keyboard_arrow_down,
            ),
            onTap: () => setState(() => _showAdvancedOptions = !_showAdvancedOptions),
          ),
          if (_showAdvancedOptions) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CheckboxListTile(
                    title: const Text('Don\'t Encrypt'),
                    subtitle: const Text('Faster backup creation without encryption'),
                    value: _dontEncrypt,
                    onChanged: (value) => setState(() => _dontEncrypt = value ?? true),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  if (!_dontEncrypt) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Encryption Password',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                        helperText: 'Required for encrypted backups',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExportConfigCard(BuildContext context, ColorScheme colorScheme, AppLocalizations? l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description_outlined, color: Colors.teal.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Export Config (.rsc)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Export configuration as text file (editable)',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _exportNameController,
              enabled: !_isExporting,
              decoration: const InputDecoration(
                labelText: 'Export File Name',
                hintText: 'Leave empty for auto-generated name',
                prefixIcon: Icon(Icons.file_present),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Compact'),
                    subtitle: const Text('Only modified'),
                    value: _compactExport,
                    onChanged: (value) => setState(() => _compactExport = value ?? true),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Sensitive'),
                    subtitle: const Text('Include passwords'),
                    value: _showSensitive,
                    onChanged: (value) => setState(() => _showSensitive = value ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isExporting ? null : () => _exportConfig(context),
                icon: _isExporting 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload_file),
                label: Text(_isExporting ? 'Exporting...' : 'Export Config'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: Colors.teal.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupListSection(
    BuildContext context,
    BackupState state,
    List<BackupFile> backups,
    ColorScheme colorScheme,
    AppLocalizations? l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.folder_open, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Available Backups (${backups.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (state is BackupLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          )
        else if (backups.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.backup_outlined, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      l10n?.noBackupsFound ?? 'No backups found',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first backup above',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...backups.map((backup) => _buildBackupItem(context, backup, colorScheme)),
      ],
    );
  }

  Widget _buildBackupItem(BuildContext context, BackupFile backup, ColorScheme colorScheme) {
    final isBackupFile = backup.type == 'backup' || backup.name.endsWith('.backup');
    final isRscFile = backup.name.endsWith('.rsc');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isBackupFile 
                ? Colors.blue.shade50 
                : (isRscFile ? Colors.teal.shade50 : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isBackupFile 
                ? Icons.backup 
                : (isRscFile ? Icons.description : Icons.insert_drive_file),
            color: isBackupFile 
                ? Colors.blue.shade700 
                : (isRscFile ? Colors.teal.shade700 : Colors.grey.shade700),
          ),
        ),
        title: Text(
          backup.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.storage, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(backup.size, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(backup.created),
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isBackupFile) ...[
              IconButton(
                icon: Icon(Icons.restore, color: Colors.orange.shade700),
                onPressed: () => _showRestoreDialog(context, backup),
                tooltip: 'Restore',
              ),
            ],
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _showDeleteDialog(context, backup),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}