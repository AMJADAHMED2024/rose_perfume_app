import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class AdminNotification {
  const AdminNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
  });
  final int id;
  final String title;
  final String description;
  final int userId;
  factory AdminNotification.fromJson(Map<String, dynamic> j) =>
      AdminNotification(
        id: _int(j['id']),
        title: '${j['nameAr'] ?? j['nameEn'] ?? ''}',
        description: '${j['descriptionAr'] ?? j['descriptionEn'] ?? ''}',
        userId: _int(j['userId']),
      );
}

class AdminNotificationsRepository {
  const AdminNotificationsRepository(this._dio);
  final Dio _dio;
  Future<List<AdminNotification>> fetch() async {
    final r = await _dio.post<dynamic>(
      '/api/Notification/get-all-notifications',
      data: const {'pageNumber': 1, 'pageSize': 100},
    );
    final body = _map(r.data);
    final data = _map(body['data']);
    final raw = data['items'] ?? body['items'];
    return raw is List
        ? raw
              .whereType<Map>()
              .map(
                (x) => AdminNotification.fromJson(Map<String, dynamic>.from(x)),
              )
              .toList()
        : const [];
  }

  Future<void> send({
    required String title,
    required String description,
    int? userId,
  }) => _dio.post<dynamic>(
    userId == null
        ? '/api/Notification/send-notification-for-all-users'
        : '/api/Notification/send-notification-for-specific-user',
    data: {
      'nameAr': title,
      'nameEn': title,
      'descriptionAr': description,
      'descriptionEn': description,
      'userId': userId ?? 0,
    },
  );
  Future<void> delete(int id) => _dio.delete<dynamic>(
    '/api/Notification/delete-notification',
    queryParameters: {'id': id},
  );
}

final adminNotificationsRepositoryProvider =
    Provider<AdminNotificationsRepository>(
      (ref) => AdminNotificationsRepository(ref.watch(dioProvider)),
    );
Map<String, dynamic> _map(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : const {};
int _int(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;
