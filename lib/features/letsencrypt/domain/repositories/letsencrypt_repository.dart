import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/letsencrypt_status.dart';
import '../entities/precheck_result.dart';
import '../entities/acme_provider.dart';

abstract class LetsEncryptRepository {
  /// Get current Let's Encrypt certificate status
  Future<Either<Failure, LetsEncryptStatus>> getStatus();

  /// Run all pre-flight checks before requesting a certificate
  Future<Either<Failure, PreCheckResult>> runPreChecks();

  /// Auto-fix a specific issue (e.g., add firewall rule for port 80)
  Future<Either<Failure, bool>> autoFix(PreCheckType checkType);

  /// Request a Let's Encrypt certificate
  /// [dnsName] - The DNS name for the certificate
  /// [provider] - ACME provider (defaults to Let's Encrypt)
  Future<Either<Failure, bool>> requestCertificate({
    required String dnsName,
    AcmeProvider provider = AcmeProvider.letsEncrypt,
  });

  /// Add temporary firewall rule to allow port 80 for ACME challenge
  Future<Either<Failure, String>> addTemporaryFirewallRule();

  /// Remove temporary firewall rule after certificate is issued
  Future<Either<Failure, bool>> removeTemporaryFirewallRule(String ruleId);

  /// Check if port 80 is accessible from WAN
  /// This tries to determine if port 80 is reachable for ACME challenge
  Future<Either<Failure, bool>> checkPort80Accessible();

  /// Revoke/delete Let's Encrypt certificate
  Future<Either<Failure, bool>> revokeCertificate(String certificateName);
}
