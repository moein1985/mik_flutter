import '../../../../core/network/routeros_client.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/data/datasources/auth_remote_data_source.dart';
import '../../../certificates/data/datasources/certificate_remote_data_source.dart' show CertificateException;
import '../models/ip_service_model.dart';

final _log = AppLogger.tag('IpServiceDataSource');

/// Exception for service-related errors with user-friendly messages
class ServiceException implements Exception {
  final String message;
  final String? technicalDetails;

  ServiceException(this.message, {this.technicalDetails});

  /// Create exception from RouterOS error message with Persian translation
  static ServiceException fromRouterOSError(String error) {
    final lowerError = error.toLowerCase();
    
    if (lowerError.contains('certificate') && lowerError.contains('not found')) {
      return ServiceException(
        'گواهی مورد نظر یافت نشد',
        technicalDetails: error,
      );
    }
    if (lowerError.contains('invalid') && lowerError.contains('certificate')) {
      return ServiceException(
        'گواهی نامعتبر است. ممکن است کلید خصوصی نداشته باشد',
        technicalDetails: error,
      );
    }
    if (lowerError.contains('port') && (lowerError.contains('in use') || lowerError.contains('already'))) {
      return ServiceException(
        'این پورت قبلاً توسط سرویس دیگری استفاده شده است',
        technicalDetails: error,
      );
    }
    if (lowerError.contains('permission') || lowerError.contains('denied')) {
      return ServiceException(
        'دسترسی برای این عملیات وجود ندارد',
        technicalDetails: error,
      );
    }
    if (lowerError.contains('unknown parameter')) {
      return ServiceException(
        'خطای سازگاری با نسخه RouterOS',
        technicalDetails: error,
      );
    }
    
    return ServiceException(
      'خطا در عملیات سرویس',
      technicalDetails: error,
    );
  }

  @override
  String toString() => technicalDetails != null 
    ? '$message ($technicalDetails)' 
    : message;
}

abstract class IpServiceRemoteDataSource {
  Future<List<IpServiceModel>> getServices();
  Future<void> setServiceEnabled(String id, bool enabled);
  Future<void> setServicePort(String id, int port);
  Future<void> setServiceCertificate(String id, String certificateName);
  Future<void> setServiceAddress(String id, String address);
  Future<void> createSelfSignedCertificate(String name, String commonName);
}

class IpServiceRemoteDataSourceImpl implements IpServiceRemoteDataSource {
  final AuthRemoteDataSource authRemoteDataSource;

  IpServiceRemoteDataSourceImpl({required this.authRemoteDataSource});

  RouterOSClient get _client {
    final client = authRemoteDataSource.client;
    if (client == null) {
      throw Exception('Not connected to router');
    }
    return client;
  }

  @override
  Future<List<IpServiceModel>> getServices() async {
    _log.d('Getting all IP services...');
    final response = await _client.sendCommand(['/ip/service/print']);
    _log.d('Raw response: $response');
    
    // Filter out protocol items like {type: done}, {type: trap}
    // Keep 'type: re' items as they contain actual data rows
    final serviceData = response.where((data) {
      if (data['type'] == 'done' || data['type'] == 'trap') {
        return false;
      }
      return data.containsKey('name') || data.containsKey('.id');
    }).toList();
    
    final services = serviceData.map((data) => IpServiceModel.fromRouterOS(data)).toList();
    for (final s in services) {
      _log.d('Service: ${s.name}, port=${s.port}, cert=${s.certificate}, disabled=${s.disabled}');
    }
    return services;
  }

  @override
  Future<void> setServiceEnabled(String id, bool enabled) async {
    _log.i('Setting service "$id" enabled=$enabled');
    // For services, id is the service name (like "api-ssl", "www-ssl")
    // Use the name directly, not =.id=
    final command = enabled ? '/ip/service/enable' : '/ip/service/disable';
    final response = await _client.sendCommand([command, '=$id']);
    _log.d('Enable/disable response: $response');
    
    if (response.any((r) => r['type'] == 'trap')) {
      final errorMsg = response.firstWhere((r) => r['type'] == 'trap', orElse: () => {})['message'] ?? 'Unknown error';
      _log.e('Failed to set service enabled: $errorMsg');
      throw ServiceException.fromRouterOSError(errorMsg);
    }
  }

  @override
  Future<void> setServicePort(String id, int port) async {
    _log.i('Setting port $port for service "$id"');
    // Use service name directly, not =.id=
    final response = await _client.sendCommand([
      '/ip/service/set',
      '=$id',
      '=port=$port',
    ]);
    _log.d('Set port response: $response');
    
    if (response.any((r) => r['type'] == 'trap')) {
      final errorMsg = response.firstWhere((r) => r['type'] == 'trap', orElse: () => {})['message'] ?? 'Unknown error';
      _log.e('Failed to set port: $errorMsg');
      throw ServiceException.fromRouterOSError(errorMsg);
    }
  }

  @override
  Future<void> setServiceCertificate(String id, String certificateName) async {
    _log.i('Setting certificate "$certificateName" for service "$id"');
    
    // In RouterOS, service is identified by name (like "api-ssl", "www-ssl")
    // not by numeric .id. Let's try using the name directly.
    final response = await _client.sendCommand([
      '/ip/service/set',
      '=$id',  // Use service name directly, not =.id=
      '=certificate=$certificateName',
    ]);
    _log.d('Set certificate response: $response');
    
    // Check for trap error
    if (response.any((r) => r['type'] == 'trap')) {
      final errorMsg = response.firstWhere((r) => r['type'] == 'trap', orElse: () => {})['message'] ?? 'Unknown error';
      _log.e('Failed to set certificate: $errorMsg');
      throw ServiceException.fromRouterOSError(errorMsg);
    }
    
    // Verify the certificate was set
    final verifyResponse = await _client.sendCommand([
      '/ip/service/print',
      '?name=$id',  // Filter by service name
    ]);
    _log.d('Verify certificate response: $verifyResponse');
    if (verifyResponse.isNotEmpty) {
      final cert = verifyResponse.first['certificate'];
      _log.i('Certificate after set: $cert');
      if (cert != certificateName && cert != 'none' && certificateName.isNotEmpty) {
        _log.w('Certificate mismatch! Expected: $certificateName, Got: $cert');
      }
    }
  }

  @override
  Future<void> setServiceAddress(String id, String address) async {
    _log.i('Setting address "$address" for service "$id"');
    // Use service name directly, not =.id=
    final response = await _client.sendCommand([
      '/ip/service/set',
      '=$id',
      '=address=$address',
    ]);
    _log.d('Set address response: $response');
    
    if (response.any((r) => r['type'] == 'trap')) {
      final errorMsg = response.firstWhere((r) => r['type'] == 'trap', orElse: () => {})['message'] ?? 'Unknown error';
      _log.e('Failed to set address: $errorMsg');
      throw ServiceException.fromRouterOSError(errorMsg);
    }
  }

  @override
  Future<void> createSelfSignedCertificate(String name, String commonName) async {
    _log.i('Creating certificate: name=$name, commonName=$commonName');
    
    // Check if we have a local CA, if not create one
    final caName = 'local-ca';
    _log.d('Checking for local CA...');
    final caCheckResponse = await _client.sendCommand([
      '/certificate/print',
      '?name=$caName',
    ]);
    
    final hasCa = caCheckResponse.any((r) => r['name'] == caName && r['private-key'] == 'true');
    
    if (!hasCa) {
      _log.i('Creating local CA certificate...');
      
      // Add CA certificate template
      final addCaResponse = await _client.sendCommand([
        '/certificate/add',
        '=name=$caName',
        '=common-name=$caName',
        '=key-usage=key-cert-sign,crl-sign',
      ]);
      _log.d('Add CA response: $addCaResponse');
      
      // Get CA ID for signing
      final caPrintResponse = await _client.sendCommand([
        '/certificate/print',
        '?name=$caName',
      ]);
      final caItem = caPrintResponse.firstWhere(
        (r) => r['name'] == caName,
        orElse: () => {},
      );
      final caId = caItem['.id'];
      
      if (caId != null) {
        // Sign the CA (self-sign)
        _log.d('Signing CA certificate (ID: $caId)...');
        final signCaResponse = await _client.sendCommand([
          '/certificate/sign',
          '=.id=$caId',
        ], timeout: const Duration(seconds: 60));
        _log.d('Sign CA response: $signCaResponse');
      }
    }
    
    // Step 1: Add certificate template with key-usage for TLS server
    _log.d('Step 1: Adding certificate template...');
    final addResponse = await _client.sendCommand([
      '/certificate/add',
      '=name=$name',
      '=common-name=$commonName',
      '=key-size=2048',
      '=days-valid=3650', // 10 years
      '=key-usage=digital-signature,key-encipherment,tls-server',
    ]);
    _log.d('Add certificate response: $addResponse');
    
    // Check for errors in add response
    if (addResponse.any((r) => r['type'] == 'trap')) {
      final trapData = addResponse.firstWhere((r) => r['type'] == 'trap', orElse: () => {});
      _log.e('Add certificate trap: $trapData');
      final errorMsg = trapData['message'] ?? trapData.toString();
      throw CertificateException.fromRouterOSError(errorMsg);
    }

    // Step 2: Get certificate ID for signing
    _log.d('Step 2: Getting certificate ID...');
    final certPrintResponse = await _client.sendCommand([
      '/certificate/print',
      '?name=$name',
    ]);
    final certItem = certPrintResponse.firstWhere(
      (r) => r['name'] == name,
      orElse: () => {},
    );
    final certId = certItem['.id'];
    
    if (certId == null) {
      _log.e('Could not find certificate ID for $name');
      throw CertificateException(
        'گواهی یافت نشد',
        technicalDetails: 'Could not find certificate ID for $name',
      );
    }

    // Step 3: Sign the certificate with CA
    _log.d('Step 3: Signing certificate (ID: $certId) with CA (may take up to 60s)...');
    final signResponse = await _client.sendCommand([
      '/certificate/sign',
      '=.id=$certId',
      '=ca=$caName',
    ], timeout: const Duration(seconds: 60));
    _log.d('Sign certificate response: $signResponse');
    
    // Check for errors in sign response
    if (signResponse.any((r) => r['type'] == 'trap')) {
      final trapData = signResponse.firstWhere((r) => r['type'] == 'trap', orElse: () => {});
      _log.e('Sign certificate trap: $trapData');
      // Don't throw - continue to verify if certificate exists anyway
      _log.w('Sign may have failed, but will check if certificate exists...');
    }
    
    // Wait a bit for the certificate to be fully processed
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Step 3: Verify certificate was created and has private key
    _log.d('Step 3: Verifying certificate exists and has private key...');
    final verifyResponse = await _client.sendCommand([
      '/certificate/print',
      '?name=$name',
    ]);
    _log.d('Verify certificate response: $verifyResponse');
    
    // Filter out protocol messages
    final certData = verifyResponse.where((r) => r['name'] == name).toList();
    
    if (certData.isEmpty) {
      _log.e('Certificate "$name" was not found after creation!');
      throw CertificateException(
        'ساخت گواهی ناموفق بود',
        technicalDetails: 'Certificate creation failed - not found after signing',
      );
    }
    
    final cert = certData.first;
    final hasPrivateKey = cert['private-key'] == 'true' || cert['private-key'] == true;
    _log.i('Certificate "$name" created. Has private key: $hasPrivateKey');
    
    if (!hasPrivateKey) {
      _log.w('Certificate does not have private key - SSL may not work!');
    }
  }
}
