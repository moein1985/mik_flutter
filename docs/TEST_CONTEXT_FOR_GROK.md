# Test Context for Certificate Feature - MikroTik Flutter App

## Overview
This document provides context for writing unit tests for the Certificate management feature in a Flutter app that connects to MikroTik RouterOS devices.

## Architecture
The project follows **Clean Architecture** with the following layers:
- **Domain**: Entities, Repository interfaces
- **Data**: Models, Repository implementations, DataSources
- **Presentation**: BLoC (State Management), Pages, Widgets

## Key Files & Their Responsibilities

---

## 1. Domain Layer

### `lib/features/certificates/domain/entities/certificate.dart`
```dart
import 'package:equatable/equatable.dart';

/// Entity representing a Certificate on RouterOS
class Certificate extends Equatable {
  final String id;
  final String name;
  final String? commonName;
  final String? country;
  final String? state;
  final String? locality;
  final String? organization;
  final String? unit;
  final String? subjectAltName;
  final int? keySize;
  final String? keyType;
  final String? digestAlgorithm;
  final DateTime? notBefore;
  final DateTime? notAfter;
  final bool trusted;
  final bool ca;           // Is this a Certificate Authority?
  final bool privateKey;   // Does it have a private key?
  final bool crl;
  final bool revoked;
  final bool expired;
  final String? issuer;
  final String? serialNumber;
  final String? fingerprint;
  final String? akid;
  final String? skid;
  final int? daysValid;

  const Certificate({...});

  /// Check if certificate is valid (not expired and not revoked)
  bool get isValid => !expired && !revoked;

  /// Check if certificate is self-signed
  bool get isSelfSigned => issuer == null || issuer == commonName;

  /// Check if certificate has private key (can be used for SSL services)
  bool get canBeUsedForSsl => privateKey && !expired && !revoked;
}
```

### `lib/features/certificates/domain/repositories/certificate_repository.dart`
```dart
abstract class CertificateRepository {
  Future<Either<Failure, List<Certificate>>> getCertificates();
  Future<Either<Failure, void>> createSelfSignedCertificate({
    required String name,
    required String commonName,
    int keySize = 2048,
    int daysValid = 365,
  });
  Future<Either<Failure, void>> deleteCertificate(String id);
}
```

---

## 2. Data Layer

### `lib/features/certificates/data/datasources/certificate_remote_data_source.dart`

**Key Class: `CertificateException`**
```dart
/// Custom exception for certificate operations with user-friendly Persian messages
class CertificateException implements Exception {
  final String message;
  final String? technicalDetails;
  
  CertificateException(this.message, {this.technicalDetails});
  
  /// Translate RouterOS error messages to user-friendly messages
  static CertificateException fromRouterOSError(String errorMessage, {String? operation}) {
    // Handles:
    // - "same subject exists" → یک گواهی با همین Common Name قبلاً وجود دارد
    // - "already exists" → یک گواهی با این نام قبلاً وجود دارد
    // - "ca not found" → CA یافت نشد
    // - "key-size" errors → اندازه کلید نامعتبر است
    // - "in use" → این گواهی در حال استفاده است
    // - "permission denied" → دسترسی رد شد
    // - "unknown parameter" → خطای سازگاری با نسخه RouterOS
  }
}
```

**Key Methods in `CertificateRemoteDataSourceImpl`:**

1. **`getCertificates()`**: Gets all certificates from RouterOS
   - Sends `/certificate/print` command
   - Filters out `type: done` and `type: trap` protocol messages
   - Keeps items with `name` or `.id` fields

2. **`createSelfSignedCertificate()`**: Creates a new SSL certificate
   - **Step 1**: Check if `local-ca` exists, if not create it
   - **Step 2**: Add certificate template with key-usage
   - **Step 3**: Sign the certificate with CA using `.id` parameter
   - **Step 4**: Verify certificate was created with private key

3. **`deleteCertificate(String id)`**: Removes a certificate
   - Sends `/certificate/remove` with `=.id=$id`

### `lib/features/certificates/data/models/certificate_model.dart`
```dart
class CertificateModel extends Certificate {
  factory CertificateModel.fromRouterOS(Map<String, String> data) {
    // Parses RouterOS response fields like:
    // '.id', 'name', 'common-name', 'key-size', 'private-key', 'trusted', 'ca', etc.
  }
}
```

---

## 3. Presentation Layer

### `lib/features/certificates/presentation/bloc/certificate_bloc.dart`
```dart
class CertificateBloc extends Bloc<CertificateEvent, CertificateState> {
  // Events:
  // - LoadCertificates
  // - RefreshCertificates  
  // - CreateSelfSignedCertificate(name, commonName, keySize, daysValid)
  // - DeleteCertificate(id)
  
  // States:
  // - CertificateInitial
  // - CertificateLoading
  // - CertificateLoaded(List<Certificate>)
  // - CertificateCreating(message)
  // - CertificateOperationSuccess(message, certificates)
  // - CertificateError(message)
}
```

### `lib/features/certificates/presentation/pages/certificates_page.dart`

**Key UI Feature: CA Delete Warning**
```dart
void _confirmDelete(BuildContext context, Certificate cert) {
  // Check if this is a CA certificate
  final isCA = cert.ca || 
               cert.name.toLowerCase().contains('ca') ||
               (cert.commonName?.toLowerCase().contains('ca') ?? false);
  
  if (isCA) {
    // Show special warning dialog with:
    // - "این یک Certificate Authority است"
    // - "گواهی‌های امضا شده با این CA ممکن است نامعتبر شوند"
    // - "امکان ساخت گواهی جدید تا ایجاد CA جدید وجود نخواهد داشت"
    // - "سرویس‌های SSL ممکن است از کار بیفتند"
  } else {
    // Show normal delete confirmation
  }
}
```

---

## 4. RouterOS Client

### `lib/core/network/routeros_client.dart`
- Implements RouterOS API protocol
- `sendCommand(List<String> command, {Duration? timeout})` - sends commands to router
- Handles trap (error) messages with `type: trap` and `message` field

---

## Test Scenarios to Cover

### Unit Tests for `Certificate` Entity
1. Test `isValid` - returns true when not expired and not revoked
2. Test `isSelfSigned` - returns true when issuer is null or equals commonName
3. Test `canBeUsedForSsl` - returns true when has privateKey, not expired, not revoked
4. Test Equatable props comparison

### Unit Tests for `CertificateModel`
1. Test `fromRouterOS()` parsing with complete data
2. Test `fromRouterOS()` with missing optional fields
3. Test boolean parsing ('true'/'false' strings)
4. Test `toEntity()` conversion

### Unit Tests for `CertificateException`
1. Test `fromRouterOSError()` with "same subject exists" error
2. Test `fromRouterOSError()` with "already exists" error
3. Test `fromRouterOSError()` with "ca not found" error
4. Test `fromRouterOSError()` with "unknown parameter" error
5. Test `fromRouterOSError()` with unknown error message
6. Test `toString()` output

### Unit Tests for `CertificateRemoteDataSource`
1. Test `getCertificates()` returns list of certificates
2. Test `getCertificates()` filters protocol messages correctly
3. Test `getCertificates()` handles empty response
4. Test `createSelfSignedCertificate()` creates CA if not exists
5. Test `createSelfSignedCertificate()` reuses existing CA
6. Test `createSelfSignedCertificate()` throws CertificateException on error
7. Test `deleteCertificate()` sends correct command

### Unit Tests for `CertificateRepository`
1. Test `getCertificates()` returns Right with certificates
2. Test `getCertificates()` returns Left(Failure) on exception
3. Test `createSelfSignedCertificate()` returns Right on success
4. Test `createSelfSignedCertificate()` returns Left(Failure) on CertificateException
5. Test `deleteCertificate()` returns Right on success

### Unit Tests for `CertificateBloc`
1. Test initial state is `CertificateInitial`
2. Test `LoadCertificates` emits Loading then Loaded
3. Test `LoadCertificates` emits Loading then Error on failure
4. Test `RefreshCertificates` emits Loaded with new data
5. Test `CreateSelfSignedCertificate` emits Creating then OperationSuccess
6. Test `CreateSelfSignedCertificate` emits Creating then Error on failure
7. Test `DeleteCertificate` emits OperationSuccess then reloads list
8. Test `DeleteCertificate` emits Error on failure

### Widget Tests for `CertificatesPage`
1. Test certificate list displays correctly
2. Test delete button shows confirmation dialog
3. Test CA delete shows special warning with Persian text
4. Test non-CA delete shows normal confirmation
5. Test create certificate FAB functionality
6. Test loading state shows progress indicator
7. Test error state shows error message

---

## Mock Data Examples

### RouterOS Certificate Response
```dart
final mockRouterOSResponse = [
  {
    '.id': '*1',
    'name': 'local-ca',
    'common-name': 'local-ca',
    'key-size': '2048',
    'private-key': 'true',
    'trusted': 'true',
    'ca': 'true',
    'expired': 'false',
    'revoked': 'false',
  },
  {
    '.id': '*2',
    'name': 'api-ssl-cert',
    'common-name': 'router',
    'key-size': '2048',
    'private-key': 'true',
    'trusted': 'false',
    'ca': 'false',
    'expired': 'false',
    'revoked': 'false',
    'issuer': 'local-ca',
  },
  {'type': 'done'},  // Should be filtered out
];
```

### Mock Certificate Entity
```dart
const mockCertificate = Certificate(
  id: '*1',
  name: 'test-cert',
  commonName: 'test.local',
  keySize: 2048,
  privateKey: true,
  trusted: false,
  ca: false,
  expired: false,
  revoked: false,
);

const mockCACertificate = Certificate(
  id: '*2',
  name: 'local-ca',
  commonName: 'local-ca',
  keySize: 2048,
  privateKey: true,
  trusted: true,
  ca: true,  // This is a CA
  expired: false,
  revoked: false,
);
```

---

## Dependencies Used
- `flutter_bloc`: State management
- `equatable`: Value equality
- `dartz`: Functional programming (Either type)
- `mockito`: Mocking in tests
- `bloc_test`: BLoC testing utilities

---

## File Locations for Tests
Create tests in:
- `test/features/certificates/domain/entities/certificate_test.dart`
- `test/features/certificates/data/models/certificate_model_test.dart`
- `test/features/certificates/data/datasources/certificate_remote_data_source_test.dart`
- `test/features/certificates/data/repositories/certificate_repository_impl_test.dart`
- `test/features/certificates/presentation/bloc/certificate_bloc_test.dart`
- `test/features/certificates/presentation/pages/certificates_page_test.dart`

---

## Notes for Test Implementation
1. Use `mocktail` or `mockito` for mocking dependencies
2. Follow existing test patterns in `test/features/hotspot/` directory
3. Test Persian error messages are correctly generated
4. Test CA detection logic (by `ca` field AND by name containing 'ca')
5. Ensure async operations are properly awaited in tests
