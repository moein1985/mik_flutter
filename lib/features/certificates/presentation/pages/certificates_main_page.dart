import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../injection_container.dart';
import '../../../letsencrypt/presentation/bloc/letsencrypt_bloc.dart';
import '../../../letsencrypt/presentation/pages/letsencrypt_page.dart';
import '../bloc/certificate_bloc.dart';
import 'certificates_local_ca_page.dart';

/// Main Certificates page with tabs for Local CA and Let's Encrypt
class CertificatesMainPage extends StatefulWidget {
  const CertificatesMainPage({super.key});

  @override
  State<CertificatesMainPage> createState() => _CertificatesMainPageState();
}

class _CertificatesMainPageState extends State<CertificatesMainPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.certificates),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.security),
              text: l10n.localCA,
            ),
            Tab(
              icon: const Icon(Icons.verified_user),
              text: l10n.letsEncrypt,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Local CA Tab
          BlocProvider(
            create: (_) => sl<CertificateBloc>(),
            child: const CertificatesLocalCAPage(),
          ),
          // Let's Encrypt Tab
          BlocProvider(
            create: (_) => sl<LetsEncryptBloc>(),
            child: const LetsEncryptPage(),
          ),
        ],
      ),
    );
  }
}
