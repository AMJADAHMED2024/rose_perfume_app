import 'package:flutter_test/flutter_test.dart';
import 'package:rose_perfume_app/features/admin/data/admin_coupons_repository.dart';

void main() {
  test('maps coupon administration records and normalizes its payload', () {
    final page = AdminCouponsPageData.fromJson({
      'items': [
        {
          'id': 3,
          'code': 'rose15',
          'discount': 15,
          'expiryDate': '2026-12-31T00:00:00Z',
          'isPercentage': true,
        },
      ],
      'pageNumber': 1,
      'totalPages': 1,
      'totalCount': 1,
    });
    final coupon = page.items.single;
    final payload = AdminCouponDraft.fromCoupon(coupon).toJson();

    expect(coupon.code, 'rose15');
    expect(coupon.isPercentage, isTrue);
    expect(payload['code'], 'ROSE15');
    expect(payload['discount'], 15);
  });
}
