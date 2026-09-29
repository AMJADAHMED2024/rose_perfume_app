import 'package:flutter_test/flutter_test.dart';
import 'package:rose_perfume_app/features/checkout/data/checkout_repository.dart';

void main() {
  test('percentage coupons are capped at the merchandise subtotal', () {
    final coupon = CheckoutCoupon(
      code: 'SAVE20',
      discount: 20,
      isPercentage: true,
      expiryDate: DateTime(2030),
    );

    expect(coupon.discountFor(250), 50);
  });

  test('fixed coupons cannot make merchandise total negative', () {
    final coupon = CheckoutCoupon(
      code: 'SAVE500',
      discount: 500,
      isPercentage: false,
      expiryDate: DateTime(2030),
    );

    expect(coupon.discountFor(125), 125);
  });
}
