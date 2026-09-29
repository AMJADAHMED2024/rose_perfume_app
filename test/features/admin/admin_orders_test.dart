import 'package:flutter_test/flutter_test.dart';
import 'package:rose_perfume_app/features/admin/data/admin_orders_repository.dart';

void main() {
  test('maps administrative order lists with customer and item details', () {
    final page = AdminOrdersPageData.fromJson({
      'items': [
        {
          'id': 15,
          'totalPrice': 265.5,
          'status': 5,
          'createdAt': '2026-09-20T11:30:00Z',
          'paymentMethod': 'KNET',
          'isHasCoupon': true,
          'couponCode': 'ROSE10',
          'user': {'name': 'أمل'},
          'shippingDetail': {
            'address': 'شارع الملك',
            'city': 'الرياض',
            'country': 'السعودية',
          },
          'orderItems': [
            {
              'quantity': 2,
              'price': 99.5,
              'product': {'nameAr': 'عطر ورد'},
            },
          ],
        },
      ],
      'pageNumber': 2,
      'totalPages': 4,
      'totalCount': 61,
    });

    final order = page.items.single;
    expect(page.pageNumber, 2);
    expect(page.totalCount, 61);
    expect(order.customerName, 'أمل');
    expect(order.couponCode, 'ROSE10');
    expect(order.items.single.name, 'عطر ورد');
    expect(order.shippingAddress, 'شارع الملك، الرياض، السعودية');
  });
}
