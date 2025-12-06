import 'package:equatable/equatable.dart';

/// Individual requirement check result
class PreCheckItem extends Equatable {
  final PreCheckType type;
  final bool passed;
  final String? errorMessage;
  final bool canAutoFix;

  const PreCheckItem({
    required this.type,
    required this.passed,
    this.errorMessage,
    this.canAutoFix = false,
  });

  @override
  List<Object?> get props => [type, passed, errorMessage, canAutoFix];

  PreCheckItem copyWith({
    PreCheckType? type,
    bool? passed,
    String? errorMessage,
    bool? canAutoFix,
  }) {
    return PreCheckItem(
      type: type ?? this.type,
      passed: passed ?? this.passed,
      errorMessage: errorMessage ?? this.errorMessage,
      canAutoFix: canAutoFix ?? this.canAutoFix,
    );
  }
}

/// Types of pre-checks for Let's Encrypt
enum PreCheckType {
  cloudEnabled,      // Check if Cloud DDNS is enabled
  dnsAvailable,      // Check if DNS name is assigned
  port80Accessible,  // Check if port 80 can be accessed from WAN
  firewallRule,      // Check if firewall allows port 80
  natRule,           // Check if NAT redirect exists for port 80
  www,               // Check if www service is not using port 80
}

/// Result of all pre-flight checks before Let's Encrypt request
class PreCheckResult extends Equatable {
  final List<PreCheckItem> checks;
  final String? dnsName; // Cloud DNS name if available
  final String? publicIp; // Router's public IP if available
  final bool allPassed;
  final bool hasAutoFixableIssues;

  const PreCheckResult({
    required this.checks,
    this.dnsName,
    this.publicIp,
    required this.allPassed,
    required this.hasAutoFixableIssues,
  });

  /// Get a specific check result
  PreCheckItem? getCheck(PreCheckType type) {
    try {
      return checks.firstWhere((c) => c.type == type);
    } catch (_) {
      return null;
    }
  }

  /// Get all failed checks
  List<PreCheckItem> get failedChecks => checks.where((c) => !c.passed).toList();

  /// Get auto-fixable failed checks
  List<PreCheckItem> get autoFixableChecks => 
      checks.where((c) => !c.passed && c.canAutoFix).toList();

  @override
  List<Object?> get props => [checks, dnsName, publicIp, allPassed, hasAutoFixableIssues];

  PreCheckResult copyWith({
    List<PreCheckItem>? checks,
    String? dnsName,
    String? publicIp,
    bool? allPassed,
    bool? hasAutoFixableIssues,
  }) {
    return PreCheckResult(
      checks: checks ?? this.checks,
      dnsName: dnsName ?? this.dnsName,
      publicIp: publicIp ?? this.publicIp,
      allPassed: allPassed ?? this.allPassed,
      hasAutoFixableIssues: hasAutoFixableIssues ?? this.hasAutoFixableIssues,
    );
  }
}
