import '../../domain/entities/letsencrypt_status.dart';

class LetsEncryptStatusModel extends LetsEncryptStatus {
  const LetsEncryptStatusModel({
    required super.hasCertificate,
    super.certificateName,
    super.dnsName,
    super.issuedAt,
    super.expiresAt,
    super.daysUntilExpiry,
    super.isExpired,
    super.isExpiringSoon,
  });

  /// Create from RouterOS certificate data
  factory LetsEncryptStatusModel.fromCertificate(Map<String, dynamic> certData) {
    DateTime? notBefore;
    DateTime? notAfter;
    int? daysUntilExpiry;
    bool isExpired = false;
    bool isExpiringSoon = false;

    // Parse dates
    if (certData['not-before'] != null) {
      notBefore = _parseRouterDate(certData['not-before']);
    }
    if (certData['not-after'] != null) {
      notAfter = _parseRouterDate(certData['not-after']);
    }

    // Calculate expiry info
    if (notAfter != null) {
      final now = DateTime.now();
      final difference = notAfter.difference(now);
      daysUntilExpiry = difference.inDays;
      isExpired = difference.isNegative;
      isExpiringSoon = !isExpired && daysUntilExpiry < 30;
    }

    // Check if expired based on RouterOS flag
    if (certData['expired'] == 'true') {
      isExpired = true;
    }

    return LetsEncryptStatusModel(
      hasCertificate: true,
      certificateName: certData['name'],
      dnsName: certData['common-name'] ?? certData['subject-alt-name'],
      issuedAt: notBefore,
      expiresAt: notAfter,
      daysUntilExpiry: daysUntilExpiry,
      isExpired: isExpired,
      isExpiringSoon: isExpiringSoon,
    );
  }

  /// Create empty status (no certificate)
  factory LetsEncryptStatusModel.empty() {
    return const LetsEncryptStatusModel(
      hasCertificate: false,
    );
  }

  /// Parse RouterOS date format
  /// RouterOS returns dates like: "Jan/01/2024 00:00:00" or "2024-01-01 00:00:00"
  static DateTime? _parseRouterDate(String dateStr) {
    try {
      // Try different formats
      // Format 1: "Jan/01/2024 00:00:00"
      final monthNames = {
        'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
        'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
      };
      
      final parts = dateStr.split(' ');
      if (parts.length >= 2) {
        final dateParts = parts[0].split('/');
        if (dateParts.length == 3) {
          final month = monthNames[dateParts[0].toLowerCase()];
          if (month != null) {
            final day = int.tryParse(dateParts[1]);
            final year = int.tryParse(dateParts[2]);
            if (day != null && year != null) {
              final timeParts = parts[1].split(':');
              final hour = int.tryParse(timeParts[0]) ?? 0;
              final minute = int.tryParse(timeParts[1]) ?? 0;
              final second = int.tryParse(timeParts[2]) ?? 0;
              return DateTime(year, month, day, hour, minute, second);
            }
          }
        }
      }
      
      // Format 2: Try ISO format "2024-01-01T00:00:00"
      return DateTime.tryParse(dateStr);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'hasCertificate': hasCertificate,
      'certificateName': certificateName,
      'dnsName': dnsName,
      'issuedAt': issuedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'daysUntilExpiry': daysUntilExpiry,
      'isExpired': isExpired,
      'isExpiringSoon': isExpiringSoon,
    };
  }
}
