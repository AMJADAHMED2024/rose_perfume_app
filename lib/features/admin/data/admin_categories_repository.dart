import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

class AdminCategory {
  const AdminCategory({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
  });
  final int id;
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;

  factory AdminCategory.fromJson(Map<String, dynamic> json) => AdminCategory(
    id: _int(json['id']),
    nameAr: _text(json['nameAr']),
    nameEn: _text(json['nameEn']),
    descriptionAr: _text(json['descriptionAr']),
    descriptionEn: _text(json['descriptionEn']),
  );
}

class AdminCategoryDraft {
  const AdminCategoryDraft({
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
  });
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;

  factory AdminCategoryDraft.fromCategory(AdminCategory category) =>
      AdminCategoryDraft(
        nameAr: category.nameAr,
        nameEn: category.nameEn,
        descriptionAr: category.descriptionAr,
        descriptionEn: category.descriptionEn,
      );

  Map<String, dynamic> toJson() => {
    'nameAr': nameAr,
    'nameEn': nameEn,
    'descriptionAr': descriptionAr,
    'descriptionEn': descriptionEn,
  };
}

class AdminCategoriesRepository {
  const AdminCategoriesRepository(this._dio);
  final Dio _dio;

  Future<List<AdminCategory>> fetch({required String search}) async {
    final response = await _dio.post<dynamic>(
      '/api/category/get-all-categories',
      data: {'pageNumber': 1, 'pageSize': 200, 'search': search},
    );
    final data = _map(_map(response.data)['data']);
    return _list(data['items']).map(AdminCategory.fromJson).toList();
  }

  Future<void> create(AdminCategoryDraft draft) =>
      _dio.post<dynamic>('/api/category/create-category', data: draft.toJson());

  Future<void> update(int id, AdminCategoryDraft draft) => _dio.put<dynamic>(
    '/api/category/update-category',
    queryParameters: {'id': id},
    data: draft.toJson(),
  );

  Future<void> delete(int id) => _dio.delete<dynamic>(
    '/api/category/delete-category',
    queryParameters: {'id': id},
  );
}

final adminCategoriesRepositoryProvider = Provider<AdminCategoriesRepository>(
  (ref) => AdminCategoriesRepository(ref.watch(dioProvider)),
);

Map<String, dynamic> _map(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : const {};
List<Map<String, dynamic>> _list(dynamic value) => value is List
    ? value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList()
    : const [];
int _int(dynamic value) => value is int ? value : int.tryParse('$value') ?? 0;
String _text(dynamic value) => value?.toString().trim() ?? '';
