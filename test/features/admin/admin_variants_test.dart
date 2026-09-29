import 'package:flutter_test/flutter_test.dart';
import 'package:rose_perfume_app/features/admin/data/admin_variants_repository.dart';

void main() {
  test('maps variant management fields', () {
    final value = AdminProductVariant.fromJson({
      'id': 3,
      'productId': 9,
      'name': '100 مل',
      'weightInGram': 100,
      'price': 120,
    });
    expect(value.productId, 9);
    expect(value.weightInGram, 100);
    expect(value.name, '100 مل');
  });
}
