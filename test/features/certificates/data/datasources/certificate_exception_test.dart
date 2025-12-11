import 'package:flutter_test/flutter_test.dart';
import 'package:hsmik/features/certificates/data/datasources/certificate_remote_data_source.dart';

void main() {
  group('CertificateException', () {
    test('should return correct message in toString', () {
      final exception = CertificateException('Test message');
      expect(exception.toString(), 'Test message');
    });

    test('should handle same subject exists error', () {
      const errorMessage = 'same subject exists';
      final exception = CertificateException.fromRouterOSError(errorMessage);

      expect(exception.message, 'A certificate with the same Common Name already exists. Please choose a different name.');
      expect(exception.technicalDetails, errorMessage);
    });

    test('should handle certificate with the same error', () {
      const errorMessage = 'certificate with the same common name already exists';
      final exception = CertificateException.fromRouterOSError(errorMessage);

      expect(exception.message, 'A certificate with the same Common Name already exists. Please choose a different name.');
      expect(exception.technicalDetails, errorMessage);
    });

    test('should handle already exists error', () {
      const errorMessage = 'already exists';
      final exception = CertificateException.fromRouterOSError(errorMessage);

      expect(exception.message, 'A certificate with this name already exists. Please choose a different name.');
      expect(exception.technicalDetails, errorMessage);
    });

    test('should handle entry already exists error', () {
      const errorMessage = 'entry already exists';
      final exception = CertificateException.fromRouterOSError(errorMessage);

      expect(exception.message, 'A certificate with this name already exists. Please choose a different name.');
      expect(exception.technicalDetails, errorMessage);
    });

    test('should handle ca not found error', () {
      const errorMessage = 'ca not found';
      final exception = CertificateException.fromRouterOSError(errorMessage);

      expect(exception.message, 'Certificate Authority (CA) not found. Please create a CA first.');
      expect(exception.technicalDetails, errorMessage);
    });

    test('should handle no ca error', () {
      const errorMessage = 'no ca available';
      final exception = CertificateException.fromRouterOSError(errorMessage);

      expect(exception.message, 'Certificate Authority (CA) not found. Please create a CA first.');
      expect(exception.technicalDetails, errorMessage);
    });

    test('should handle key-size error', () {
      const errorMessage = 'invalid key-size';
      final exception = CertificateException.fromRouterOSError(errorMessage);

      expect(exception.message, 'Invalid key size. Valid values: 1024, 2048, 4096');
      expect(exception.technicalDetails, errorMessage);
    });

    test('should handle invalid key error', () {
      const errorMessage = 'invalid key parameter';
      final exception = CertificateException.fromRouterOSError(errorMessage);

      expect(exception.message, 'Invalid key size. Valid values: 1024, 2048, 4096');
      expect(exception.technicalDetails, errorMessage);
    });

    test('should handle in use error', () {
      const errorMessage = 'certificate is in use';
      final exception = CertificateException.fromRouterOSError(errorMessage);

      expect(exception.message, 'This certificate is in use and cannot be removed.');
      expect(exception.technicalDetails, errorMessage);
    });

    test('should handle cannot remove error', () {
      const errorMessage = 'cannot remove certificate';
      final exception = CertificateException.fromRouterOSError(errorMessage);

      expect(exception.message, 'This certificate is in use and cannot be removed.');
      expect(exception.technicalDetails, errorMessage);
    });

    test('should handle permission denied error', () {
      const errorMessage = 'permission denied';
      final exception = CertificateException.fromRouterOSError(errorMessage);

      expect(exception.message, 'Permission denied. Current user does not have permission for this operation.');
      expect(exception.technicalDetails, errorMessage);
    });

    test('should handle denied error', () {
      const errorMessage = 'access denied';
      final exception = CertificateException.fromRouterOSError(errorMessage);

      expect(exception.message, 'Permission denied. Current user does not have permission for this operation.');
      expect(exception.technicalDetails, errorMessage);
    });

    test('should handle not allowed error', () {
      const errorMessage = 'operation not allowed';
      final exception = CertificateException.fromRouterOSError(errorMessage);

      expect(exception.message, 'Permission denied. Current user does not have permission for this operation.');
      expect(exception.technicalDetails, errorMessage);
    });

    test('should handle unknown parameter error', () {
      const errorMessage = 'unknown parameter';
      final exception = CertificateException.fromRouterOSError(errorMessage);

      expect(exception.message, 'RouterOS compatibility error. Please check the router OS version.');
      expect(exception.technicalDetails, errorMessage);
    });

    test('should handle failure error', () {
      const errorMessage = 'failure: invalid certificate';
      final exception = CertificateException.fromRouterOSError(errorMessage);

      expect(exception.message, 'Certificate operation failed: invalid certificate');
      expect(exception.technicalDetails, errorMessage);
    });

    test('should handle unknown error with operation', () {
      const errorMessage = 'some unknown error';
      final exception = CertificateException.fromRouterOSError(errorMessage, operation: 'creating certificate');

      expect(exception.message, 'Error in creating certificate: some unknown error');
      expect(exception.technicalDetails, errorMessage);
    });

    test('should handle unknown error without operation', () {
      const errorMessage = 'some unknown error';
      final exception = CertificateException.fromRouterOSError(errorMessage);

      expect(exception.message, 'some unknown error');
      expect(exception.technicalDetails, errorMessage);
    });

    test('should handle case insensitive matching', () {
      const errorMessage = 'SAME SUBJECT EXISTS';
      final exception = CertificateException.fromRouterOSError(errorMessage);

      expect(exception.message, 'A certificate with the same Common Name already exists. Please choose a different name.');
    });
  });
}