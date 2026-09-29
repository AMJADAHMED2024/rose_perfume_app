import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

class AdminVariantProduct {
  const AdminVariantProduct({required this.id, required this.name});
  final int id;
  final String name;
  factory AdminVariantProduct.fromJson(Map<String, dynamic> json) =>
      AdminVariantProduct(
        id: _int(json['id']),
        name:
            json['nameAr']?.toString() ?? json['nameEn']?.toString() ?? 'منتج',
      );
}

class AdminProductVariant {
  const AdminProductVariant({
    required this.id,
    required this.productId,
    required this.name,
    required this.weightInGram,
    required this.price,
  });
  final int id;
  final int productId;
  final String name;
  final double weightInGram;
  final double price;
  factory AdminProductVariant.fromJson(Map<String, dynamic> json) =>
      AdminProductVariant(
        id: _int(json['id']),
        productId: _int(json['productId']),
        name: json['name']?.toString() ?? '',
        weightInGram: _double(json['weightInGram']),
        price: _double(json['price']),
      );
}

class AdminVariantDraft {
  const AdminVariantDraft({
    required this.name,
    required this.weightInGram,
    required this.price,
  });
  final String name;
  final double weightInGram;
  final double price;
  Map<String, dynamic> toJson({required int id, required int productId}) => {
    'id': id,
    'productId': productId,
    'name': name,
    'weightInGram': weightInGram,
    'price': price,
  };
}

class AdminVariantsRepository {
  const AdminVariantsRepository(this._dio);
  final Dio _dio;

  Future<List<AdminVariantProduct>> products() async {
    final response = await _dio.post<dynamic>(
      '/api/product/get-all',
      data: const {'pageNumber': 1, 'pageSize': 200},
    );
    final data = _map(_map(response.data)['data']);
    return _list(data['items']).map(AdminVariantProduct.fromJson).toList();
  }

  Future<List<AdminProductVariant>> variants(int productId) async {
    final response = await _dio.get<dynamic>(
      '/api/ProductVariant/get-all-by-product-id/$productId',
    );
    return _list(
      _map(response.data)['data'],
    ).map(AdminProductVariant.fromJson).toList();
  }

  Future<void> create(int productId, AdminVariantDraft draft) =>
      _dio.post<dynamic>(
        '/api/ProductVariant/create',
        data: draft.toJson(id: 0, productId: productId),
      );
  Future<void> update(AdminProductVariant variant, AdminVariantDraft draft) =>
      _dio.post<dynamic>(
        '/api/ProductVariant/Update',
        data: draft.toJson(id: variant.id, productId: variant.productId),
      );
  Future<void> delete(AdminProductVariant variant) => _dio.post<dynamic>(
    '/api/ProductVariant/Delete',
    data: {'id': variant.id, 'productId': variant.productId},
  );
}

final adminVariantsRepositoryProvider = Provider<AdminVariantsRepository>(
  (ref) => AdminVariantsRepository(ref.watch(dioProvider)),
);
Map<String, dynamic> _map(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : const {};
List<Map<String, dynamic>> _list(dynamic value) => value is List
    ? value.whereType<Map>().map((x) => Map<String, dynamic>.from(x)).toList()
    : const [];
int _int(dynamic value) => value is int ? value : int.tryParse('$value') ?? 0;
double _double(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
