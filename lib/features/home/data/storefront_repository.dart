import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../core/database/app_database.dart';
import '../../../core/models/product.dart';
import '../domain/storefront.dart';

class StorefrontRepository {
  const StorefrontRepository(this._dio, this._database);
  final Dio _dio;
  final AppDatabase _database;

  Future<Storefront> fetchAndCache() async {
    final responses = await Future.wait([
      _dio.get<Map<String, dynamic>>('/api/Slider/get-all-slider-published'),
      _dio.post<Map<String, dynamic>>(
        '/api/category/get-all-categories',
        data: const {
          'pageNumber': 1,
          'pageSize': 12,
          'sortBy': 'productCount',
          'isDescending': true,
        },
      ),
      _dio.post<Map<String, dynamic>>(
        '/api/product/get-all',
        data: const {
          'pageNumber': 1,
          'pageSize': 100,
          'sortBy': 'createdAt',
          'isDescending': true,
        },
      ),
      _dio.get<Map<String, dynamic>>('/api/Banner/get-all-banners'),
      _dio.post<Map<String, dynamic>>(
        '/api/Testimonial/get-all-testimonial',
        data: const {'pageNumber': 1, 'pageSize': 12},
      ),
      _dio.get<Map<String, dynamic>>('/api/storefront-settings/new-arrivals'),
    ]);
    final sliders = _list(
      responses[0].data?['data'],
    ).map((item) => StoreSlider.fromJson(item)).toList();
    final categoriesData = responses[1].data?['data'];
    final productsData = responses[2].data?['data'];
    final bannersData = responses[3].data?['data'];
    final testimonialsData = responses[4].data?['data'];
    final newArrivalsData = responses[5].data?['data'];
    final storefront = Storefront(
      sliders: sliders,
      categories: _list(
        categoriesData is Map ? categoriesData['items'] : null,
      ).map((item) => StoreCategory.fromJson(item)).toList(),
      products: _list(
        productsData is Map ? productsData['items'] : null,
      ).map(Product.fromJson).toList(),
      banners: _list(bannersData).map(StoreBanner.fromJson).toList(),
      testimonials: _list(
        testimonialsData is Map ? testimonialsData['items'] : testimonialsData,
      ).map(StoreTestimonial.fromJson).toList(),
      newArrivalsEnabled: newArrivalsData is Map
          ? newArrivalsData['enabled'] != false
          : true,
      newArrivalsCount: newArrivalsData is Map
          ? ((newArrivalsData['productCount'] as num?)?.toInt() ?? 6)
          : 6,
    );
    await _database.saveStorefrontPayload(jsonEncode(storefront.toJson()));
    return storefront;
  }

  Future<Storefront?> readCached() async {
    final raw = await _database.readStorefrontPayload();
    if (raw == null) return null;
    try {
      return Storefront.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } on FormatException {
      return null;
    }
  }

  static List<Map<String, dynamic>> _list(dynamic value) => value is List
      ? value
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList()
      : const [];
}
