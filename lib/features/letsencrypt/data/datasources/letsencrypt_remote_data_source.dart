import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/routeros_client_v2.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/data/datasources/auth_remote_data_source.dart';
import '../../domain/entities/acme_provider.dart';
import '../../domain/entities/precheck_result.dart';
import '../models/letsencrypt_status_model.dart';
import '../models/precheck_result_model.dart';

final _log = AppLogger.tag('LetsEncryptDataSource');

abstract class LetsEncryptRemoteDataSource {
  Future<LetsEncryptStatusModel> getStatus();
  Future<PreCheckResultModel> runPreChecks();
  Future<bool> autoFix(PreCheckType checkType);
  Future<bool> requestCertificate({
    required String dnsName,
    AcmeProvider provider = AcmeProvider.letsEncrypt,
  });
  Future<String> addTemporaryFirewallRule();
  Future<bool> removeTemporaryFirewallRule(String ruleId);
  Future<bool> checkPort80Accessible();
  Future<bool> revokeCertificate(String certificateName);
}

class LetsEncryptRemoteDataSourceImpl implements LetsEncryptRemoteDataSource {
  final AuthRemoteDataSource authRemoteDataSource;

  // Comment to identify our temporary firewall rule
  static const _firewallRuleComment = 'MikManager-LE-Temp-Port80';

  LetsEncryptRemoteDataSourceImpl({required this.authRemoteDataSource});

  RouterOSClientV2 get client {
    if (authRemoteDataSource.client == null) {
      throw ServerException('Not connected to router');
    }
    return authRemoteDataSource.client!;
  }

  @override
  Future<LetsEncryptStatusModel> getStatus() async {
    try {
      _log.d('Getting Let\'s Encrypt certificate status...');
      
      // Look for Let's Encrypt certificates
      final response = await client.sendCommand(['/certificate/print']);
      
      for (var item in response) {
        if (item['type'] == 're') {
          final issuer = item['issuer']?.toString().toLowerCase() ?? '';
          final ca = item['ca']?.toString().toLowerCase() ?? '';
          final name = item['name']?.toString().toLowerCase() ?? '';
          final commonName = item['common-name']?.toString().toLowerCase() ?? '';
          
          // Log certificate details for debugging
          _log.d('Certificate: name=$name, issuer=$issuer, ca=$ca, common-name=$commonName');
          
          // Check if this is a Let's Encrypt certificate
          // Let's Encrypt issuer contains R3, R10, R11, E5, E6 etc
          // Or the common-name contains mynetname.net (MikroTik's DDNS)
          final isLetsEncrypt = 
              issuer.contains('let\'s encrypt') ||
              issuer.contains('letsencrypt') ||
              issuer.contains('r3') ||
              issuer.contains('r10') ||
              issuer.contains('r11') ||
              issuer.contains('e5') ||
              issuer.contains('e6') ||
              ca.contains('let\'s encrypt') ||
              ca.contains('letsencrypt') ||
              ca.contains('r3') ||
              ca.contains('r10') ||
              ca.contains('r11') ||
              name.contains('letsencrypt') ||
              commonName.contains('mynetname.net') ||
              commonName.contains('sn.mynetname');
              
          if (isLetsEncrypt) {
            _log.i('Found Let\'s Encrypt certificate: ${item['name']}');
            return LetsEncryptStatusModel.fromCertificate(item);
          }
        }
      }
      
      _log.i('No Let\'s Encrypt certificate found');
      return LetsEncryptStatusModel.empty();
    } catch (e, stackTrace) {
      _log.e('Failed to get Let\'s Encrypt status', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to get Let\'s Encrypt status: $e');
    }
  }

  @override
  Future<PreCheckResultModel> runPreChecks() async {
    try {
      _log.d('Running pre-flight checks for Let\'s Encrypt...');
      
      final checks = <PreCheckItemModel>[];
      String? dnsName;
      String? publicIp;

      // 1. Check Cloud DDNS
      try {
        final cloudResponse = await client.sendCommand(['/ip/cloud/print']);
        bool cloudEnabled = false;
        
        for (var item in cloudResponse) {
          if (item['ddns-enabled'] == 'yes') {
            cloudEnabled = true;
          }
          if (item['dns-name'] != null && item['dns-name'].toString().isNotEmpty) {
            dnsName = item['dns-name'];
          }
          if (item['public-address'] != null) {
            publicIp = item['public-address'];
          }
        }
        
        checks.add(PreCheckItemModel(
          type: PreCheckType.cloudEnabled,
          passed: cloudEnabled,
          errorMessage: cloudEnabled ? null : 'cloudDdnsNotEnabled',
          canAutoFix: true,
        ));
        
        checks.add(PreCheckItemModel(
          type: PreCheckType.dnsAvailable,
          passed: dnsName != null && dnsName.isNotEmpty,
          errorMessage: dnsName != null ? null : 'dnsNameNotAvailable',
          canAutoFix: false, // Need to wait for cloud to assign DNS
        ));
      } catch (e) {
        _log.w('Failed to check cloud status: $e');
        checks.add(PreCheckItemModel(
          type: PreCheckType.cloudEnabled,
          passed: false,
          errorMessage: 'cloudCheckFailed',
          canAutoFix: false,
        ));
        checks.add(PreCheckItemModel(
          type: PreCheckType.dnsAvailable,
          passed: false,
          errorMessage: 'cloudCheckFailed',
          canAutoFix: false,
        ));
      }

      // 2. Check firewall rules for port 80
      try {
        final firewallCheck = await _checkFirewallForPort80();
        checks.add(PreCheckItemModel(
          type: PreCheckType.firewallRule,
          passed: firewallCheck,
          errorMessage: firewallCheck ? null : 'port80BlockedByFirewall',
          canAutoFix: true, // We can add a temporary rule
        ));
      } catch (e) {
        _log.w('Failed to check firewall: $e');
        checks.add(PreCheckItemModel(
          type: PreCheckType.firewallRule,
          passed: false,
          errorMessage: 'firewallCheckFailed',
          canAutoFix: true,
        ));
      }

      // 3. Check www service - MUST be enabled on port 80 for Let's Encrypt
      try {
        final wwwCheck = await _checkWwwService();
        checks.add(PreCheckItemModel(
          type: PreCheckType.www,
          passed: wwwCheck,
          errorMessage: wwwCheck ? null : 'wwwServiceNotOnPort80',
          canAutoFix: true, // Can auto-fix by enabling www on port 80
        ));
      } catch (e) {
        _log.w('Failed to check www service: $e');
        // Assume it's not OK if we can't check
        checks.add(const PreCheckItemModel(
          type: PreCheckType.www,
          passed: false,
          errorMessage: 'wwwServiceCheckFailed',
        ));
      }

      // 4. Check NAT rules (dstnat to port 80)
      try {
        final natCheck = await _checkNatForPort80();
        checks.add(PreCheckItemModel(
          type: PreCheckType.natRule,
          passed: natCheck,
          errorMessage: natCheck ? null : 'natRuleBlockingPort80',
          canAutoFix: false, // User needs to handle this
        ));
      } catch (e) {
        _log.w('Failed to check NAT rules: $e');
        checks.add(const PreCheckItemModel(
          type: PreCheckType.natRule,
          passed: true, // Assume OK if can't check
        ));
      }

      // Log each check result for debugging
      for (var check in checks) {
        _log.d('Pre-check ${check.type.name}: ${check.passed ? "PASSED" : "FAILED"} ${check.errorMessage ?? ""}');
      }
      
      _log.i('Pre-checks completed: ${checks.where((c) => c.passed).length}/${checks.length} passed');
      
      return PreCheckResultModel.fromChecks(
        checks: checks,
        dnsName: dnsName,
        publicIp: publicIp,
      );
    } catch (e, stackTrace) {
      _log.e('Failed to run pre-checks', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to run pre-checks: $e');
    }
  }

  /// Check if firewall allows port 80 inbound
  /// Returns true if:
  /// 1. Our temporary rule exists (MikManager-LE-Temp-Port80), OR
  /// 2. There's no blocking rule before an accept rule for port 80
  Future<bool> _checkFirewallForPort80() async {
    final response = await client.sendCommand([
      '/ip/firewall/filter/print',
      '?chain=input',
    ]);
    
    _log.d('Firewall check: found ${response.where((r) => r['type'] == 're').length} input rules');
    
    bool foundOurRule = false;
    bool foundAcceptForPort80 = false;
    
    // Process rules in order (they come in order from RouterOS)
    for (var item in response) {
      if (item['type'] == 're') {
        final action = item['action']?.toString() ?? '';
        final dstPort = item['dst-port']?.toString() ?? '';
        final protocol = item['protocol']?.toString() ?? '';
        final disabled = item['disabled'] == 'true';
        final comment = item['comment']?.toString() ?? '';
        
        if (disabled) continue;
        
        // Check if this is our temporary rule
        if (comment == _firewallRuleComment) {
          foundOurRule = true;
          _log.d('Found our temporary firewall rule');
          return true; // Our rule exists, we're good
        }
        
        // Check if this is an accept rule for port 80
        if (action == 'accept' &&
            (protocol == 'tcp' || protocol.isEmpty) &&
            (dstPort == '80' || dstPort.contains('80'))) {
          foundAcceptForPort80 = true;
          _log.d('Found accept rule for port 80');
          return true; // Accept rule found before any drop
        }
        
        // Check if this is a drop/reject rule that would block port 80
        // before any accept rule
        if ((action == 'drop' || action == 'reject') &&
            (protocol == 'tcp' || protocol.isEmpty) &&
            (dstPort == '80' || dstPort.contains('80') || dstPort.isEmpty)) {
          // This rule would block port 80 and there's no accept before it
          _log.d('Found blocking rule for port 80: action=$action, port=$dstPort, protocol=$protocol');
          return false;
        }
      }
    }
    
    // No blocking rule found, but also no explicit accept
    // This might be OK depending on default policy, but we'll require explicit accept
    _log.d('No explicit accept rule for port 80, foundOurRule=$foundOurRule');
    return foundOurRule || foundAcceptForPort80;
  }

  /// Check if www service is using port 80
  Future<bool> _checkWwwService() async {
    final response = await client.sendCommand(['/ip/service/print', '?name=www']);
    
    for (var item in response) {
      if (item['type'] == 're') {
        final disabled = item['disabled'] == 'true';
        final port = item['port']?.toString() ?? '80';
        
        // WWW service MUST be enabled on port 80 for Let's Encrypt to work
        // Let's Encrypt sends challenge to port 80 and www service must respond
        if (!disabled && port == '80') {
          return true; // Good: www is enabled on port 80
        }
      }
    }
    
    return false; // Bad: www is either disabled or not on port 80
  }

  /// Check if there's a NAT rule redirecting port 80 elsewhere
  Future<bool> _checkNatForPort80() async {
    final response = await client.sendCommand([
      '/ip/firewall/nat/print',
      '?chain=dstnat',
      '?dst-port=80',
    ]);
    
    for (var item in response) {
      if (item['type'] == 're') {
        final disabled = item['disabled'] == 'true';
        if (!disabled) {
          // There's an active NAT rule for port 80
          return false;
        }
      }
    }
    
    return true;
  }

  @override
  Future<bool> autoFix(PreCheckType checkType) async {
    try {
      _log.i('Auto-fixing issue: $checkType');
      
      switch (checkType) {
        case PreCheckType.cloudEnabled:
          return await _enableCloudDdns();
        case PreCheckType.firewallRule:
          final ruleId = await addTemporaryFirewallRule();
          return ruleId.isNotEmpty;
        case PreCheckType.www:
          return await _enableWwwOnPort80();
        default:
          throw ServerException('Cannot auto-fix issue type: $checkType');
      }
    } catch (e, stackTrace) {
      _log.e('Failed to auto-fix $checkType', error: e, stackTrace: stackTrace);
      if (e is ServerException) rethrow;
      throw ServerException('Failed to auto-fix: $e');
    }
  }

  /// Enable www service on port 80
  Future<bool> _enableWwwOnPort80() async {
    _log.i('Enabling www service on port 80...');
    
    final response = await client.sendCommand([
      '/ip/service/set',
      '=numbers=www',
      '=port=80',
      '=disabled=no',
    ]);
    
    final trap = response.firstWhere((r) => r['type'] == 'trap', orElse: () => {});
    if (trap.isNotEmpty) {
      throw ServerException(trap['message'] ?? 'Failed to enable www on port 80');
    }
    
    _log.i('WWW service enabled on port 80');
    return true;
  }

  Future<bool> _enableCloudDdns() async {
    final response = await client.sendCommand([
      '/ip/cloud/set',
      '=ddns-enabled=yes',
    ]);
    
    final trap = response.firstWhere((r) => r['type'] == 'trap', orElse: () => {});
    if (trap.isNotEmpty) {
      throw ServerException(trap['message'] ?? 'Failed to enable Cloud DDNS');
    }
    
    _log.i('Cloud DDNS enabled');
    return true;
  }

  @override
  Future<String> addTemporaryFirewallRule() async {
    try {
      _log.i('Adding temporary firewall rule for port 80...');
      
      // First, check if our rule already exists
      final existingRules = await client.sendCommand([
        '/ip/firewall/filter/print',
        '?comment=$_firewallRuleComment',
      ]);
      
      for (var item in existingRules) {
        if (item['type'] == 're' && item['.id'] != null) {
          final existingId = item['.id'] as String;
          _log.i('Temporary rule already exists: $existingId');
          
          // Move the existing rule to the top of input chain
          _log.d('Moving existing rule to top of input chain...');
          
          // Get the first rule in input chain
          final inputRules = await client.sendCommand([
            '/ip/firewall/filter/print',
            '?chain=input',
          ]);
          
          String? firstRuleId;
          for (var rule in inputRules) {
            if (rule['type'] == 're' && rule['.id'] != null) {
              final ruleId = rule['.id'] as String;
              // Skip our own rule
              if (ruleId != existingId) {
                firstRuleId = ruleId;
                break;
              }
            }
          }
          
          // If our rule is not already first, move it
          if (firstRuleId != null) {
            await client.sendCommand([
              '/ip/firewall/filter/move',
              '=numbers=$existingId',
              '=destination=$firstRuleId',
            ]);
            _log.i('Moved rule $existingId before $firstRuleId');
          } else {
            _log.d('Rule is already at top or only rule');
          }
          
          return existingId;
        }
      }
      
      // First, get the first rule in input chain to use for place-before
      final inputRules = await client.sendCommand([
        '/ip/firewall/filter/print',
        '?chain=input',
      ]);
      
      String? firstRuleId;
      for (var item in inputRules) {
        if (item['type'] == 're' && item['.id'] != null) {
          firstRuleId = item['.id'] as String;
          _log.d('First input rule ID: $firstRuleId');
          break;
        }
      }
      
      // Add new rule to input chain at the TOP using place-before
      final addCommand = [
        '/ip/firewall/filter/add',
        '=chain=input',
        '=action=accept',
        '=protocol=tcp',
        '=dst-port=80',
        '=comment=$_firewallRuleComment',
      ];
      
      // Only add place-before if we found existing rules
      if (firstRuleId != null) {
        addCommand.add('=place-before=$firstRuleId');
        _log.d('Adding rule before: $firstRuleId');
      }
      
      final response = await client.sendCommand(addCommand);
      
      _log.d('Add firewall rule response: $response');
      
      // Get the ID of the created rule - MikroTik returns 'ret' field
      String? ruleId;
      for (var item in response) {
        // Check for 'ret' (standard response) or '.id' format
        if (item['ret'] != null) {
          ruleId = item['ret'] as String;
          break;
        }
        // Some versions return the ID directly
        if (item['.id'] != null && item['type'] != 're') {
          ruleId = item['.id'] as String;
          break;
        }
      }
      
      // If still no ID, try to fetch the rule we just created
      if (ruleId == null) {
        _log.d('No direct ID returned, fetching rule by comment...');
        final createdRules = await client.sendCommand([
          '/ip/firewall/filter/print',
          '?comment=$_firewallRuleComment',
        ]);
        
        for (var item in createdRules) {
          if (item['type'] == 're' && item['.id'] != null) {
            ruleId = item['.id'] as String;
            _log.i('Found rule by comment: $ruleId');
            break;
          }
        }
      }
      
      if (ruleId == null) {
        throw ServerException('Failed to create firewall rule - no ID returned');
      }
      
      _log.i('Temporary firewall rule added: $ruleId');
      return ruleId;
    } catch (e, stackTrace) {
      _log.e('Failed to add firewall rule', error: e, stackTrace: stackTrace);
      if (e is ServerException) rethrow;
      throw ServerException('Failed to add firewall rule: $e');
    }
  }

  @override
  Future<bool> removeTemporaryFirewallRule(String ruleId) async {
    try {
      _log.i('Removing temporary firewall rule: $ruleId');
      
      final response = await client.sendCommand([
        '/ip/firewall/filter/remove',
        '=.id=$ruleId',
      ]);
      
      final trap = response.firstWhere((r) => r['type'] == 'trap', orElse: () => {});
      if (trap.isNotEmpty) {
        _log.w('Failed to remove rule: ${trap['message']}');
        return false;
      }
      
      _log.i('Temporary firewall rule removed');
      return true;
    } catch (e, stackTrace) {
      _log.e('Failed to remove firewall rule', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<bool> checkPort80Accessible() async {
    // This is a best-effort check - we can't truly verify external access from inside
    // We'll rely on the firewall and NAT checks instead
    _log.d('Port 80 accessibility check (based on firewall/NAT rules)');
    
    final firewallOk = await _checkFirewallForPort80();
    final natOk = await _checkNatForPort80();
    final wwwOk = await _checkWwwService();
    
    return firewallOk && natOk && wwwOk;
  }

  @override
  Future<bool> requestCertificate({
    required String dnsName,
    AcmeProvider provider = AcmeProvider.letsEncrypt,
  }) async {
    try {
      _log.i('Requesting Let\'s Encrypt certificate for: $dnsName');
      
      // Build the command
      final command = <String>['/certificate/enable-ssl-certificate', '=dns-name=$dnsName'];
      
      // Add ACME provider options if not default Let's Encrypt
      if (provider.directoryUrl != null) {
        command.add('=directory-url=${provider.directoryUrl}');
      }
      if (provider.eabKid != null) {
        command.add('=eab-kid=${provider.eabKid}');
      }
      if (provider.eabHmacKey != null) {
        command.add('=eab-hmac-key=${provider.eabHmacKey}');
      }
      
      _log.d('Executing: ${command.join(' ')}');
      
      // Certificate request can take 30-90 seconds depending on ACME provider
      final response = await client.sendCommand(
        command,
        timeout: const Duration(seconds: 90),
      );
      
      // Log the full response for debugging - important to see Let's Encrypt's actual response
      _log.i('=== Let\'s Encrypt Response (${response.length} items) ===');
      for (int i = 0; i < response.length; i++) {
        final item = response[i];
        // Log each item - this will show ACME errors, rate limits, sanctions, etc.
        _log.i('[$i] ${item.toString()}');
      }
      _log.i('=== End of Let\'s Encrypt Response ===');
      
      // Check for errors - trap message indicates failure
      final trap = response.firstWhere((r) => r['type'] == 'trap', orElse: () => {});
      if (trap.isNotEmpty) {
        final message = trap['message'] ?? 'Unknown error';
        _log.e('Certificate request failed (trap): $message');
        throw ServerException(message);
      }
      
      // Check for error messages in progress field (MikroTik reports errors here)
      for (var item in response) {
        final progress = item['progress']?.toString() ?? '';
        final progressLower = progress.toLowerCase();
        final message = item['message']?.toString() ?? '';
        final messageLower = message.toLowerCase();
        
        // Check both progress and message fields for errors
        if (progressLower.contains('[error]') || progressLower.contains('failed') || progressLower.contains('failure') ||
            messageLower.contains('error') || messageLower.contains('failed') || messageLower.contains('failure')) {
          
          // Analyze error and provide user-friendly message
          final errorKey = _analyzeAcmeError(progress, message);
          _log.e('Certificate request error: $progress $message -> $errorKey');
          throw ServerException(errorKey);
        }
      }
      
      _log.i('Certificate request completed successfully');
      return true;
    } catch (e, stackTrace) {
      _log.e('Failed to request certificate', error: e, stackTrace: stackTrace);
      if (e is ServerException) rethrow;
      throw ServerException('Failed to request certificate: $e');
    }
  }

  /// Analyze ACME error and return a user-friendly error key
  String _analyzeAcmeError(String progress, String message) {
    final combined = '$progress $message'.toLowerCase();
    
    // Connection/Network errors - likely sanctions or firewall
    if (combined.contains('connecting to') && combined.contains('failed')) {
      return 'acmeConnectionFailed';
    }
    
    // DNS resolution errors
    if (combined.contains('resolving') && combined.contains('failed')) {
      return 'acmeDnsResolutionFailed';
    }
    
    // SSL certificate update failed (generic)
    if (combined.contains('failed to update ssl certificate')) {
      return 'acmeSslUpdateFailed';
    }
    
    // Rate limit errors
    if (combined.contains('rate') && combined.contains('limit')) {
      return 'acmeRateLimited';
    }
    
    // Authorization errors
    if (combined.contains('unauthorized') || combined.contains('authorization')) {
      return 'acmeAuthorizationFailed';
    }
    
    // Challenge validation errors
    if (combined.contains('challenge') || combined.contains('validation')) {
      return 'acmeChallengeValidationFailed';
    }
    
    // Timeout errors
    if (combined.contains('timeout') || combined.contains('timed out')) {
      return 'acmeTimeout';
    }
    
    // Generic error with original message
    return 'acmeGenericError:$progress';
  }

  @override
  Future<bool> revokeCertificate(String certificateName) async {
    try {
      _log.i('Revoking/deleting certificate: $certificateName');
      
      final response = await client.sendCommand([
        '/certificate/remove',
        '=numbers=$certificateName',
      ]);
      
      final trap = response.firstWhere((r) => r['type'] == 'trap', orElse: () => {});
      if (trap.isNotEmpty) {
        throw ServerException(trap['message'] ?? 'Failed to remove certificate');
      }
      
      _log.i('Certificate removed successfully');
      return true;
    } catch (e, stackTrace) {
      _log.e('Failed to revoke certificate', error: e, stackTrace: stackTrace);
      if (e is ServerException) rethrow;
      throw ServerException('Failed to revoke certificate: $e');
    }
  }
}
