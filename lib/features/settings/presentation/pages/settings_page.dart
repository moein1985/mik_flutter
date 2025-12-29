import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../app_auth/presentation/bloc/app_auth_bloc.dart';
import '../../../app_auth/presentation/bloc/app_auth_event.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // Biometric Settings Section
          _buildSectionHeader(context, l10n.biometricAuthentication),
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: Text(l10n.enableBiometricAuth),
            subtitle: Text(l10n.biometricAuthDescription),
            trailing: Switch(
              value: false, // TODO: Get from settings
              onChanged: (value) {
                // TODO: Implement biometric toggle
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.biometricComingSoon),
                  ),
                );
              },
            ),
          ),
          const Divider(),

          // App Settings Section
          _buildSectionHeader(context, l10n.settings),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            subtitle: Text(l10n.persian),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement language selector
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.changeLanguage + ' ' + l10n.comingSoon),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.palette),
            title: Text(l10n.theme),
            subtitle: Text(l10n.light),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement theme selector
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.changeTheme + ' ' + l10n.comingSoon),
                ),
              );
            },
          ),
          const Divider(),

          // Account Section
          _buildSectionHeader(context, l10n.account),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(l10n.profile),
            subtitle: Text(l10n.profileDescription),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to profile page
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.profileComingSoon),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: Text(l10n.changePassword),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to change password page
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.changePasswordComingSoon),
                ),
              );
            },
          ),
          const Divider(),

          // About Section
          _buildSectionHeader(context, l10n.about),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(l10n.aboutApp),
            subtitle: Text('${l10n.version} 1.0.1+6'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: l10n.appName,
                applicationVersion: '1.0.1+6',
                applicationLegalese: '© 2025 All rights reserved',
                children: [
                  const SizedBox(height: 16),
                  Text(l10n.aboutAppDescription),
                ],
              );
            },
          ),
          const Divider(),

          // Logout Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: Text(l10n.logout),
                    content: Text(l10n.logoutConfirmation),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: Text(l10n.cancel),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          context.read<AppAuthBloc>().add(const LogoutRequested());
                        },
                        child: Text(l10n.logout),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout),
              label: Text(l10n.logout),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
