import 'package:flutter_test/flutter_test.dart';
import 'package:rose_perfume_app/features/admin/data/admin_inventory_repository.dart';

void main() {
  test('maps inventory transaction direction and product details', () {
    final record = AdminInventoryTransaction.fromJson({
      'id': 8,
      'productName': 'ورد الطائف',
      'type': 1,
      'quantity': 12,
      'date': '2026-09-23T00:00:00Z',
      'notes': 'توريد',
    });
    expect(record.productName, 'ورد الطائف');
    expect(record.type, 1);
    expect(record.quantity, 12);
  });
}
