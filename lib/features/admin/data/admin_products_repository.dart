import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

class AdminCategoryOption {
  const AdminCategoryOption({required this.id, required this.name});
  final int id;
  final String name;

  factory AdminCategoryOption.fromJson(Map<String, dynamic> json) =>
      AdminCategoryOption(
        id: _asInt(json['id']),
        name: _text(json['nameAr'], fallback: _text(json['nameEn'])),
      );
}

class AdminProduct {
  const AdminProduct({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.price,
    required this.discount,
    required this.stockQuantity,
    required this.categoryId,
    required this.categoryName,
    required this.isDiscounted,
    required this.isFeatured,
    required this.weight,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.imageUrl,
  });

  final int id;
  final String nameAr;
  final String nameEn;
  final double price;
  final double discount;
  final int stockQuantity;
  final int categoryId;
  final String categoryName;
  final bool isDiscounted;
  final bool isFeatured;
  final double weight;
  final String descriptionAr;
  final String descriptionEn;
  final String? imageUrl;

  factory AdminProduct.fromJson(Map<String, dynamic> json) {
    final images = json['imageUrls'];
    final imageUrl = images is List && images.isNotEmpty
        ? images.first?.toString()
        : json['imageUrl']?.toString();
    return AdminProduct(
      id: _asInt(json['id']),
      nameAr: _text(json['nameAr']),
      nameEn: _text(json['nameEn']),
      price: _asDouble(json['price']),
      discount: _asDouble(json['discount']),
      stockQuantity: _asInt(json['stockQuantity']),
      categoryId: _asInt(json['categoryId']),
      categoryName: _text(json['categoryNameAr'], fallback: 'بدون تصنيف'),
      isDiscounted: json['isDiscounted'] == true,
      isFeatured: json['isFeatured'] == true,
      weight: _asDouble(json['weight']),
      descriptionAr: _text(json['descriptionAr']),
      descriptionEn: _text(json['descriptionEn']),
      imageUrl: imageUrl,
    );
  }
}

class AdminProductDraft {
  const AdminProductDraft({
    required this.nameAr,
    required this.nameEn,
    required this.price,
    required this.discount,
    required this.stockQuantity,
    required this.categoryId,
    required this.isDiscounted,
    required this.isFeatured,
    required this.weight,
    required this.descriptionAr,
    required this.descriptionEn,
  });

  final String nameAr;
  final String nameEn;
  final double price;
  final double discount;
  final int stockQuantity;
  final int categoryId;
  final bool isDiscounted;
  final bool isFeatured;
  final double weight;
  final String descriptionAr;
  final String descriptionEn;

  factory AdminProductDraft.fromProduct(AdminProduct product) =>
      AdminProductDraft(
        nameAr: product.nameAr,
        nameEn: product.nameEn,
        price: product.price,
        discount: product.discount,
        stockQuantity: product.stockQuantity,
        categoryId: product.categoryId,
        isDiscounted: product.isDiscounted,
        isFeatured: product.isFeatured,
        weight: product.weight,
        descriptionAr: product.descriptionAr,
        descriptionEn: product.descriptionEn,
      );

  Map<String, dynamic> toJson() => {
    'nameAr': nameAr,
    'nameEn': nameEn,
    'descriptionAr': descriptionAr,
    'descriptionEn': descriptionEn,
    'price': price,
    'discount': isDiscounted ? discount : 0,
    'stockQuantity': stockQuantity,
    'isDiscounted': isDiscounted,
    'categoryId': categoryId,
    'isFeatured': isFeatured,
    'weight': weight,
    'haveOtherPrice': false,
  };
}

class AdminProductsPageData {
  const AdminProductsPageData({
    required this.items,
    required this.pageNumber,
    required this.totalPages,
    required this.totalCount,
  });
  final List<AdminProduct> items;
  final int pageNumber;
  final int totalPages;
  final int totalCount;

  factory AdminProductsPageData.fromJson(Map<String, dynamic> json) =>
      AdminProductsPageData(
        items: _asList(json['items']).map(AdminProduct.fromJson).toList(),
        pageNumber: _asInt(json['pageNumber'], fallback: 1),
        totalPages: _asInt(json['totalPages'], fallback: 1),
        totalCount: _asInt(json['totalCount']),
      );
}

class AdminProductsRepository {
  const AdminProductsRepository(this._dio);
  final Dio _dio;

  Future<AdminProductsPageData> fetchProducts({
    required int pageNumber,
    required String search,
  }) async {
    final response = await _dio.post<dynamic>(
      '/api/product/get-all',
      data: {
        'pageNumber': pageNumber,
        'pageSize': 20,
        'search': search,
        'sortBy': 'createdAt',
        'isDescending': true,
      },
    );
    return AdminProductsPageData.fromJson(
      _asMap(_asMap(response.data)['data']),
    );
  }

  Future<List<AdminCategoryOption>> fetchCategories() async {
    final response = await _dio.post<dynamic>(
      '/api/category/get-all-categories',
      data: const {'pageNumber': 1, 'pageSize': 200},
    );
    return _asList(
      _asMap(_asMap(response.data)['data'])['items'],
    ).map(AdminCategoryOption.fromJson).toList();
  }

  Future<void> createProduct(AdminProductDraft draft) => _dio.post<dynamic>(
    '/api/product/create-product',
    data: FormData.fromMap(draft.toJson()),
  );

  Future<void> updateProduct(int id, AdminProductDraft draft) =>
      _dio.put<dynamic>(
        '/api/product/update-by-id',
        queryParameters: {'id': id},
        data: draft.toJson(),
      );

  Future<void> deleteProduct(int id) => _dio.delete<dynamic>(
    '/api/product/delete-by-id',
    queryParameters: {'id': id},
  );
}

final adminProductsRepositoryProvider = Provider<AdminProductsRepository>(
  (ref) => AdminProductsRepository(ref.watch(dioProvider)),
);

Map<String, dynamic> _asMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : const {};

List<Map<String, dynamic>> _asList(dynamic value) => value is List
    ? value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList()
    : const [];

int _asInt(dynamic value, {int fallback = 0}) =>
    value is int ? value : int.tryParse(value?.toString() ?? '') ?? fallback;

double _asDouble(dynamic value) => value is num
    ? value.toDouble()
    : double.tryParse(value?.toString() ?? '') ?? 0;

String _text(dynamic value, {String fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}
