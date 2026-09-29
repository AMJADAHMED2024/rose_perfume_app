import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

class AdminOrder {
  const AdminOrder({
    required this.id,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.customerName,
    required this.paymentMethod,
    required this.couponCode,
    required this.items,
    this.shippingAddress,
  });

  final int id;
  final double totalPrice;
  final int status;
  final DateTime? createdAt;
  final String customerName;
  final String paymentMethod;
  final String? couponCode;
  final List<AdminOrderItem> items;
  final String? shippingAddress;

  factory AdminOrder.fromJson(Map<String, dynamic> json) {
    final user = _asMap(json['user']);
    final shipping = _asMap(json['shippingDetail']);
    return AdminOrder(
      id: _asInt(json['id']),
      totalPrice: _asDouble(json['totalPrice']),
      status: _asInt(json['status']),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      customerName: _text(user['name'], fallback: 'عميل غير مسجل'),
      paymentMethod: _text(
        json['paymentMethod'] ?? json['paymentType'],
        fallback: 'غير محدد',
      ),
      couponCode: json['isHasCoupon'] == true
          ? _nullableText(json['couponCode'])
          : null,
      items: _asList(json['orderItems']).map(AdminOrderItem.fromJson).toList(),
      shippingAddress: _shippingAddress(shipping),
    );
  }
}

class AdminOrderItem {
  const AdminOrderItem({
    required this.name,
    this.variantName,
    required this.quantity,
    required this.price,
  });

  final String name;
  final String? variantName;
  final int quantity;
  final double price;

  factory AdminOrderItem.fromJson(Map<String, dynamic> json) {
    final product = _asMap(json['product']);
    return AdminOrderItem(
      name: _text(
        product['nameAr'],
        fallback: _text(product['nameEn'], fallback: 'منتج'),
      ),
      variantName: _nullableText(
        json['productVariantName'] ?? _asMap(json['productVariant'])['name'],
      ),
      quantity: _asInt(json['quantity']),
      price: _asDouble(json['price']),
    );
  }
}

class AdminOrdersPageData {
  const AdminOrdersPageData({
    required this.items,
    required this.pageNumber,
    required this.totalPages,
    required this.totalCount,
  });

  final List<AdminOrder> items;
  final int pageNumber;
  final int totalPages;
  final int totalCount;

  factory AdminOrdersPageData.fromJson(Map<String, dynamic> json) =>
      AdminOrdersPageData(
        items: _asList(json['items']).map(AdminOrder.fromJson).toList(),
        pageNumber: _asInt(json['pageNumber'], fallback: 1),
        totalPages: _asInt(json['totalPages'], fallback: 1),
        totalCount: _asInt(json['totalCount']),
      );
}

class AdminOrdersRepository {
  const AdminOrdersRepository(this._dio);
  final Dio _dio;

  Future<AdminOrdersPageData> fetchOrders({
    required int pageNumber,
    required String search,
  }) async {
    final response = await _dio.post<dynamic>(
      '/api/order/get-all',
      data: {
        'pageNumber': pageNumber,
        'pageSize': 20,
        'search': search,
        'sortBy': 'createdAt',
        'isDescending': true,
      },
    );
    return AdminOrdersPageData.fromJson(_asMap(_asMap(response.data)['data']));
  }

  Future<AdminOrdersPageData> fetchCustomerOrders(int customerId) async {
    final response = await _dio.get<dynamic>(
      '/api/order/get-orders-by-user-id/$customerId',
      queryParameters: {
        'pageNumber': 1,
        'pageSize': 100,
        'sortBy': 'createdAt',
        'isDescending': true,
      },
    );
    return AdminOrdersPageData.fromJson(_asMap(_asMap(response.data)['data']));
  }
}

final adminOrdersRepositoryProvider = Provider<AdminOrdersRepository>(
  (ref) => AdminOrdersRepository(ref.watch(dioProvider)),
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

String? _nullableText(dynamic value) {
  final text = _text(value);
  return text.isEmpty ? null : text;
}

String? _shippingAddress(Map<String, dynamic> shipping) {
  final parts = [
    shipping['address'],
    shipping['city'],
    shipping['country'],
  ].map((value) => _text(value)).where((value) => value.isNotEmpty).toList();
  return parts.isEmpty ? null : parts.join('، ');
}
