/// Extracts a payment invoice identifier from the application's trusted
/// payment-return URL. A URL is only a navigation hint; payment status is
/// always confirmed by the authenticated server request.
String? paymentInvoiceIdFromUri(Uri uri) {
  if (uri.scheme != 'roseperfume' || uri.host != 'payment-status') {
    return null;
  }

  for (final key in const ['invoiceId', 'paymentId', 'payment_id', 'orderId']) {
    final value = uri.queryParameters[key]?.trim();
    if (value != null && value.isNotEmpty) {
      return value;
    }
  }

  return null;
}
