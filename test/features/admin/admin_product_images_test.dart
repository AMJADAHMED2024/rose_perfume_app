import 'package:flutter_test/flutter_test.dart';
import 'package:rose_perfume_app/features/admin/data/admin_product_images_repository.dart';

void main() {
  test('maps product image records from the administration API', () {
    final image = AdminProductImage.fromJson({
      'id': 11,
      'imageUrl': 'https://cdn.example/image.jpg',
    });
    expect(image.id, 11);
    expect(image.url, contains('image.jpg'));
  });
}
