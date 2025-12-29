import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../app_auth/presentation/bloc/app_auth_bloc.dart';
import '../../../app_auth/presentation/bloc/app_auth_event.dart';
import '../../domain/entities/app_module.dart';
import '../widgets/module_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  List<AppModule> _getModules(AppLocalizations l10n) {
    return [
      AppModule(
        name: 'MikroTik Assist',
        nameKey: 'mikrotikAssist',
        icon: Icons.router,
        route: AppRoutes.mikrotik,
        isEnabled: true,
        description: l10n.mikrotikAssistDescription,
        color: Colors.blue,
      ),
      AppModule(
        name: 'SNMP Assist',
        nameKey: 'snmpAssist',
        icon: Icons.devices,
        route: AppRoutes.snmp,
        isEnabled: true,
        description: l10n.snmpAssistDescription,
        color: Colors.green,
      ),
      const AppModule(
        name: 'Asterisk PBX',
        nameKey: 'asteriskPbx',
        icon: Icons.phone,
        route: null,
        isEnabled: false,
        description: 'VoIP Phone System Management',
        color: Colors.orange,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final modules = _getModules(l10n);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        centerTitle: true,
        actions: [
          IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  context.push(AppRoutes.settings);
                },
                tooltip: l10n.settings,
              ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Show confirmation dialog
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
            tooltip: l10n.logout,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.welcomeToNetworkAssistant,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.selectModuleToStart,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWideScreen = constraints.maxWidth > 600;
                    
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isWideScreen ? 3 : 1,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: isWideScreen ? 1.0 : 1.2,
                      ),
                      itemCount: modules.length,
                      itemBuilder: (context, index) {
                        final module = modules[index];
                        return ModuleTile(
                          module: module,
                          onTap: module.route != null
                              ? () => context.push(module.route!)
                              : null,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
