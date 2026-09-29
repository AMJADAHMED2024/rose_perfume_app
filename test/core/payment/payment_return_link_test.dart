import 'package:flutter_test/flutter_test.dart';
import 'package:rose_perfume_app/core/payment/payment_return_link.dart';

void main() {
  group('paymentInvoiceIdFromUri', () {
    test('reads a trusted payment invoice identifier', () {
      final uri = Uri.parse(
        'roseperfume://payment-status?invoiceId=INV-2026-42',
      );

      expect(paymentInvoiceIdFromUri(uri), 'INV-2026-42');
    });

    test('supports gateway paymentId aliases', () {
      final uri = Uri.parse('roseperfume://payment-status?paymentId=987');

      expect(paymentInvoiceIdFromUri(uri), '987');
    });

    test('rejects an untrusted scheme or destination', () {
      expect(
        paymentInvoiceIdFromUri(
          Uri.parse('https://example.com/payment-status?invoiceId=INV-1'),
        ),
        isNull,
      );
      expect(
        paymentInvoiceIdFromUri(
          Uri.parse('roseperfume://checkout?invoiceId=INV-1'),
        ),
        isNull,
      );
    });

    test('rejects missing and blank identifiers', () {
      expect(
        paymentInvoiceIdFromUri(Uri.parse('roseperfume://payment-status')),
        isNull,
      );
      expect(
        paymentInvoiceIdFromUri(
          Uri.parse('roseperfume://payment-status?invoiceId=%20%20'),
        ),
        isNull,
      );
    });
  });
}
