import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/network/api_client.dart';
import '../../../core/security/secure_session_store.dart';
import '../../../core/security/session_identity.dart';

class CustomerOrder {
  const CustomerOrder({
    required this.id,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.items,
    this.paymentMethod,
    this.shipmentId,
    this.labelUrl,
  });

  final int id;
  final double totalPrice;
  final int status;
  final DateTime? createdAt;
  final List<CustomerOrderItem> items;
  final String? paymentMethod;
  final String? shipmentId;
  final String? labelUrl;

  factory CustomerOrder.fromJson(Map<String, dynamic> json) => CustomerOrder(
    id: _asInt(json['id']),
    totalPrice: _asDouble(json['totalPrice']),
    status: _asInt(json['status']),
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    items: _asList(json['orderItems']).map(CustomerOrderItem.fromJson).toList(),
    paymentMethod: json['paymentMethod']?.toString(),
    shipmentId: json['shipmentId']?.toString(),
    labelUrl: json['labelURL']?.toString() ?? json['labelUrl']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'totalPrice': totalPrice,
    'status': status,
    'createdAt': createdAt?.toIso8601String(),
    'orderItems': items.map((item) => item.toJson()).toList(),
    'paymentMethod': paymentMethod,
    'shipmentId': shipmentId,
    'labelUrl': labelUrl,
  };
}

class CustomerOrderItem {
  const CustomerOrderItem({
    required this.quantity,
    required this.price,
    required this.productName,
    this.productVariantId,
    this.productVariantName,
  });

  final int quantity;
  final double price;
  final String productName;
  final int? productVariantId;
  final String? productVariantName;

  factory CustomerOrderItem.fromJson(Map<String, dynamic> json) {
    final product = _asMap(json['product']);
    return CustomerOrderItem(
      quantity: _asInt(json['quantity']),
      price: _asDouble(json['price']),
      productName:
          product['nameAr']?.toString() ??
          product['nameEn']?.toString() ??
          'منتج من روز برفيوم',
      productVariantId: _asNullableInt(json['productVariantId']),
      productVariantName: _asNullableText(json['productVariantName']),
    );
  }

  Map<String, dynamic> toJson() => {
    'quantity': quantity,
    'price': price,
    if (productVariantId != null) 'productVariantId': productVariantId,
    if (productVariantName != null) 'productVariantName': productVariantName,
    'product': {'nameAr': productName},
  };
}

class OrdersRepository {
  const OrdersRepository(this._dio, this._database, this._sessionStore);
  final Dio _dio;
  final AppDatabase _database;
  final SessionStore _sessionStore;

  Future<List<CustomerOrder>?> readCached() async {
    final userId = await SessionIdentity.userId(_sessionStore);
    if (userId == null) return null;
    final payload = await _database.readOrderHistoryPayload(userId);
    if (payload == null) return null;
    try {
      final values = jsonDecode(payload);
      return _asList(values).map(CustomerOrder.fromJson).toList();
    } on FormatException {
      return null;
    }
  }

  Future<List<CustomerOrder>> fetchMyOrders() async {
    final response = await _dio.post<dynamic>(
      '/api/order/my-orders',
      data: const {'pageNumber': 1, 'pageSize': 30},
    );
    final data = _asMap(_asMap(response.data)['data']);
    final orders = _asList(data['items']).map(CustomerOrder.fromJson).toList();
    final userId = await SessionIdentity.userId(_sessionStore);
    if (userId != null) {
      await _database.saveOrderHistoryPayload(
        userId: userId,
        payload: jsonEncode(orders.map((order) => order.toJson()).toList()),
      );
    }
    return orders;
  }
}

Map<String, dynamic> _asMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : const {};

List<Map<String, dynamic>> _asList(dynamic value) => value is List
    ? value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList()
    : const [];

int _asInt(dynamic value) =>
    value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;

int? _asNullableInt(dynamic value) {
  final parsed = _asInt(value);
  return parsed > 0 ? parsed : null;
}

String? _asNullableText(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

double _asDouble(dynamic value) => value is num
    ? value.toDouble()
    : double.tryParse(value?.toString() ?? '') ?? 0;

final ordersRepositoryProvider = Provider<OrdersRepository>(
  (ref) => OrdersRepository(
    ref.watch(dioProvider),
    ref.watch(appDatabaseProvider),
    ref.watch(sessionStoreProvider),
  ),
);
