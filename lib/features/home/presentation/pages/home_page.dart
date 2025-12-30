import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../injection_container.dart' as di;
import '../../../../modules/_shared/base_device_module.dart';
import '../../../app_auth/presentation/bloc/app_auth_bloc.dart';
import '../../../app_auth/presentation/bloc/app_auth_event.dart';
import '../../domain/entities/app_module.dart';
import '../widgets/module_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  List<AppModule> _getModulesFromRegistry(AppLocalizations l10n) {
    // Get registered modules from dependency injection
    final registeredModules = di.sl<List<BaseDeviceModule>>();
    
    // Convert BaseDeviceModule to AppModule for backwards compatibility
    return registeredModules.map((module) {
      return AppModule(
        name: module.displayName,
        nameKey: module.id,
        icon: module.icon,
        route: module.getRouteBasePath(),
        isEnabled: !module.isBeta, // Enable non-beta modules
        description: module.description,
        color: module.primaryColor,
      );
    }).toList();
  }

  List<AppModule> _getFallbackModules(AppLocalizations l10n) {
    // Fallback to hardcoded modules if registry fails
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
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    // Try to get modules from registry, fallback to hardcoded if fails
    List<AppModule> modules;
    try {
      modules = _getModulesFromRegistry(l10n);
    } catch (e) {
      debugPrint('Failed to get modules from registry: $e');
      modules = _getFallbackModules(l10n);
    }

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
