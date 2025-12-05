import '../../../../core/network/routeros_client.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/data/datasources/auth_remote_data_source.dart';
import '../models/certificate_model.dart';

final _log = AppLogger.tag('CertificateDataSource');

/// Custom exception for certificate operations with user-friendly messages
class CertificateException implements Exception {
  final String message;
  final String? technicalDetails;
  
  CertificateException(this.message, {this.technicalDetails});
  
  @override
  String toString() => message;
  
  /// Translate RouterOS error messages to user-friendly messages
  static CertificateException fromRouterOSError(String errorMessage, {String? operation}) {
    final lowerError = errorMessage.toLowerCase();
    
    // Common name / subject already exists
    if (lowerError.contains('same subject exists') || 
        lowerError.contains('certificate with the same')) {
      return CertificateException(
        'یک گواهی با همین Common Name قبلاً وجود دارد. لطفاً یک نام متفاوت انتخاب کنید.',
        technicalDetails: errorMessage,
      );
    }
    
    // Certificate name already exists
    if (lowerError.contains('already exists') || lowerError.contains('entry already exists')) {
      return CertificateException(
        'یک گواهی با این نام قبلاً وجود دارد. لطفاً نام دیگری انتخاب کنید.',
        technicalDetails: errorMessage,
      );
    }
    
    // CA not found
    if (lowerError.contains('ca not found') || lowerError.contains('no ca')) {
      return CertificateException(
        'CA (مرجع صدور گواهی) یافت نشد. ابتدا یک CA ایجاد کنید.',
        technicalDetails: errorMessage,
      );
    }
    
    // Invalid key size
    if (lowerError.contains('key-size') || lowerError.contains('invalid key')) {
      return CertificateException(
        'اندازه کلید نامعتبر است. مقادیر مجاز: 1024, 2048, 4096',
        technicalDetails: errorMessage,
      );
    }
    
    // Certificate in use
    if (lowerError.contains('in use') || lowerError.contains('cannot remove')) {
      return CertificateException(
        'این گواهی در حال استفاده است و نمی‌توان آن را حذف کرد.',
        technicalDetails: errorMessage,
      );
    }
    
    // Permission denied
    if (lowerError.contains('permission') || lowerError.contains('denied') || lowerError.contains('not allowed')) {
      return CertificateException(
        'دسترسی رد شد. کاربر فعلی مجوز انجام این عملیات را ندارد.',
        technicalDetails: errorMessage,
      );
    }
    
    // Unknown parameter (API version mismatch)
    if (lowerError.contains('unknown parameter')) {
      return CertificateException(
        'خطای سازگاری با نسخه RouterOS. لطفاً نسخه سیستم‌عامل روتر را بررسی کنید.',
        technicalDetails: errorMessage,
      );
    }
    
    // Generic failure
    if (lowerError.contains('failure:')) {
      final cleanedMessage = errorMessage.replaceFirst(RegExp(r'failure:\s*', caseSensitive: false), '');
      return CertificateException(
        'خطا در عملیات گواهی: $cleanedMessage',
        technicalDetails: errorMessage,
      );
    }
    
    // Default - return as is
    return CertificateException(
      operation != null ? 'خطا در $operation: $errorMessage' : errorMessage,
      technicalDetails: errorMessage,
    );
  }
}

abstract class CertificateRemoteDataSource {
  Future<List<CertificateModel>> getCertificates();
  Future<void> createSelfSignedCertificate({
    required String name,
    required String commonName,
    int keySize = 2048,
    int daysValid = 365,
  });
  Future<void> signCertificate(String name);
  Future<void> deleteCertificate(String id);
  Future<void> exportCertificate(String id, String filePath);
}

class CertificateRemoteDataSourceImpl implements CertificateRemoteDataSource {
  final AuthRemoteDataSource authRemoteDataSource;

  CertificateRemoteDataSourceImpl({required this.authRemoteDataSource});

  RouterOSClient get _client {
    final client = authRemoteDataSource.client;
    if (client == null) {
      throw Exception('Not connected to router');
    }
    return client;
  }

  @override
  Future<List<CertificateModel>> getCertificates() async {
    _log.d('Getting all certificates...');
    final response = await _client.sendCommand(['/certificate/print']);
    _log.d('Raw certificate response: $response');
    
    // Filter out protocol items like {type: done}, {type: trap}
    // Keep items with 'type: re' as they contain actual data rows
    // Also keep items that have certificate data (name or .id)
    final certificateData = response.where((data) {
      // Skip done and trap messages
      if (data['type'] == 'done' || data['type'] == 'trap') {
        return false;
      }
      // Include items that have certificate data (name or .id)
      // 'type: re' items from RouterOS contain the actual data
      return data.containsKey('name') || data.containsKey('.id');
    }).toList();
    
    _log.d('Filtered certificate data: ${certificateData.length} items');
    
    final certs = certificateData.map((data) => CertificateModel.fromRouterOS(data)).toList();
    for (final c in certs) {
      _log.d('Certificate: ${c.name}, privateKey=${c.privateKey}, trusted=${c.trusted}');
    }
    
    _log.i('Found ${certs.length} certificates');
    return certs;
  }

  @override
  Future<void> createSelfSignedCertificate({
    required String name,
    required String commonName,
    int keySize = 2048,
    int daysValid = 365,
  }) async {
    _log.i('Creating self-signed certificate: name=$name, CN=$commonName, keySize=$keySize, days=$daysValid');
    
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
      
      // Step 1a: Add CA certificate template
      final addCaResponse = await _client.sendCommand([
        '/certificate/add',
        '=name=$caName',
        '=common-name=$caName',
        '=key-usage=key-cert-sign,crl-sign',
      ]);
      _log.d('Add CA response: $addCaResponse');
      
      if (addCaResponse.any((r) => r['type'] == 'trap')) {
        final trapData = addCaResponse.firstWhere((r) => r['type'] == 'trap', orElse: () => {});
        // If CA already exists but wasn't signed, continue
        if (!trapData.toString().contains('already exists')) {
          _log.e('Add CA trap: $trapData');
        }
      }
      
      // Get CA ID for signing
      _log.d('Getting CA certificate ID...');
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
        // Step 1b: Sign the CA (self-sign)
        _log.d('Signing CA certificate (ID: $caId)...');
        final signCaResponse = await _client.sendCommand([
          '/certificate/sign',
          '=.id=$caId',
        ], timeout: const Duration(seconds: 60));
        _log.d('Sign CA response: $signCaResponse');
      }
    }
    
    // Step 2: Add the actual certificate template
    _log.d('Step 2: Adding certificate template...');
    final addResponse = await _client.sendCommand([
      '/certificate/add',
      '=name=$name',
      '=common-name=$commonName',
      '=key-size=$keySize',
      '=days-valid=$daysValid',
      '=key-usage=digital-signature,key-encipherment,tls-server',
    ]);
    _log.d('Add response: $addResponse');
    
    // Check for errors - log full trap content
    if (addResponse.any((r) => r['type'] == 'trap')) {
      final trapData = addResponse.firstWhere((r) => r['type'] == 'trap', orElse: () => {});
      _log.e('Add certificate trap: $trapData');
      final errorMsg = trapData['message'] ?? trapData.toString();
      throw CertificateException.fromRouterOSError(errorMsg);
    }

    // Step 3: Sign the certificate with our local CA
    // For API, we need to use .id parameter or find the certificate first
    _log.d('Step 3: Getting certificate ID for signing...');
    final certPrintResponse = await _client.sendCommand([
      '/certificate/print',
      '?name=$name',
    ]);
    _log.d('Cert print response: $certPrintResponse');
    
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
    
    _log.d('Signing certificate $name (ID: $certId) with CA (may take time)...');
    final signResponse = await _client.sendCommand([
      '/certificate/sign',
      '=.id=$certId',
      '=ca=$caName',
    ], timeout: const Duration(seconds: 60));
    _log.d('Sign response: $signResponse');
    
    // Check for errors in signing - log full trap content
    if (signResponse.any((r) => r['type'] == 'trap')) {
      final trapData = signResponse.firstWhere((r) => r['type'] == 'trap', orElse: () => {});
      _log.e('Sign certificate trap: $trapData');
      final errorMsg = trapData['message'] ?? trapData.toString();
      throw CertificateException.fromRouterOSError(errorMsg);
    }
    
    // Wait for processing
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Step 3: Verify
    _log.d('Step 3: Verifying certificate...');
    final verifyResponse = await _client.sendCommand([
      '/certificate/print',
      '?name=$name',
    ]);
    _log.d('Verify response: $verifyResponse');
    if (verifyResponse.isEmpty) {
      _log.e('Certificate "$name" not found after creation!');
      throw CertificateException(
        'گواهی پس از ایجاد یافت نشد',
        technicalDetails: 'Certificate not found after creation',
      );
    }
    
    final certData = verifyResponse.firstWhere((r) => r['name'] == name, orElse: () => {});
    final hasPrivateKey = certData['private-key'] == 'true';
    _log.i('Certificate "$name" created. Has private key: $hasPrivateKey');
    
    if (!hasPrivateKey) {
      _log.w('WARNING: Certificate does not have private key - SSL will not work!');
    }
  }

  @override
  Future<void> signCertificate(String name) async {
    _log.i('Signing certificate: $name');
    final response = await _client.sendCommand([
      '/certificate/sign',
      '=numbers=$name',  // Use 'numbers' parameter
    ], timeout: const Duration(seconds: 60));
    _log.d('Sign response: $response');
    
    if (response.any((r) => r['type'] == 'trap')) {
      final trapData = response.firstWhere((r) => r['type'] == 'trap', orElse: () => {});
      _log.e('Sign certificate trap: $trapData');
      final errorMsg = trapData['message'] ?? trapData.toString();
      throw CertificateException.fromRouterOSError(errorMsg);
    }
  }

  @override
  Future<void> deleteCertificate(String id) async {
    await _client.sendCommand([
      '/certificate/remove',
      '=.id=$id',
    ]);
  }

  @override
  Future<void> exportCertificate(String id, String filePath) async {
    await _client.sendCommand([
      '/certificate/export-certificate',
      '=.id=$id',
      '=file-name=$filePath',
    ]);
  }
}
