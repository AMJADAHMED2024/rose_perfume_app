import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

class ProductReview {
  const ProductReview({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    this.createdAt,
  });
  final int id;
  final String userName;
  final int rating;
  final String comment;
  final DateTime? createdAt;

  factory ProductReview.fromJson(Map<String, dynamic> json) => ProductReview(
    id: _asInt(json['id']),
    userName: json['userName']?.toString() ?? 'عميل روز برفيوم',
    rating: _asInt(json['rating']).clamp(1, 5),
    comment: json['comment']?.toString() ?? '',
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
  );
}

class ReviewsRepository {
  const ReviewsRepository(this._dio);
  final Dio _dio;

  Future<List<ProductReview>> fetch(int productId) async {
    final response = await _dio.post<dynamic>(
      '/api/review/get-all-reviews-by-product-id',
      data: {'productId': productId, 'pageNumber': 1, 'pageSize': 30},
    );
    final data = _asMap(_asMap(response.data)['data']);
    return _asList(data['items']).map(ProductReview.fromJson).toList();
  }

  Future<void> create({
    required int productId,
    required int rating,
    required String comment,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/review/create-review',
      data: {'productId': productId, 'rating': rating, 'comment': comment},
    );
    final body = _asMap(response.data);
    if (body['isSuccess'] != true && body['success'] != true) {
      throw ReviewException(
        body['message']?.toString() ?? 'تعذر إرسال التقييم.',
      );
    }
  }
}

class ReviewException implements Exception {
  const ReviewException(this.message);
  final String message;
}

Map<String, dynamic> _asMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : const {};
List<Map<String, dynamic>> _asList(dynamic value) => value is List
    ? value
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .toList()
    : const [];
int _asInt(dynamic value) =>
    value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;

final reviewsRepositoryProvider = Provider<ReviewsRepository>(
  (ref) => ReviewsRepository(ref.watch(dioProvider)),
);
