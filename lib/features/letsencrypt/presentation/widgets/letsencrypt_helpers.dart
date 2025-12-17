import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/precheck_result.dart';

/// Helper functions for Let's Encrypt UI
class LetsEncryptHelpers {
  static String getCheckTitle(AppLocalizations l10n, PreCheckType type) {
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

  static String getLocalizedMessage(AppLocalizations l10n, String key) {
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

  static String getLocalizedError(AppLocalizations l10n, String key) {
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
        if (key.startsWith('acmeGenericError:')) {
          final errorDetail = key.substring('acmeGenericError:'.length);
          return l10n.letsEncryptErrorAcmeGeneric(errorDetail);
        }
        return key;
    }
  }

  static Color getExpiryColor(int days) {
    if (days < 0) return Colors.red;
    if (days < 14) return Colors.red;
    if (days < 30) return Colors.orange;
    return Colors.green;
  }

  static Widget buildDetailRow(String label, String value, {Color? valueColor}) {
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
}
