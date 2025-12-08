import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../injection_container.dart';
import '../bloc/backup_bloc.dart';
import '../bloc/backup_event.dart';
import '../bloc/backup_state.dart';
import '../widgets/backup_list_widget.dart';
import '../widgets/create_backup_dialog.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  @override
  void initState() {
    super.initState();
    // Load backups when page opens
    context.read<BackupBloc>().add(LoadBackupsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BackupBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)?.backupRestore ?? 'Backup & Restore'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showCreateBackupDialog(context),
              tooltip: AppLocalizations.of(context)?.createBackup ?? 'Create Backup',
            ),
          ],
        ),
        body: BlocConsumer<BackupBloc, BackupState>(
          listener: (context, state) {
            if (state is BackupOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is BackupError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is BackupLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is BackupLoaded) {
              return BackupListWidget(backups: state.backups);
            } else if (state is BackupError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<BackupBloc>().add(LoadBackupsEvent()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text('No data'));
          },
        ),
      ),
    );
  }

  void _showCreateBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateBackupDialog(),
    );
  }
}