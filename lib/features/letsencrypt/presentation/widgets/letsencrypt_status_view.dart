import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/letsencrypt_status.dart';
import '../bloc/letsencrypt_bloc.dart';
import '../bloc/letsencrypt_event.dart';
import 'letsencrypt_helpers.dart';

class LetsEncryptStatusView extends StatelessWidget {
  final LetsEncryptStatus status;

  const LetsEncryptStatusView({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatusCard(context, l10n, theme),
          const SizedBox(height: 24),
          _buildActionButtons(context, l10n),
          const SizedBox(height: 24),
          _buildInfoSection(l10n),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  status.hasCertificate
                      ? (status.isValid ? Icons.verified : Icons.warning)
                      : Icons.shield_outlined,
                  color: status.hasCertificate
                      ? (status.isValid ? Colors.green : Colors.orange)
                      : Colors.grey,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status.hasCertificate
                            ? l10n.letsEncryptCertificateActive
                            : l10n.letsEncryptNoCertificate,
                        style: theme.textTheme.titleMedium,
                      ),
                      if (status.dnsName != null)
                        Text(
                          status.dnsName!,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (status.hasCertificate) ...[
              const Divider(height: 24),
              LetsEncryptHelpers.buildDetailRow(
                l10n.letsEncryptCertName,
                status.certificateName ?? '-',
              ),
              LetsEncryptHelpers.buildDetailRow(
                l10n.letsEncryptExpiresAt,
                status.expiresAt != null
                    ? '${status.expiresAt!.day}/${status.expiresAt!.month}/${status.expiresAt!.year}'
                    : '-',
              ),
              if (status.daysUntilExpiry != null)
                LetsEncryptHelpers.buildDetailRow(
                  l10n.letsEncryptDaysRemaining,
                  status.daysUntilExpiry.toString(),
                  valueColor: LetsEncryptHelpers.getExpiryColor(status.daysUntilExpiry!),
                ),
              if (status.isExpiringSoon)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.letsEncryptExpiringSoon,
                          style: const TextStyle(color: Colors.orange, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AppLocalizations l10n) {
    if (status.hasCertificate) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: () => _showRevokeDialog(context, l10n, status.certificateName!),
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            label: Text(
              l10n.letsEncryptRevoke,
              style: const TextStyle(color: Colors.red),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              context.read<LetsEncryptBloc>().add(const RunPreChecks());
            },
            icon: const Icon(Icons.refresh),
            label: Text(l10n.letsEncryptRenew),
          ),
        ],
      );
    } else {
      return ElevatedButton.icon(
        onPressed: () {
          context.read<LetsEncryptBloc>().add(const RunPreChecks());
        },
        icon: const Icon(Icons.add_circle_outline),
        label: Text(l10n.letsEncryptGetCertificate),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      );
    }
  }

  Widget _buildInfoSection(AppLocalizations l10n) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  l10n.letsEncryptInfo,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.letsEncryptInfoText,
              style: TextStyle(color: Colors.blue.shade900, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  void _showRevokeDialog(BuildContext context, AppLocalizations l10n, String certName) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.warning_amber, color: Colors.red, size: 48),
          title: Text(l10n.letsEncryptRevokeTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.letsEncryptRevokeDesc),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.letsEncryptRevokeWarning,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<LetsEncryptBloc>().add(RevokeCertificate(certName));
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(l10n.letsEncryptRevoke),
            ),
          ],
        );
      },
    );
  }
}
