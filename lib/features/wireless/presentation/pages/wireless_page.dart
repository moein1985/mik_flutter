import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../injection_container.dart';
import '../bloc/wireless_bloc.dart';
import '../widgets/wireless_interfaces_list.dart';
import '../widgets/wireless_clients_list.dart';
import '../widgets/security_profiles_list.dart';

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
    _tabController = TabController(length: 3, vsync: this);
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
            tabs: [
              Tab(text: AppLocalizations.of(context)?.interfaces ?? 'Interfaces'),
              Tab(text: AppLocalizations.of(context)?.clients ?? 'Clients'),
              Tab(text: AppLocalizations.of(context)?.securityProfiles ?? 'Security Profiles'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            WirelessInterfacesList(),
            WirelessClientsList(),
            SecurityProfilesList(),
          ],
        ),
      ),
    );
  }
}