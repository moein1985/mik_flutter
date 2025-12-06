import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/routeros_client.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/data/datasources/auth_remote_data_source.dart';
import '../models/cloud_status_model.dart';

final _log = AppLogger.tag('CloudDataSource');

abstract class CloudRemoteDataSource {
  Future<CloudStatusModel> getCloudStatus();
  Future<bool> enableDdns();
  Future<bool> disableDdns();
  Future<bool> forceUpdate();
  Future<bool> setUpdateInterval(String interval);
  Future<bool> setUpdateTime(bool enabled);
}

class CloudRemoteDataSourceImpl implements CloudRemoteDataSource {
  final AuthRemoteDataSource authRemoteDataSource;

  CloudRemoteDataSourceImpl({required this.authRemoteDataSource});

  RouterOSClient get client {
    if (authRemoteDataSource.client == null) {
      throw ServerException('Not connected to router');
    }
    return authRemoteDataSource.client!;
  }

  @override
  Future<CloudStatusModel> getCloudStatus() async {
    try {
      _log.d('Getting cloud status...');
      final response = await client.sendCommand(['/ip/cloud/print']);
      
      // Find the data response (type=re) or done with properties
      Map<String, String> cloudData = {};
      String? comment;
      
      for (var item in response) {
        if (item['type'] == 're' || item.containsKey('ddns-enabled')) {
          cloudData = Map<String, String>.from(item);
        }
        // Check for comment (warning message)
        if (item['comment'] != null) {
          comment = item['comment'];
        }
      }
      
      // Also check if there's a comment in the response indicating x86
      // RouterOS sometimes returns this in a different way
      final rawResponse = response.toString();
      if (rawResponse.contains('not supported on x86')) {
        cloudData['comment'] = 'Cloud services not supported on x86';
      } else if (comment != null) {
        cloudData['comment'] = comment;
      }
      
      final status = CloudStatusModel.fromMap(cloudData);
      _log.i('Cloud status: DDNS=${status.ddnsEnabled}, DNS=${status.dnsName}, Supported=${status.isSupported}');
      return status;
    } catch (e, stackTrace) {
      _log.e('Failed to get cloud status', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to get cloud status: $e');
    }
  }

  @override
  Future<bool> enableDdns() async {
    try {
      _log.i('Enabling DDNS...');
      final response = await client.sendCommand([
        '/ip/cloud/set',
        '=ddns-enabled=yes',
      ]);
      
      final trap = response.firstWhere((r) => r['type'] == 'trap', orElse: () => {});
      if (trap.isNotEmpty) {
        final message = trap['message'] ?? 'Unknown error';
        _log.e('Failed to enable DDNS: $message');
        throw ServerException(message);
      }
      
      _log.i('DDNS enabled successfully');
      return true;
    } catch (e, stackTrace) {
      _log.e('Failed to enable DDNS', error: e, stackTrace: stackTrace);
      if (e is ServerException) rethrow;
      throw ServerException('Failed to enable DDNS: $e');
    }
  }

  @override
  Future<bool> disableDdns() async {
    try {
      _log.i('Disabling DDNS...');
      // Note: RouterOS doesn't accept 'no' for ddns-enabled, use 'auto' instead
      // 'auto' means DDNS is only enabled if Back to Home VPN is used
      final response = await client.sendCommand([
        '/ip/cloud/set',
        '=ddns-enabled=auto',
      ]);
      
      final trap = response.firstWhere((r) => r['type'] == 'trap', orElse: () => {});
      if (trap.isNotEmpty) {
        final message = trap['message'] ?? 'Unknown error';
        _log.e('Failed to disable DDNS: $message');
        throw ServerException(message);
      }
      
      _log.i('DDNS disabled successfully');
      return true;
    } catch (e, stackTrace) {
      _log.e('Failed to disable DDNS', error: e, stackTrace: stackTrace);
      if (e is ServerException) rethrow;
      throw ServerException('Failed to disable DDNS: $e');
    }
  }

  @override
  Future<bool> forceUpdate() async {
    try {
      _log.i('Forcing DDNS update...');
      final response = await client.sendCommand(['/ip/cloud/force-update']);
      
      final trap = response.firstWhere((r) => r['type'] == 'trap', orElse: () => {});
      if (trap.isNotEmpty) {
        final message = trap['message'] ?? 'Unknown error';
        _log.e('Failed to force update: $message');
        throw ServerException(message);
      }
      
      _log.i('DDNS force update triggered');
      return true;
    } catch (e, stackTrace) {
      _log.e('Failed to force DDNS update', error: e, stackTrace: stackTrace);
      if (e is ServerException) rethrow;
      throw ServerException('Failed to force DDNS update: $e');
    }
  }

  @override
  Future<bool> setUpdateInterval(String interval) async {
    try {
      _log.i('Setting DDNS update interval to $interval...');
      final response = await client.sendCommand([
        '/ip/cloud/set',
        '=ddns-update-interval=$interval',
      ]);
      
      final trap = response.firstWhere((r) => r['type'] == 'trap', orElse: () => {});
      if (trap.isNotEmpty) {
        final message = trap['message'] ?? 'Unknown error';
        throw ServerException(message);
      }
      
      _log.i('DDNS update interval set successfully');
      return true;
    } catch (e, stackTrace) {
      _log.e('Failed to set DDNS update interval', error: e, stackTrace: stackTrace);
      if (e is ServerException) rethrow;
      throw ServerException('Failed to set DDNS update interval: $e');
    }
  }

  @override
  Future<bool> setUpdateTime(bool enabled) async {
    try {
      _log.i('Setting update time to ${enabled ? 'yes' : 'no'}...');
      final response = await client.sendCommand([
        '/ip/cloud/set',
        '=update-time=${enabled ? 'yes' : 'no'}',
      ]);
      
      final trap = response.firstWhere((r) => r['type'] == 'trap', orElse: () => {});
      if (trap.isNotEmpty) {
        final message = trap['message'] ?? 'Unknown error';
        throw ServerException(message);
      }
      
      _log.i('Update time setting changed successfully');
      return true;
    } catch (e, stackTrace) {
      _log.e('Failed to set update time', error: e, stackTrace: stackTrace);
      if (e is ServerException) rethrow;
      throw ServerException('Failed to set update time: $e');
    }
  }
}
