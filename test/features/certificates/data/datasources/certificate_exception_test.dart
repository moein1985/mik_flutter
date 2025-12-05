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

      expect(exception.message, 'یک گواهی با همین Common Name قبلاً وجود دارد. لطفاً یک نام متفاوت انتخاب کنید.');
      expect(exception.technicalDetails, errorMessage);
    });

    test('should handle certificate with the same error', () {
      const errorMessage = 'certificate with the same common name already exists';
      final exception = CertificateException.fromRouterOSError(errorMessage);

      expect(exception.message, 'یک گواهی با همین Common Name قبلاً وجود دارد. لطفاً یک نام متفاوت انتخاب کنید.');
      expect(exception.technicalDetails, errorMessage);
    });

    test('should handle already exists error', () {
      const errorMessage = 'already exists';
      final exception = CertificateException.fromRouterOSError(errorMessage);

      expect(exception.message, 'یک گواهی با این نام قبلاً وجود دارد. لطفاً نام دیگری انتخاب کنید.');
      expect(exception.technicalDetails, errorMessage);
    });

    test('should handle entry already exists error', () {
      const errorMessage = 'entry already exists';
      final exception = CertificateException.fromRouterOSError(errorMessage);

      expect(exception.message, 'یک گواهی با این نام قبلاً وجود دارد. لطفاً نام دیگری انتخاب کنید.');
      expect(exception.technicalDetails, errorMessage);
    });

    test('should handle ca not found error', () {
      const errorMessage = 'ca not found';
      final exception = CertificateException.fromRouterOSError(errorMessage);

      expect(exception.message, 'CA (مرجع صدور گواهی) یافت نشد. ابتدا یک CA ایجاد کنید.');
      expect(exception.technicalDetails, errorMessage);
    });

    test('should handle no ca error', () {
      const errorMessage = 'no ca available';
      final exception = CertificateException.fromRouterOSError(errorMessage);

      expect(exception.message, 'CA (مرجع صدور گواهی) یافت نشد. ابتدا یک CA ایجاد کنید.');
      expect(exception.technicalDetails, errorMessage);
    });

    test('should handle key-size error', () {
      const errorMessage = 'invalid key-size';
      final exception = CertificateException.fromRouterOSError(errorMessage);

      expect(exception.message, 'اندازه کلید نامعتبر است. مقادیر مجاز: 1024, 2048, 4096');
      expect(exception.technicalDetails, errorMessage);
    });

    test('should handle invalid key error', () {
      const errorMessage = 'invalid key parameter';
      final exception = CertificateException.fromRouterOSError(errorMessage);

      expect(exception.message, 'اندازه کلید نامعتبر است. مقادیر مجاز: 1024, 2048, 4096');
      expect(exception.technicalDetails, errorMessage);
    });

    test('should handle in use error', () {
      const errorMessage = 'certificate is in use';
      final exception = CertificateException.fromRouterOSError(errorMessage);

      expect(exception.message, 'این گواهی در حال استفاده است و نمی‌توان آن را حذف کرد.');
      expect(exception.technicalDetails, errorMessage);
    });

    test('should handle cannot remove error', () {
      const errorMessage = 'cannot remove certificate';
      final exception = CertificateException.fromRouterOSError(errorMessage);

      expect(exception.message, 'این گواهی در حال استفاده است و نمی‌توان آن را حذف کرد.');
      expect(exception.technicalDetails, errorMessage);
    });

    test('should handle permission denied error', () {
      const errorMessage = 'permission denied';
      final exception = CertificateException.fromRouterOSError(errorMessage);

      expect(exception.message, 'دسترسی رد شد. کاربر فعلی مجوز انجام این عملیات را ندارد.');
      expect(exception.technicalDetails, errorMessage);
    });

    test('should handle denied error', () {
      const errorMessage = 'access denied';
      final exception = CertificateException.fromRouterOSError(errorMessage);

      expect(exception.message, 'دسترسی رد شد. کاربر فعلی مجوز انجام این عملیات را ندارد.');
      expect(exception.technicalDetails, errorMessage);
    });

    test('should handle not allowed error', () {
      const errorMessage = 'operation not allowed';
      final exception = CertificateException.fromRouterOSError(errorMessage);

      expect(exception.message, 'دسترسی رد شد. کاربر فعلی مجوز انجام این عملیات را ندارد.');
      expect(exception.technicalDetails, errorMessage);
    });

    test('should handle unknown parameter error', () {
      const errorMessage = 'unknown parameter';
      final exception = CertificateException.fromRouterOSError(errorMessage);

      expect(exception.message, 'خطای سازگاری با نسخه RouterOS. لطفاً نسخه سیستم‌عامل روتر را بررسی کنید.');
      expect(exception.technicalDetails, errorMessage);
    });

    test('should handle failure error', () {
      const errorMessage = 'failure: invalid certificate';
      final exception = CertificateException.fromRouterOSError(errorMessage);

      expect(exception.message, 'خطا در عملیات گواهی: invalid certificate');
      expect(exception.technicalDetails, errorMessage);
    });

    test('should handle unknown error with operation', () {
      const errorMessage = 'some unknown error';
      final exception = CertificateException.fromRouterOSError(errorMessage, operation: 'ایجاد گواهی');

      expect(exception.message, 'خطا در ایجاد گواهی: some unknown error');
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

      expect(exception.message, 'یک گواهی با همین Common Name قبلاً وجود دارد. لطفاً یک نام متفاوت انتخاب کنید.');
    });
  });
}