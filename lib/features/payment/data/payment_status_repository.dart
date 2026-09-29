import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/network/api_client.dart';
import '../../checkout/data/checkout_repository.dart';

class PaymentSessionRecord {
  const PaymentSessionRecord({
    required this.invoiceId,
    required this.orderId,
    this.paymentType,
    this.invoiceUrl,
    this.invoiceStatus,
    this.shipmentId,
    this.labelUrl,
    required this.createdAt,
    this.lastCheckedAt,
  });

  final String invoiceId;
  final int orderId;
  final String? paymentType;
  final String? invoiceUrl;
  final String? invoiceStatus;
  final String? shipmentId;
  final String? labelUrl;
  final DateTime createdAt;
  final DateTime? lastCheckedAt;

  factory PaymentSessionRecord.fromRow(PaymentSession row) =>
      PaymentSessionRecord(
        invoiceId: row.invoiceId,
        orderId: row.orderId,
        paymentType: row.paymentType,
        invoiceUrl: row.invoiceUrl,
        invoiceStatus: row.invoiceStatus,
        shipmentId: row.shipmentId,
        labelUrl: row.labelUrl,
        createdAt: row.createdAt,
        lastCheckedAt: row.lastCheckedAt,
      );
}

class PaymentStatusRepository {
  const PaymentStatusRepository(this._dio, this._database);
  final Dio _dio;
  final AppDatabase _database;

  Future<void> saveCreatedOrder(CreatedOrder order) async {
    final invoiceId = order.invoiceId?.trim();
    if (invoiceId == null || invoiceId.isEmpty) return;
    await _database.savePaymentSession(
      PaymentSessionsCompanion.insert(
        invoiceId: invoiceId,
        orderId: order.orderId,
        paymentType: Value(order.paymentType),
        invoiceUrl: Value(order.invoiceUrl),
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<PaymentSessionRecord?> latest() async {
    final row = await _database.readLatestPaymentSession();
    return row == null ? null : PaymentSessionRecord.fromRow(row);
  }

  Future<PaymentSessionRecord?> byInvoiceId(String invoiceId) async {
    final row = await _database.readPaymentSession(invoiceId);
    return row == null ? null : PaymentSessionRecord.fromRow(row);
  }

  Future<PaymentSessionRecord> refresh(PaymentSessionRecord session) async {
    final response = await _dio.post<dynamic>(
      '/api/order/check-pay-order',
      data: {
        'orderId': session.orderId,
        'paymentId': session.invoiceId,
        'paymentType': session.paymentType,
      },
    );
    final data = _payload(response.data);
    final updated = PaymentSessionRecord(
      invoiceId: data['invoiceId']?.toString() ?? session.invoiceId,
      orderId: _asInt(data['orderId'], session.orderId),
      paymentType: session.paymentType,
      invoiceUrl: session.invoiceUrl,
      invoiceStatus: data['invoiceStatus']?.toString() ?? session.invoiceStatus,
      shipmentId: data['shipmentId']?.toString() ?? session.shipmentId,
      labelUrl:
          data['labelURL']?.toString() ??
          data['labelUrl']?.toString() ??
          session.labelUrl,
      createdAt: session.createdAt,
      lastCheckedAt: DateTime.now(),
    );
    await _database.savePaymentSession(
      PaymentSessionsCompanion.insert(
        invoiceId: updated.invoiceId,
        orderId: updated.orderId,
        paymentType: Value(updated.paymentType),
        invoiceUrl: Value(updated.invoiceUrl),
        invoiceStatus: Value(updated.invoiceStatus),
        shipmentId: Value(updated.shipmentId),
        labelUrl: Value(updated.labelUrl),
        createdAt: updated.createdAt,
        lastCheckedAt: Value(updated.lastCheckedAt),
      ),
    );
    return updated;
  }
}

Map<String, dynamic> _payload(dynamic value) {
  if (value is! Map) return const {};
  final map = Map<String, dynamic>.from(value);
  final data = map['data'];
  return data is Map ? Map<String, dynamic>.from(data) : map;
}

int _asInt(dynamic value, int fallback) =>
    value is int ? value : int.tryParse(value?.toString() ?? '') ?? fallback;

final paymentStatusRepositoryProvider = Provider<PaymentStatusRepository>(
  (ref) => PaymentStatusRepository(
    ref.watch(dioProvider),
    ref.watch(appDatabaseProvider),
  ),
);
