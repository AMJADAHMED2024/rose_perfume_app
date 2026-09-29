import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

class AdminInventoryTransaction {
  const AdminInventoryTransaction({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.type,
    required this.date,
    required this.notes,
  });
  final int id;
  final String productName;
  final int quantity;
  final int type;
  final DateTime? date;
  final String notes;

  factory AdminInventoryTransaction.fromJson(Map<String, dynamic> json) =>
      AdminInventoryTransaction(
        id: _int(json['id']),
        productName: json['productName']?.toString() ?? 'منتج',
        quantity: _int(json['quantity']),
        type: _int(json['type']),
        date: DateTime.tryParse(json['date']?.toString() ?? ''),
        notes: json['notes']?.toString() ?? '',
      );
}

class AdminInventoryRepository {
  const AdminInventoryRepository(this._dio);
  final Dio _dio;

  Future<List<AdminInventoryTransaction>> fetchTransactions() async {
    final response = await _dio.post<dynamic>(
      '/api/InventoryTransaction/get-all',
      data: const {'pageNumber': 1, 'pageSize': 100},
    );
    final envelope = _map(response.data);
    final data = _map(envelope['data']);
    final items = data['items'] ?? envelope['items'];
    return _list(items).map(AdminInventoryTransaction.fromJson).toList();
  }
}

final adminInventoryRepositoryProvider = Provider<AdminInventoryRepository>(
  (ref) => AdminInventoryRepository(ref.watch(dioProvider)),
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
