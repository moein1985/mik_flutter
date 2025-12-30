import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../injection_container.dart';
import '../utils/logger.dart';
import '../../features/app_auth/presentation/bloc/app_auth_bloc.dart';
import '../../features/app_auth/presentation/bloc/app_auth_state.dart';
import '../../features/app_auth/presentation/pages/app_login_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/change_password_page.dart';
import '../../features/snmp/presentation/bloc/snmp_monitor_bloc.dart';
import '../../features/snmp/presentation/pages/snmp_dashboard_page.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/dashboard/presentation/pages/interfaces_page.dart';
import '../../features/dashboard/presentation/pages/ip_addresses_page.dart';
import '../../features/hotspot/presentation/bloc/hotspot_bloc.dart';
import '../../features/hotspot/presentation/pages/hotspot_page.dart';
import '../../features/hotspot/presentation/pages/hotspot_users_page.dart';
import '../../features/hotspot/presentation/pages/hotspot_active_users_page.dart';
import '../../features/hotspot/presentation/pages/hotspot_servers_page.dart';
import '../../features/hotspot/presentation/pages/hotspot_profiles_page.dart';
import '../../features/hotspot/presentation/pages/hotspot_ip_bindings_page.dart';
import '../../features/hotspot/presentation/pages/hotspot_hosts_page.dart';
import '../../features/hotspot/presentation/pages/hotspot_walled_garden_page.dart';
import '../../features/firewall/presentation/bloc/firewall_bloc.dart';
import '../../features/firewall/presentation/pages/firewall_page.dart';
import '../../features/firewall/presentation/pages/firewall_rules_page.dart';
import '../../features/firewall/presentation/pages/firewall_address_list_page.dart';
import '../../features/firewall/domain/entities/firewall_rule.dart';
import '../../features/ip_services/presentation/bloc/ip_service_bloc.dart';
import '../../features/ip_services/presentation/pages/ip_services_page.dart';
import '../../features/certificates/presentation/pages/certificates_main_page.dart';
import '../../features/letsencrypt/presentation/bloc/letsencrypt_bloc.dart';
import '../../features/letsencrypt/presentation/pages/letsencrypt_page.dart';
import '../../features/dhcp/presentation/bloc/dhcp_bloc.dart';
import '../../features/dhcp/presentation/pages/dhcp_page.dart';
import '../../features/cloud/presentation/bloc/cloud_bloc.dart';
import '../../features/cloud/presentation/pages/cloud_page.dart';
import '../../features/tools/presentation/pages/tools_page.dart';
import '../../features/tools/presentation/pages/ping_page.dart';
import '../../features/tools/presentation/pages/traceroute_page.dart';
import '../../features/tools/presentation/pages/dns_lookup_page.dart';
import '../../features/tools/presentation/bloc/tools_bloc.dart';
import '../../features/queues/presentation/bloc/queues_bloc.dart';
import '../../features/queues/presentation/pages/queues_page.dart';
import '../../features/queues/presentation/pages/add_edit_queue_page.dart';
import '../../features/wireless/presentation/bloc/wireless_bloc.dart';
import '../../features/wireless/presentation/pages/wireless_page.dart';
import '../../features/logs/presentation/bloc/logs_bloc.dart';
import '../../features/logs/presentation/pages/logs_page.dart';
import '../../features/backup/presentation/bloc/backup_bloc.dart';
import '../../features/backup/presentation/pages/backup_page.dart';
import '../../features/about/presentation/pages/about_page.dart';
import '../../features/subscription/presentation/pages/subscription_page.dart';

/// Route names as constants
class AppRoutes {
  static const String appLogin = '/app-login';
  static const String login = '/login';
  static const String home = '/';
  static const String settings = '/settings';
  static const String profile = '/settings/profile';
  static const String changePassword = '/settings/change-password';
  static const String mikrotik = '/mikrotik';
  static const String snmp = '/snmp';
  static const String dashboard = '/dashboard';
  static const String interfaces = '/dashboard/interfaces';
  static const String ipAddresses = '/dashboard/ip-addresses';
  static const String dhcp = '/dashboard/dhcp';
  static const String cloud = '/dashboard/cloud';
  static const String hotspot = '/dashboard/hotspot';
  static const String hotspotUsers = '/dashboard/hotspot/users';
  static const String hotspotActiveUsers = '/dashboard/hotspot/active-users';
  static const String hotspotServers = '/dashboard/hotspot/servers';
  static const String hotspotProfiles = '/dashboard/hotspot/profiles';
  static const String hotspotIpBindings = '/dashboard/hotspot/ip-bindings';
  static const String hotspotHosts = '/dashboard/hotspot/hosts';
  static const String hotspotWalledGarden = '/dashboard/hotspot/walled-garden';
  static const String firewall = '/dashboard/firewall';
  static const String firewallRules = '/dashboard/firewall/rules';
  static const String firewallAddressList = '/dashboard/firewall/address-list';
  static const String services = '/dashboard/services';
  static const String certificates = '/dashboard/certificates';
  static const String letsencrypt = '/dashboard/certificates/letsencrypt';
  static const String tools = '/dashboard/tools';
  static const String toolsPing = '/dashboard/tools/ping';
  static const String toolsTraceroute = '/dashboard/tools/traceroute';
  static const String toolsDnsLookup = '/dashboard/tools/dns-lookup';
  static const String queues = '/dashboard/queues';
  static const String addQueue = '/dashboard/queues/add';
  static const String editQueue = '/dashboard/queues/edit/:id';
  static const String wireless = '/dashboard/wireless';
  static const String logs = '/dashboard/logs';
  static const String backup = '/dashboard/backup';
  static const String about = '/dashboard/about';
  static const String subscription = '/subscription';
  static const String dashboardSubscription = '/dashboard/subscription';
}

/// Global navigator key for use outside of widget context
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// App router configuration using go_router
class AppRouter {
  final AppAuthBloc appAuthBloc;
  final AuthBloc authBloc;
  final _log = AppLogger.tag('AppRouter');
  late final GoRouter router;

  AppRouter({required this.appAuthBloc, required this.authBloc}) {
    router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: AppRoutes.home,
      debugLogDiagnostics: true,
      redirect: (context, state) {
        final appAuthState = appAuthBloc.state;
        final isAppAuthenticated = appAuthState is AppAuthAuthenticated;
        final isOnAppLogin = state.matchedLocation == AppRoutes.appLogin;
        _log.i('Redirect check: matched=${state.matchedLocation}, appAuth=${appAuthState.runtimeType}, isAppAuthenticated=$isAppAuthenticated, isOnAppLogin=$isOnAppLogin');

        // App-level authentication check
        if (!isAppAuthenticated && !isOnAppLogin) {
          _log.i('Redirecting to AppLogin');
          return AppRoutes.appLogin;
        }
        if (isAppAuthenticated && isOnAppLogin) {
          _log.i('Authenticated and on app login - redirect to home');
          return AppRoutes.home;
        }

        // Router-level authentication check (for MikroTik pages only)
        final authState = authBloc.state;
        final isRouterAuthenticated = authState is AuthAuthenticated;
        final isLoggingIn = state.matchedLocation == AppRoutes.login;
        final isOnSubscription = state.matchedLocation == AppRoutes.subscription;
        
        // Only check router auth for mikrotik and dashboard routes
        final needsRouterAuth = state.matchedLocation.startsWith('/dashboard') || 
                               state.matchedLocation == AppRoutes.mikrotik;

        _log.i('Router auth check: needsRouterAuth=$needsRouterAuth, authState=${authState.runtimeType}, isRouterAuthenticated=$isRouterAuthenticated');

        if (needsRouterAuth && !isRouterAuthenticated && !isLoggingIn && !isOnSubscription) {
          _log.i('Redirecting to router login');
          return AppRoutes.login;
        }

        // Redirect to mikrotik after successful authentication
        if (isRouterAuthenticated && (isLoggingIn || state.matchedLocation == '/')) {
          _log.i('Router authenticated - redirect to mikrotik (from ${state.matchedLocation})');
          return AppRoutes.mikrotik;
        }

        return null;
      },
      refreshListenable: GoRouterRefreshStream([appAuthBloc.stream, authBloc.stream]),
      routes: [
        // App Login Route
        GoRoute(
          path: AppRoutes.appLogin,
          name: 'appLogin',
          builder: (context, state) => const AppLoginPage(),
        ),

        // Router Login Route
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),

        // Subscription Route (public)
        GoRoute(
          path: AppRoutes.subscription,
          name: 'subscription',
          builder: (context, state) => const SubscriptionPage(),
        ),

        // Home Route (main dashboard with module tiles)
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),

        // Settings Route
        GoRoute(
          path: AppRoutes.settings,
          name: 'settings',
          builder: (context, state) => const SettingsPage(),
        ),

        // Profile Route
        GoRoute(
          path: AppRoutes.profile,
          name: 'profile',
          builder: (context, state) => const ProfilePage(),
        ),

        // Change Password Route
        GoRoute(
          path: AppRoutes.changePassword,
          name: 'changePassword',
          builder: (context, state) => const ChangePasswordPage(),
        ),

        // MikroTik Section (current dashboard)
        GoRoute(
          path: AppRoutes.mikrotik,
          name: 'mikrotik',
          builder: (context, state) => const DashboardPage(),
        ),

        // SNMP Section
        GoRoute(
          path: AppRoutes.snmp,
          name: 'snmp',
          builder: (context, state) => BlocProvider(
            create: (_) => sl<SnmpMonitorBloc>(),
            child: const SnmpDashboardPage(),
          ),
        ),

        // Dashboard and nested routes (keeping old routes for compatibility)
        GoRoute(
          path: AppRoutes.dashboard,
          name: 'dashboard',
          builder: (context, state) => const DashboardPage(),
          routes: [
            // Interfaces
            GoRoute(
              path: 'interfaces',
              name: 'interfaces',
              builder: (context, state) => BlocProvider.value(
                value: context.read<DashboardBloc>(),
                child: const InterfacesPage(),
              ),
            ),

            // IP Addresses
            GoRoute(
              path: 'ip-addresses',
              name: 'ip-addresses',
              builder: (context, state) => BlocProvider.value(
                value: context.read<DashboardBloc>(),
                child: const IpAddressesPage(),
              ),
            ),

            // Services
            GoRoute(
              path: 'services',
              name: 'services',
              builder: (context, state) => BlocProvider(
                create: (_) => sl<IpServiceBloc>(),
                child: const IpServicesPage(),
              ),
            ),

            // Certificates
            GoRoute(
              path: 'certificates',
              name: 'certificates',
              builder: (context, state) => const CertificatesMainPage(),
              routes: [
                // Let's Encrypt (standalone route for direct navigation)
                GoRoute(
                  path: 'letsencrypt',
                  name: 'letsencrypt',
                  builder: (context, state) => BlocProvider(
                    create: (_) => sl<LetsEncryptBloc>(),
                    child: const LetsEncryptPage(),
                  ),
                ),
              ],
            ),

            // HotSpot and nested routes
            GoRoute(
              path: 'hotspot',
              name: 'hotspot',
              builder: (context, state) => BlocProvider(
                create: (_) => sl<HotspotBloc>(),
                child: const HotspotPage(),
              ),
              routes: [
                GoRoute(
                  path: 'users',
                  name: 'hotspot-users',
                  builder: (context, state) {
                    final hotspotBloc = state.extra as HotspotBloc?;
                    if (hotspotBloc != null) {
                      return BlocProvider.value(
                        value: hotspotBloc,
                        child: const HotspotUsersPage(),
                      );
                    }
                    return BlocProvider(
                      create: (_) => sl<HotspotBloc>(),
                      child: const HotspotUsersPage(),
                    );
                  },
                ),
                GoRoute(
                  path: 'active-users',
                  name: 'hotspot-active-users',
                  builder: (context, state) {
                    final hotspotBloc = state.extra as HotspotBloc?;
                    if (hotspotBloc != null) {
                      return BlocProvider.value(
                        value: hotspotBloc,
                        child: const HotspotActiveUsersPage(),
                      );
                    }
                    return BlocProvider(
                      create: (_) => sl<HotspotBloc>(),
                      child: const HotspotActiveUsersPage(),
                    );
                  },
                ),
                GoRoute(
                  path: 'servers',
                  name: 'hotspot-servers',
                  builder: (context, state) {
                    final hotspotBloc = state.extra as HotspotBloc?;
                    if (hotspotBloc != null) {
                      return BlocProvider.value(
                        value: hotspotBloc,
                        child: const HotspotServersPage(),
                      );
                    }
                    return BlocProvider(
                      create: (_) => sl<HotspotBloc>(),
                      child: const HotspotServersPage(),
                    );
                  },
                ),
                GoRoute(
                  path: 'profiles',
                  name: 'hotspot-profiles',
                  builder: (context, state) {
                    final hotspotBloc = state.extra as HotspotBloc?;
                    if (hotspotBloc != null) {
                      return BlocProvider.value(
                        value: hotspotBloc,
                        child: const HotspotProfilesPage(),
                      );
                    }
                    return BlocProvider(
                      create: (_) => sl<HotspotBloc>(),
                      child: const HotspotProfilesPage(),
                    );
                  },
                ),
                GoRoute(
                  path: 'ip-bindings',
                  name: 'hotspot-ip-bindings',
                  builder: (context, state) {
                    final hotspotBloc = state.extra as HotspotBloc?;
                    if (hotspotBloc != null) {
                      return BlocProvider.value(
                        value: hotspotBloc,
                        child: const HotspotIpBindingsPage(),
                      );
                    }
                    return BlocProvider(
                      create: (_) => sl<HotspotBloc>(),
                      child: const HotspotIpBindingsPage(),
                    );
                  },
                ),
                GoRoute(
                  path: 'hosts',
                  name: 'hotspot-hosts',
                  builder: (context, state) {
                    final hotspotBloc = state.extra as HotspotBloc?;
                    if (hotspotBloc != null) {
                      return BlocProvider.value(
                        value: hotspotBloc,
                        child: const HotspotHostsPage(),
                      );
                    }
                    return BlocProvider(
                      create: (_) => sl<HotspotBloc>(),
                      child: const HotspotHostsPage(),
                    );
                  },
                ),
                GoRoute(
                  path: 'walled-garden',
                  name: 'hotspot-walled-garden',
                  builder: (context, state) {
                    final hotspotBloc = state.extra as HotspotBloc?;
                    if (hotspotBloc != null) {
                      return BlocProvider.value(
                        value: hotspotBloc,
                        child: const HotspotWalledGardenPage(),
                      );
                    }
                    return BlocProvider(
                      create: (_) => sl<HotspotBloc>(),
                      child: const HotspotWalledGardenPage(),
                    );
                  },
                ),
              ],
            ),

            // DHCP Server route
            GoRoute(
              path: 'dhcp',
              name: 'dhcp',
              builder: (context, state) => BlocProvider(
                create: (_) => sl<DhcpBloc>(),
                child: const DhcpPage(),
              ),
            ),

            // Cloud route
            GoRoute(
              path: 'cloud',
              name: 'cloud',
              builder: (context, state) => BlocProvider(
                create: (_) => sl<CloudBloc>(),
                child: const CloudPage(),
              ),
            ),

            // Tools route
            GoRoute(
              path: 'tools',
              name: 'tools',
              builder: (context, state) => BlocProvider(
                create: (_) => sl<ToolsBloc>(),
                child: const ToolsPage(),
              ),
              routes: [
                GoRoute(
                  path: 'ping',
                  name: 'tools-ping',
                  builder: (context, state) => BlocProvider(
                    create: (_) => sl<ToolsBloc>(),
                    child: const PingPage(),
                  ),
                ),
                GoRoute(
                  path: 'traceroute',
                  name: 'tools-traceroute',
                  builder: (context, state) => BlocProvider(
                    create: (_) => sl<ToolsBloc>(),
                    child: const TraceroutePage(),
                  ),
                ),
                GoRoute(
                  path: 'dns-lookup',
                  name: 'tools-dns-lookup',
                  builder: (context, state) => BlocProvider(
                    create: (_) => sl<ToolsBloc>(),
                    child: const DnsLookupPage(),
                  ),
                ),
              ],
            ),

            // Queues route
            GoRoute(
              path: 'queues',
              name: 'queues',
              builder: (context, state) => BlocProvider(
                create: (_) => sl<QueuesBloc>(),
                child: const QueuesPage(),
              ),
              routes: [
                GoRoute(
                  path: 'add',
                  name: 'add-queue',
                  builder: (context, state) => BlocProvider(
                    create: (_) => sl<QueuesBloc>(),
                    child: const AddEditQueuePage(),
                  ),
                ),
                GoRoute(
                  path: 'edit/:id',
                  name: 'edit-queue',
                  builder: (context, state) {
                    final queueId = state.pathParameters['id']!;
                    return BlocProvider(
                      create: (_) => sl<QueuesBloc>(),
                      child: AddEditQueuePage(queueId: queueId),
                    );
                  },
                ),
              ],
            ),

            // Wireless route
            GoRoute(
              path: 'wireless',
              name: 'wireless',
              builder: (context, state) => BlocProvider(
                create: (_) => sl<WirelessBloc>(),
                child: const WirelessPage(),
              ),
            ),

            // Logs route
            GoRoute(
              path: 'logs',
              name: 'logs',
              builder: (context, state) => BlocProvider(
                create: (_) => sl<LogsBloc>(),
                child: const LogsPage(),
              ),
            ),

            // Backup route
            GoRoute(
              path: 'backup',
              name: 'backup',
              builder: (context, state) => BlocProvider(
                create: (_) => sl<BackupBloc>(),
                child: const BackupPage(),
              ),
            ),

            // About route
            GoRoute(
              path: 'about',
              name: 'about',
              builder: (context, state) => const AboutPage(),
            ),

            // Subscription route (nested under dashboard)
            GoRoute(
              path: 'subscription',
              name: 'dashboard-subscription',
              builder: (context, state) => const SubscriptionPage(),
            ),

            // Firewall and nested routes
            GoRoute(
              path: 'firewall',
              name: 'firewall',
              builder: (context, state) => BlocProvider(
                create: (_) => sl<FirewallBloc>(),
                child: const FirewallPage(),
              ),
              routes: [
                GoRoute(
                  path: 'rules/:type',
                  name: 'firewall-rules',
                  builder: (context, state) {
                    final typeString = state.pathParameters['type'] ?? 'filter';
                    final type = FirewallRuleType.values.firstWhere(
                      (e) => e.name == typeString,
                      orElse: () => FirewallRuleType.filter,
                    );
                    final firewallBloc = state.extra as FirewallBloc?;
                    if (firewallBloc != null) {
                      return BlocProvider.value(
                        value: firewallBloc,
                        child: FirewallRulesPage(type: type),
                      );
                    }
                    return BlocProvider(
                      create: (_) => sl<FirewallBloc>(),
                      child: FirewallRulesPage(type: type),
                    );
                  },
                ),
                GoRoute(
                  path: 'address-list',
                  name: 'firewall-address-list',
                  builder: (context, state) {
                    final firewallBloc = state.extra as FirewallBloc?;
                    if (firewallBloc != null) {
                      return BlocProvider.value(
                        value: firewallBloc,
                        child: const FirewallAddressListPage(),
                      );
                    }
                    return BlocProvider(
                      create: (_) => sl<FirewallBloc>(),
                      child: const FirewallAddressListPage(),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Page not found: ${state.uri}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.login),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper class to refresh GoRouter when auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(List<Stream<dynamic>> streams) {
    notifyListeners();
    _subscriptions = streams.map((stream) => stream.listen((_) => notifyListeners())).toList();
  }

  late final List<dynamic> _subscriptions;

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}
