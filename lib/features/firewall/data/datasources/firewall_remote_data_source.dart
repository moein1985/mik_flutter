import '../../domain/entities/firewall_rule.dart';
import '../../../../core/network/routeros_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/data/datasources/auth_remote_data_source.dart';

final _log = AppLogger.tag('FirewallDataSource');

abstract class FirewallRemoteDataSource {
  /// Get all firewall rules of a specific type
  Future<List<FirewallRule>> getRules(FirewallRuleType type);
  
  /// Enable a firewall rule
  Future<bool> enableRule(FirewallRuleType type, String id);
  
  /// Disable a firewall rule
  Future<bool> disableRule(FirewallRuleType type, String id);
  
  /// Get unique address list names (lightweight)
  Future<List<String>> getAddressListNames();
  
  /// Get address list entries filtered by list name
  Future<List<FirewallRule>> getAddressListByName(String listName);
}

class FirewallRemoteDataSourceImpl implements FirewallRemoteDataSource {
  final AuthRemoteDataSource authRemoteDataSource;

  FirewallRemoteDataSourceImpl({required this.authRemoteDataSource});

  RouterOSClient get client {
    if (authRemoteDataSource.client == null) {
      throw ServerException('Not connected to router');
    }
    return authRemoteDataSource.client!;
  }

  @override
  Future<List<FirewallRule>> getRules(FirewallRuleType type) async {
    try {
      final path = type.routerOsPath;
      _log.d('Getting firewall rules from: $path');
      
      final response = await client.getFirewallRules(path);
      _log.d('Raw response: $response');
      
      final rules = response
          .where((r) => r['type'] == 're')
          .map((r) => _parseRule(r, type))
          .toList();
      
      _log.i('Got ${rules.length} ${type.displayName} rules');
      return rules;
    } catch (e, stackTrace) {
      _log.e('Failed to get ${type.displayName} rules', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to get ${type.displayName} rules: $e');
    }
  }

  @override
  Future<bool> enableRule(FirewallRuleType type, String id) async {
    try {
      final path = type.routerOsPath;
      _log.i('Enabling ${type.displayName} rule: $id');
      return await client.enableFirewallRule(path, id);
    } catch (e) {
      _log.e('Failed to enable rule', error: e);
      throw ServerException('Failed to enable rule: $e');
    }
  }

  @override
  Future<bool> disableRule(FirewallRuleType type, String id) async {
    try {
      final path = type.routerOsPath;
      _log.i('Disabling ${type.displayName} rule: $id');
      return await client.disableFirewallRule(path, id);
    } catch (e) {
      _log.e('Failed to disable rule', error: e);
      throw ServerException('Failed to disable rule: $e');
    }
  }

  @override
  Future<List<String>> getAddressListNames() async {
    try {
      _log.d('Getting address list names (lightweight)');
      // Use the optimized method that only fetches list names
      final names = await client.getAddressListNames();
      _log.i('Found ${names.length} unique address list names');
      return names;
    } catch (e, stackTrace) {
      _log.e('Failed to get address list names', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to get address list names: $e');
    }
  }

  /// Get address list entries filtered by list name
  @override
  Future<List<FirewallRule>> getAddressListByName(String listName) async {
    try {
      _log.d('Getting address list entries for: $listName');
      final response = await client.getAddressListByName(listName);
      
      final rules = response
          .where((r) => r['type'] == 're')
          .map((r) => _parseRule(r, FirewallRuleType.addressList))
          .toList();
      
      _log.i('Got ${rules.length} entries for list: $listName');
      return rules;
    } catch (e, stackTrace) {
      _log.e('Failed to get address list by name', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to get address list for $listName: $e');
    }
  }

  /// Parse raw RouterOS response to FirewallRule entity
  FirewallRule _parseRule(Map<String, String> data, FirewallRuleType type) {
    // Build allParameters map excluding 'type' key (which is RouterOS response type)
    final allParameters = Map<String, String>.from(data);
    allParameters.remove('type'); // Remove RouterOS response type marker
    
    // Parse disabled status - could be 'true', 'false', or absent
    // Also check for 'X' flag in some cases
    final disabledStr = data['disabled']?.toLowerCase();
    final isDisabled = disabledStr == 'true';
    
    // Parse dynamic status
    final dynamicStr = data['dynamic']?.toLowerCase();
    final isDynamic = dynamicStr == 'true';
    
    // Parse invalid status
    final invalidStr = data['invalid']?.toLowerCase();
    final isInvalid = invalidStr == 'true';

    return FirewallRule(
      id: data['.id'] ?? '',
      type: type,
      disabled: isDisabled,
      dynamic: isDynamic,
      invalid: isInvalid,
      chain: data['chain'],
      action: data['action'],
      listName: data['list'],  // For address-list
      protocolName: data['name'],  // For layer7-protocol
      regexp: data['regexp'],  // For layer7-protocol
      allParameters: allParameters,
    );
  }
}
