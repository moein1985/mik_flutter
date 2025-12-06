import '../../domain/entities/precheck_result.dart';

class PreCheckItemModel extends PreCheckItem {
  const PreCheckItemModel({
    required super.type,
    required super.passed,
    super.errorMessage,
    super.canAutoFix,
  });

  factory PreCheckItemModel.fromMap(Map<String, dynamic> map) {
    return PreCheckItemModel(
      type: PreCheckType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => PreCheckType.cloudEnabled,
      ),
      passed: map['passed'] as bool,
      errorMessage: map['errorMessage'] as String?,
      canAutoFix: map['canAutoFix'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'passed': passed,
      'errorMessage': errorMessage,
      'canAutoFix': canAutoFix,
    };
  }
}

class PreCheckResultModel extends PreCheckResult {
  const PreCheckResultModel({
    required List<PreCheckItemModel> super.checks,
    super.dnsName,
    super.publicIp,
    required super.allPassed,
    required super.hasAutoFixableIssues,
  });

  factory PreCheckResultModel.fromChecks({
    required List<PreCheckItemModel> checks,
    String? dnsName,
    String? publicIp,
  }) {
    final allPassed = checks.every((c) => c.passed);
    final hasAutoFixable = checks.any((c) => !c.passed && c.canAutoFix);
    
    return PreCheckResultModel(
      checks: checks,
      dnsName: dnsName,
      publicIp: publicIp,
      allPassed: allPassed,
      hasAutoFixableIssues: hasAutoFixable,
    );
  }

  factory PreCheckResultModel.fromMap(Map<String, dynamic> map) {
    final checksList = (map['checks'] as List)
        .map((c) => PreCheckItemModel.fromMap(c as Map<String, dynamic>))
        .toList();
    
    return PreCheckResultModel(
      checks: checksList,
      dnsName: map['dnsName'] as String?,
      publicIp: map['publicIp'] as String?,
      allPassed: map['allPassed'] as bool,
      hasAutoFixableIssues: map['hasAutoFixableIssues'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'checks': (checks as List<PreCheckItemModel>).map((c) => c.toMap()).toList(),
      'dnsName': dnsName,
      'publicIp': publicIp,
      'allPassed': allPassed,
      'hasAutoFixableIssues': hasAutoFixableIssues,
    };
  }
}
