import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../injection_container.dart';
import '../bloc/wireless_bloc.dart';
import '../bloc/wireless_state.dart';
import '../widgets/wireless_interfaces_list.dart';
import '../widgets/wireless_clients_list.dart';
import '../widgets/security_profiles_list.dart';
import '../widgets/wireless_header_widget.dart';
import '../widgets/wireless_scanner_widget.dart';
import '../widgets/access_list_widget.dart';

class WirelessPage extends StatefulWidget {
  const WirelessPage({super.key});

  @override
  State<WirelessPage> createState() => _WirelessPageState();
}

class _WirelessPageState extends State<WirelessPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WirelessBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)?.wirelessManagement ?? 'Wireless Management'),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: AppLocalizations.of(context)?.interfaces ?? 'Interfaces'),
              Tab(text: AppLocalizations.of(context)?.clients ?? 'Clients'),
              Tab(text: AppLocalizations.of(context)?.securityProfiles ?? 'Security'),
              const Tab(text: 'Scanner'),
              const Tab(text: 'Access List'),
            ],
          ),
        ),
        body: BlocBuilder<WirelessBloc, WirelessState>(
          builder: (context, state) {
            // Calculate counts from unified state
            final interfacesCount = state.interfaces.length;
            final clientsCount = state.registrations.length;
            final profilesCount = state.profiles.length;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: WirelessHeaderWidget(
                    interfacesCount: interfacesCount,
                    clientsCount: clientsCount,
                    profilesCount: profilesCount,
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      WirelessInterfacesList(),
                      WirelessClientsList(),
                      SecurityProfilesList(),
                      const WirelessScannerWidget(),
                      const AccessListWidget(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}