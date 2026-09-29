import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/network/api_client.dart';
import '../../../core/security/secure_session_store.dart';
import '../../../core/security/session_identity.dart';

class StoreNotification {
  const StoreNotification({
    required this.id,
    required this.title,
    required this.description,
    this.createdAt,
  });

  final int id;
  final String title;
  final String description;
  final DateTime? createdAt;

  factory StoreNotification.fromJson(Map<String, dynamic> json) =>
      StoreNotification(
        id: _asInt(json['id']),
        title:
            json['nameAr']?.toString() ??
            json['nameEn']?.toString() ??
            'إشعار من روز برفيوم',
        description:
            json['descriptionAr']?.toString() ??
            json['descriptionEn']?.toString() ??
            '',
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nameAr': title,
    'descriptionAr': description,
    'createdAt': createdAt?.toIso8601String(),
  };
}

class NotificationsRepository {
  const NotificationsRepository(this._dio, this._database, this._sessionStore);
  final Dio _dio;
  final AppDatabase _database;
  final SessionStore _sessionStore;

  Future<List<StoreNotification>?> readCached() async {
    final userId = await SessionIdentity.userId(_sessionStore);
    if (userId == null) return null;
    final payload = await _database.readNotificationPayload(userId);
    if (payload == null) return null;
    try {
      final decoded = jsonDecode(payload);
      return _asList(decoded).map(StoreNotification.fromJson).toList();
    } on FormatException {
      return null;
    }
  }

  Future<List<StoreNotification>> fetchMine() async {
    final response = await _dio.post<dynamic>(
      '/api/Notification/my-notifications',
    );
    final raw = _asMap(response.data)['data'];
    final rows = raw is List
        ? raw
        : raw is Map
        ? _asMap(raw)['items']
        : const <dynamic>[];
    final notifications = rows is List
        ? rows
              .whereType<Map>()
              .map(
                (row) =>
                    StoreNotification.fromJson(Map<String, dynamic>.from(row)),
              )
              .toList()
        : <StoreNotification>[];
    notifications.sort(
      (first, second) => (second.createdAt ?? DateTime(0)).compareTo(
        first.createdAt ?? DateTime(0),
      ),
    );
    final userId = await SessionIdentity.userId(_sessionStore);
    if (userId != null) {
      await _database.saveNotificationPayload(
        userId: userId,
        payload: jsonEncode(
          notifications.map((notification) => notification.toJson()).toList(),
        ),
      );
    }
    return notifications;
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

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => NotificationsRepository(
    ref.watch(dioProvider),
    ref.watch(appDatabaseProvider),
    ref.watch(sessionStoreProvider),
  ),
);
