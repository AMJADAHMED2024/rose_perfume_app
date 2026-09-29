import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

class AdminCoupon {
  const AdminCoupon({
    required this.id,
    required this.code,
    required this.discount,
    required this.expiryDate,
    required this.isPercentage,
  });
  final int id;
  final String code;
  final double discount;
  final DateTime? expiryDate;
  final bool isPercentage;

  factory AdminCoupon.fromJson(Map<String, dynamic> json) => AdminCoupon(
    id: _asInt(json['id']),
    code: json['code']?.toString() ?? '',
    discount: _asDouble(json['discount']),
    expiryDate: DateTime.tryParse(json['expiryDate']?.toString() ?? ''),
    isPercentage: json['isPercentage'] == true,
  );
}

class AdminCouponDraft {
  const AdminCouponDraft({
    required this.code,
    required this.discount,
    required this.expiryDate,
    required this.isPercentage,
  });
  final String code;
  final double discount;
  final DateTime expiryDate;
  final bool isPercentage;

  factory AdminCouponDraft.fromCoupon(AdminCoupon coupon) => AdminCouponDraft(
    code: coupon.code,
    discount: coupon.discount,
    expiryDate:
        coupon.expiryDate ?? DateTime.now().add(const Duration(days: 30)),
    isPercentage: coupon.isPercentage,
  );

  Map<String, dynamic> toJson() => {
    'code': code.toUpperCase(),
    'discount': discount,
    'expiryDate': expiryDate.toUtc().toIso8601String(),
    'isPercentage': isPercentage,
  };
}

class AdminCouponsPageData {
  const AdminCouponsPageData({
    required this.items,
    required this.pageNumber,
    required this.totalPages,
    required this.totalCount,
  });
  final List<AdminCoupon> items;
  final int pageNumber;
  final int totalPages;
  final int totalCount;

  factory AdminCouponsPageData.fromJson(Map<String, dynamic> json) =>
      AdminCouponsPageData(
        items: _asList(json['items']).map(AdminCoupon.fromJson).toList(),
        pageNumber: _asInt(json['pageNumber'], fallback: 1),
        totalPages: _asInt(json['totalPages'], fallback: 1),
        totalCount: _asInt(json['totalCount']),
      );
}

class AdminCouponsRepository {
  const AdminCouponsRepository(this._dio);
  final Dio _dio;

  Future<AdminCouponsPageData> fetchCoupons({
    required int pageNumber,
    required String search,
  }) async {
    final response = await _dio.post<dynamic>(
      '/api/coupon/get-all-coupons',
      data: {
        'pageNumber': pageNumber,
        'pageSize': 20,
        'search': search,
        'sortBy': 'createdAt',
        'isDescending': true,
      },
    );
    return AdminCouponsPageData.fromJson(_asMap(_asMap(response.data)['data']));
  }

  Future<void> createCoupon(AdminCouponDraft draft) =>
      _dio.post<dynamic>('/api/coupon/create-coupon', data: draft.toJson());

  Future<void> updateCoupon(int id, AdminCouponDraft draft) =>
      _dio.put<dynamic>(
        '/api/coupon/update-coupon-by-id',
        queryParameters: {'id': id},
        data: draft.toJson(),
      );

  Future<void> deleteCoupon(int id) => _dio.delete<dynamic>(
    '/api/coupon/delete-coupon-by-id',
    queryParameters: {'id': id},
  );
}

final adminCouponsRepositoryProvider = Provider<AdminCouponsRepository>(
  (ref) => AdminCouponsRepository(ref.watch(dioProvider)),
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
