import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../injection_container.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
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
import '../../features/certificates/presentation/bloc/certificate_bloc.dart';
import '../../features/certificates/presentation/pages/certificates_page.dart';
import '../../features/dhcp/presentation/bloc/dhcp_bloc.dart';
import '../../features/dhcp/presentation/pages/dhcp_page.dart';

/// Route names as constants
class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String interfaces = '/dashboard/interfaces';
  static const String ipAddresses = '/dashboard/ip-addresses';
  static const String dhcp = '/dashboard/dhcp';
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
}

/// Global navigator key for use outside of widget context
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// App router configuration using go_router
class AppRouter {
  final AuthBloc authBloc;
  late final GoRouter router;

  AppRouter({required this.authBloc}) {
    router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: AppRoutes.login,
      debugLogDiagnostics: true,
      redirect: (context, state) {
        final authState = authBloc.state;
        final isAuthenticated = authState is AuthAuthenticated;
        final isLoggingIn = state.matchedLocation == AppRoutes.login;

        // If not authenticated and not on login page, redirect to login
        if (!isAuthenticated && !isLoggingIn) {
          return AppRoutes.login;
        }

        // If authenticated and on login page, redirect to dashboard
        if (isAuthenticated && isLoggingIn) {
          return AppRoutes.dashboard;
        }

        return null;
      },
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      routes: [
        // Login Route
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),

        // Dashboard and nested routes
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
              builder: (context, state) => BlocProvider(
                create: (_) => sl<CertificateBloc>(),
                child: const CertificatesPage(),
              ),
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
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
