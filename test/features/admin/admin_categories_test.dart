import 'package:flutter_test/flutter_test.dart';
import 'package:rose_perfume_app/features/admin/data/admin_categories_repository.dart';

void main() {
  test('maps category administration data and its update payload', () {
    final category = AdminCategory.fromJson({
      'id': 4,
      'nameAr': 'عطور شرقية',
      'nameEn': 'Oriental Perfumes',
      'descriptionAr': 'مختارات شرقية',
      'descriptionEn': 'Oriental selection',
    });
    final draft = AdminCategoryDraft.fromCategory(category);

    expect(category.id, 4);
    expect(category.nameAr, 'عطور شرقية');
    expect(draft.toJson()['descriptionEn'], 'Oriental selection');
  });
}
