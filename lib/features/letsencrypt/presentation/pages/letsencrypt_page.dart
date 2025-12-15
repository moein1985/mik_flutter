import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/letsencrypt_status.dart';
import '../../domain/entities/precheck_result.dart';
import '../bloc/letsencrypt_bloc.dart';
import '../bloc/letsencrypt_event.dart';
import '../bloc/letsencrypt_state.dart';

class LetsEncryptPage extends StatefulWidget {
  const LetsEncryptPage({super.key});

  @override
  State<LetsEncryptPage> createState() => _LetsEncryptPageState();
}

class _LetsEncryptPageState extends State<LetsEncryptPage> {
  @override
  void initState() {
    super.initState();
    context.read<LetsEncryptBloc>().add(const LoadLetsEncryptStatus());
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
                content: Text(_getLocalizedError(l10n, state.errorKey ?? state.message)),
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
            LetsEncryptStatusLoaded(:final status) => _buildStatusView(context, l10n, theme, status),
            PreChecksCompleted(:final result) => _buildPreChecksView(context, l10n, theme, result),
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

  Widget _buildSuccessState(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
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
              _getLocalizedError(l10n, state.errorKey ?? state.message),
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

  Widget _buildLoadingState(AppLocalizations l10n, String? message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message != null ? _getLocalizedMessage(l10n, message) : l10n.loading),
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

  Widget _buildStatusView(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    LetsEncryptStatus status,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status card
          Card(
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
                    _buildDetailRow(l10n.letsEncryptCertName, status.certificateName ?? '-'),
                    _buildDetailRow(
                      l10n.letsEncryptExpiresAt,
                      status.expiresAt != null
                          ? '${status.expiresAt!.day}/${status.expiresAt!.month}/${status.expiresAt!.year}'
                          : '-',
                    ),
                    if (status.daysUntilExpiry != null)
                      _buildDetailRow(
                        l10n.letsEncryptDaysRemaining,
                        status.daysUntilExpiry.toString(),
                        valueColor: _getExpiryColor(status.daysUntilExpiry!),
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
          ),

          const SizedBox(height: 24),

          // Action buttons
          if (status.hasCertificate) ...[
            OutlinedButton.icon(
              onPressed: () => _showRevokeDialog(context, l10n, status.certificateName!),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: Text(l10n.letsEncryptRevoke, style: const TextStyle(color: Colors.red)),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                context.read<LetsEncryptBloc>().add(const RunPreChecks());
              },
              icon: const Icon(Icons.refresh),
              label: Text(l10n.letsEncryptRenew),
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: () {
                context.read<LetsEncryptBloc>().add(const RunPreChecks());
              },
              icon: const Icon(Icons.add_circle_outline),
              label: Text(l10n.letsEncryptGetCertificate),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Info section
          Card(
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
          ),
        ],
      ),
    );
  }

  Widget _buildPreChecksView(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    PreCheckResult result,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(
            l10n.letsEncryptPreChecks,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.letsEncryptPreChecksDesc,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          // DNS Name if available
          if (result.dnsName != null) ...[
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.dns, color: Colors.green.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.letsEncryptDnsName,
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            result.dnsName!,
                            style: TextStyle(color: Colors.green.shade900),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Checks list
          Card(
            child: Column(
              children: result.checks.map((check) {
                return _buildCheckItem(context, l10n, check);
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // Action buttons
          if (result.allPassed) ...[
            ElevatedButton.icon(
              onPressed: result.dnsName != null
                  ? () {
                      context.read<LetsEncryptBloc>().add(
                            RequestCertificate(dnsName: result.dnsName!),
                          );
                    }
                  : null,
              icon: const Icon(Icons.security),
              label: Text(l10n.letsEncryptRequestNow),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ] else if (result.hasAutoFixableIssues) ...[
            ElevatedButton.icon(
              onPressed: () {
                // Fix all auto-fixable issues at once
                final checkTypes = result.autoFixableChecks.map((c) => c.type).toList();
                context.read<LetsEncryptBloc>().add(AutoFixAll(checkTypes));
              },
              icon: const Icon(Icons.auto_fix_high),
              label: Text(l10n.letsEncryptAutoFixAll),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],

          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: () {
              context.read<LetsEncryptBloc>().add(const RunPreChecks());
            },
            icon: const Icon(Icons.refresh),
            label: Text(l10n.letsEncryptRecheck),
          ),

          const SizedBox(height: 12),

          TextButton(
            onPressed: () {
              context.read<LetsEncryptBloc>().add(const LoadLetsEncryptStatus());
            },
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(BuildContext context, AppLocalizations l10n, PreCheckItem check) {
    final passed = check.passed;
    final canFix = check.canAutoFix && !passed;

    return ListTile(
      leading: Icon(
        passed ? Icons.check_circle : Icons.error,
        color: passed ? Colors.green : Colors.red,
      ),
      title: Text(_getCheckTitle(l10n, check.type)),
      subtitle: !passed && check.errorMessage != null
          ? Text(
              _getLocalizedError(l10n, check.errorMessage!),
              style: const TextStyle(color: Colors.red, fontSize: 12),
            )
          : null,
      trailing: canFix
          ? TextButton(
              onPressed: () {
                context.read<LetsEncryptBloc>().add(AutoFixIssue(check.type));
              },
              child: Text(l10n.letsEncryptFix),
            )
          : null,
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getExpiryColor(int days) {
    if (days < 0) return Colors.red;
    if (days < 14) return Colors.red;
    if (days < 30) return Colors.orange;
    return Colors.green;
  }

  String _getCheckTitle(AppLocalizations l10n, PreCheckType type) {
    switch (type) {
      case PreCheckType.cloudEnabled:
        return l10n.letsEncryptCheckCloud;
      case PreCheckType.dnsAvailable:
        return l10n.letsEncryptCheckDns;
      case PreCheckType.port80Accessible:
        return l10n.letsEncryptCheckPort80;
      case PreCheckType.firewallRule:
        return l10n.letsEncryptCheckFirewall;
      case PreCheckType.natRule:
        return l10n.letsEncryptCheckNat;
      case PreCheckType.www:
        return l10n.letsEncryptCheckWww;
    }
  }

  String _getLocalizedMessage(AppLocalizations l10n, String key) {
    switch (key) {
      case 'loadingStatus':
        return l10n.letsEncryptLoadingStatus;
      case 'runningPreChecks':
        return l10n.letsEncryptRunningPreChecks;
      case 'requestingCertificate':
        return l10n.letsEncryptRequesting;
      default:
        return key;
    }
  }

  String _getLocalizedError(AppLocalizations l10n, String key) {
    switch (key) {
      case 'cloudDdnsNotEnabled':
        return l10n.letsEncryptErrorCloudNotEnabled;
      case 'dnsNameNotAvailable':
        return l10n.letsEncryptErrorDnsNotAvailable;
      case 'port80BlockedByFirewall':
        return l10n.letsEncryptErrorPort80Blocked;
      case 'wwwServiceNotOnPort80':
        return l10n.letsEncryptErrorWwwNotOnPort80;
      case 'wwwServiceCheckFailed':
        return l10n.letsEncryptErrorWwwCheckFailed;
      case 'natRuleBlockingPort80':
        return l10n.letsEncryptErrorNatRule;
      case 'loadStatusFailed':
        return l10n.letsEncryptErrorLoadFailed;
      case 'preChecksFailed':
        return l10n.letsEncryptErrorPreChecksFailed;
      case 'autoFixFailed':
        return l10n.letsEncryptErrorAutoFixFailed;
      case 'certificateRequestFailed':
        return l10n.letsEncryptErrorRequestFailed;
      case 'revokeFailed':
        return l10n.letsEncryptErrorRevokeFailed;
      // ACME/Let's Encrypt specific errors
      case 'acmeConnectionFailed':
        return l10n.letsEncryptErrorAcmeConnectionFailed;
      case 'acmeDnsResolutionFailed':
        return l10n.letsEncryptErrorAcmeDnsResolutionFailed;
      case 'acmeSslUpdateFailed':
        return l10n.letsEncryptErrorAcmeSslUpdateFailed;
      case 'acmeRateLimited':
        return l10n.letsEncryptErrorAcmeRateLimited;
      case 'acmeAuthorizationFailed':
        return l10n.letsEncryptErrorAcmeAuthorizationFailed;
      case 'acmeChallengeValidationFailed':
        return l10n.letsEncryptErrorAcmeChallengeValidationFailed;
      case 'acmeTimeout':
        return l10n.letsEncryptErrorAcmeTimeout;
      default:
        // Handle generic ACME errors with details
        if (key.startsWith('acmeGenericError:')) {
          final errorDetail = key.substring('acmeGenericError:'.length);
          return l10n.letsEncryptErrorAcmeGeneric(errorDetail);
        }
        return key;
    }
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
