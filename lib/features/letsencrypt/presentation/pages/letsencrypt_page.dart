import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/letsencrypt_bloc.dart';
import '../bloc/letsencrypt_event.dart';
import '../bloc/letsencrypt_state.dart';
import '../widgets/letsencrypt_helpers.dart';
import '../widgets/letsencrypt_prechecks_view.dart';
import '../widgets/letsencrypt_status_view.dart';

class LetsEncryptPage extends StatefulWidget {
  const LetsEncryptPage({super.key});

  @override
  State<LetsEncryptPage> createState() => _LetsEncryptPageState();
}

class _LetsEncryptPageState extends State<LetsEncryptPage> {
  final TextEditingController _dnsNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<LetsEncryptBloc>().add(const LoadLetsEncryptStatus());
  }

  @override
  void dispose() {
    _dnsNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.letsEncrypt),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<LetsEncryptBloc>().add(const LoadLetsEncryptStatus());
            },
          ),
        ],
      ),
      body: BlocConsumer<LetsEncryptBloc, LetsEncryptState>(
        listener: (context, state) {
          if (state is LetsEncryptError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(LetsEncryptHelpers.getLocalizedError(
                    l10n, state.errorKey ?? state.message)),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is CertificateRequestSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.letsEncryptCertificateIssued),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AutoFixSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.letsEncryptAutoFixSuccess),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            LetsEncryptLoading(:final message) => _buildLoadingState(l10n, message),
            LetsEncryptStatusLoaded(:final status) => LetsEncryptStatusView(status: status),
            PreChecksCompleted(:final result) => LetsEncryptPreChecksView(
                result: result,
                dnsNameController: _dnsNameController,
              ),
            CertificateRequesting() => _buildRequestingState(l10n, state),
            AutoFixInProgress() => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(l10n.letsEncryptAutoFixing),
                  ],
                ),
              ),
            CertificateRequestSuccess() => _buildSuccessState(context, l10n, theme),
            LetsEncryptError() => _buildErrorState(context, l10n, theme, state),
            _ => _buildLoadingState(l10n, null),
          };
        },
      ),
    );
  }

  Widget _buildLoadingState(AppLocalizations l10n, String? message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message != null
              ? LetsEncryptHelpers.getLocalizedMessage(l10n, message)
              : l10n.loading),
        ],
      ),
    );
  }

  Widget _buildRequestingState(AppLocalizations l10n, CertificateRequesting state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              l10n.letsEncryptRequesting,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(state.dnsName, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withAlpha(77)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.info_outline, color: Colors.amber),
                  const SizedBox(height: 8),
                  Text(
                    l10n.letsEncryptRequestingInfo,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.letsEncryptCertificateIssued,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.letsEncryptSuccessDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.read<LetsEncryptBloc>().add(const LoadLetsEncryptStatus());
              },
              icon: const Icon(Icons.visibility),
              label: Text(l10n.viewCertificate),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    LetsEncryptError state,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              LetsEncryptHelpers.getLocalizedError(
                  l10n, state.errorKey ?? state.message),
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<LetsEncryptBloc>().add(const LoadLetsEncryptStatus());
              },
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
