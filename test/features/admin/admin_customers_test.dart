import 'package:flutter_test/flutter_test.dart';
import 'package:rose_perfume_app/features/admin/data/admin_customers_repository.dart';

void main() {
  test('maps customer status for administration', () {
    final customer = AdminCustomer.fromJson({
      'id': 7,
      'name': 'أمل',
      'email': 'a@example.com',
      'phone': '050',
      'status': true,
    });
    expect(customer.status, isTrue);
    expect(customer.email, 'a@example.com');
  });
}
