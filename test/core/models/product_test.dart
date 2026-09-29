import 'package:flutter_test/flutter_test.dart';
import 'package:rose_perfume_app/core/models/product.dart';

void main() {
  test(
    'preserves every product image while selecting the first as primary',
    () {
      final product = Product.fromJson({
        'id': 11,
        'nameAr': 'عطر روز',
        'nameEn': 'Rose perfume',
        'price': 120,
        'imageUrls': ['/a.jpg', '/b.jpg', ''],
      });

      expect(product.imageUrl, '/a.jpg');
      expect(product.imageUrls, ['/a.jpg', '/b.jpg']);
    },
  );
}
