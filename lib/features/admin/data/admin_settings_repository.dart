import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

class NewArrivalsSettings {
  const NewArrivalsSettings({
    required this.enabled,
    required this.productCount,
  });
  final bool enabled;
  final int productCount;

  factory NewArrivalsSettings.fromJson(Map<String, dynamic> json) =>
      NewArrivalsSettings(
        enabled: json['enabled'] != false,
        productCount: ((json['productCount'] as num?)?.toInt() ?? 6).clamp(
          1,
          12,
        ),
      );
}

class AdminSettingsRepository {
  const AdminSettingsRepository(this._dio);
  final Dio _dio;

  Future<NewArrivalsSettings> fetchNewArrivals() async {
    final response = await _dio.get<dynamic>(
      '/api/storefront-settings/new-arrivals',
    );
    final body = response.data is Map
        ? Map<String, dynamic>.from(response.data as Map)
        : const <String, dynamic>{};
    final data = body['data'];
    return NewArrivalsSettings.fromJson(
      data is Map ? Map<String, dynamic>.from(data) : const {},
    );
  }

  Future<void> saveNewArrivals(NewArrivalsSettings settings) =>
      _dio.put<dynamic>(
        '/api/storefront-settings/new-arrivals',
        data: {
          'enabled': settings.enabled,
          'productCount': settings.productCount,
        },
      );
}

final adminSettingsRepositoryProvider = Provider<AdminSettingsRepository>(
  (ref) => AdminSettingsRepository(ref.watch(dioProvider)),
);
