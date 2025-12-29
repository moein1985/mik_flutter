import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../app_auth/presentation/bloc/app_auth_bloc.dart';
import '../../../app_auth/presentation/bloc/app_auth_event.dart';
import '../cubit/settings_cubit.dart';
import '../../../../main.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../injection_container.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => SettingsCubit()..loadSettings(),
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final settingsCubit = context.read<SettingsCubit>();

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
                    value: state.biometricEnabled,
                    onChanged: (value) async {
                      final localAuth = LocalAuthentication();
                      try {
                        if (value) {
                          final canCheck = await localAuth.canCheckBiometrics || await localAuth.isDeviceSupported();
                          if (!canCheck) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.biometricComingSoon)),
                            );
                            return;
                          }
                          final didAuth = await localAuth.authenticate(
                            localizedReason: l10n.biometricAuthDescription,
                            options: const AuthenticationOptions(biometricOnly: true),
                          );
                          if (!didAuth) {
                            return;
                          }
                        }
                        await settingsCubit.setBiometricEnabled(value);

                        // Guard using context after async gaps
                        if (!context.mounted) return;

                        // Also notify AppAuthBloc to enable/disable biometric for current user
                        try {
                          context.read<AppAuthBloc>().add(BiometricToggleRequested(value));
                        } catch (_) {
                          // AppAuthBloc might not be available in some contexts
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(value ? l10n.enabled : l10n.disabled)),
                        );
                      } catch (e) {
                        // Avoid using context after async gaps when widget may be unmounted
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.error)),
                        );
                      }
                    },
                  ),
                ),
                const Divider(),

                // App Settings Section
                _buildSectionHeader(context, l10n.settings),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(l10n.language),
                  subtitle: Text(state.localeCode == 'fa' ? l10n.persian : l10n.english),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final selected = await showDialog<String?>(
                      context: context,
                      builder: (context) => SimpleDialog(
                        title: Text(l10n.changeLanguage),
                        children: [
                          SimpleDialogOption(
                            onPressed: () => Navigator.of(context).pop('en'),
                            child: Text(l10n.english),
                          ),
                          SimpleDialogOption(
                            onPressed: () => Navigator.of(context).pop('fa'),
                            child: Text(l10n.persian),
                          ),
                        ],
                      ),
                    );

                    if (selected != null && selected != state.localeCode) {
                      await settingsCubit.setLocale(selected);
                      if (!context.mounted) return;
                      MyApp.of(context)?.setLocale(Locale(selected));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${l10n.changeLanguage}: ${selected == 'fa' ? l10n.persian : l10n.english}')),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.palette),
                  title: Text(l10n.theme),
                  subtitle: Text(state.themeMode == 'light' ? l10n.light : state.themeMode == 'dark' ? l10n.dark : l10n.system),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final selected = await showDialog<String?>(
                      context: context,
                      builder: (context) => SimpleDialog(
                        title: Text(l10n.theme),
                        children: [
                          SimpleDialogOption(
                            onPressed: () => Navigator.of(context).pop('system'),
                            child: Text(l10n.system),
                          ),
                          SimpleDialogOption(
                            onPressed: () => Navigator.of(context).pop('light'),
                            child: Text(l10n.light),
                          ),
                          SimpleDialogOption(
                            onPressed: () => Navigator.of(context).pop('dark'),
                            child: Text(l10n.dark),
                          ),
                        ],
                      ),
                    );

                    if (selected != null && selected != state.themeMode) {
                      await settingsCubit.setThemeMode(selected);
                      if (!context.mounted) return;
                      // apply theme globally
                      if (selected == 'system') {
                        (MyApp.of(context) as dynamic)?.setThemeMode(ThemeMode.system);
                      } else if (selected == 'light') {
                        (MyApp.of(context) as dynamic)?.setThemeMode(ThemeMode.light);
                      } else {
                        (MyApp.of(context) as dynamic)?.setThemeMode(ThemeMode.dark);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${l10n.changeTheme}: ${selected == 'system' ? l10n.system : selected == 'light' ? l10n.light : l10n.dark}')),
                      );
                    }
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
              context.push(AppRoutes.profile);
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: Text(l10n.changePassword),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push(AppRoutes.changePassword);
            },
          ),
          const Divider(),

          // About Section
          _buildSectionHeader(context, l10n.about),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(l10n.aboutApp),
            subtitle: FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                final ver = snapshot.data?.version ?? '?';
                return Text('${l10n.version} $ver');
              },
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final info = await PackageInfo.fromPlatform();
              if (!context.mounted) return;
              showAboutDialog(
                context: context,
                applicationName: l10n.appName,
                applicationVersion: info.version,
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
                        onPressed: () async {
                          Navigator.of(dialogContext).pop();
                          // Clear secure storage credentials and local settings
                          try {
                            await sl<FlutterSecureStorage>().delete(key: 'credentials');
                          } catch (_) {}
                          try {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.remove('biometricEnabled');
                          } catch (_) {}

                          if (!context.mounted) return;
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
        },
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
