import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../../../../injection_container.dart';
import '../bloc/dhcp_bloc.dart';
import '../bloc/dhcp_event.dart';
import '../bloc/dhcp_state.dart';
import 'dhcp_servers_page.dart';
import 'dhcp_networks_page.dart';
import 'dhcp_leases_page.dart';

final _log = AppLogger.tag('DhcpPage');

class DhcpPage extends StatelessWidget {
  const DhcpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DhcpBloc(repository: sl())..add(const LoadDhcpServers()),
      child: const DhcpPageContent(),
    );
  }
}

class DhcpPageContent extends StatefulWidget {
  const DhcpPageContent({super.key});

  @override
  State<DhcpPageContent> createState() => _DhcpPageContentState();
}

class _DhcpPageContentState extends State<DhcpPageContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _loadTabData(_tabController.index);
    }
  }

  void _loadTabData(int index) {
    final bloc = context.read<DhcpBloc>();
    switch (index) {
      case 0:
        bloc.add(const LoadDhcpServers());
        break;
      case 1:
        bloc.add(const LoadDhcpNetworks());
        break;
      case 2:
        bloc.add(const LoadDhcpLeases());
        break;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DhcpBloc, DhcpState>(
      listener: (context, state) {
        if (state is DhcpOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is DhcpError) {
          _log.e('DHCP error: ${state.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('DHCP Server'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Servers', icon: Icon(Icons.dns)),
              Tab(text: 'Networks', icon: Icon(Icons.lan)),
              Tab(text: 'Leases', icon: Icon(Icons.assignment)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () => _loadTabData(_tabController.index),
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            DhcpServersTab(),
            DhcpNetworksTab(),
            DhcpLeasesTab(),
          ],
        ),
      ),
    );
  }
}
