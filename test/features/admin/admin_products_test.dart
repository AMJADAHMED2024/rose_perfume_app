import 'package:flutter_test/flutter_test.dart';
import 'package:rose_perfume_app/features/admin/data/admin_products_repository.dart';

void main() {
  test('maps administrative product pages and retains management fields', () {
    final page = AdminProductsPageData.fromJson({
      'items': [
        {
          'id': 8,
          'nameAr': 'ورد المدينة',
          'nameEn': 'Madinah Rose',
          'price': 180,
          'discount': 15,
          'stockQuantity': 7,
          'categoryId': 4,
          'categoryNameAr': 'عطور',
          'isDiscounted': true,
          'isFeatured': true,
          'weight': 0.5,
          'descriptionAr': 'وصف عربي',
          'descriptionEn': 'English description',
          'imageUrls': ['https://cdn.example/rose.jpg'],
        },
      ],
      'pageNumber': 1,
      'totalPages': 1,
      'totalCount': 1,
    });

    final product = page.items.single;
    expect(product.nameAr, 'ورد المدينة');
    expect(product.imageUrl, 'https://cdn.example/rose.jpg');
    expect(product.isFeatured, isTrue);
    expect(AdminProductDraft.fromProduct(product).toJson()['categoryId'], 4);
  });
}
