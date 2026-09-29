import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/delivery_address.dart';
import '../../../core/network/api_client.dart';

class AddressesRepository {
  const AddressesRepository(this._dio);
  final Dio _dio;

  Future<List<DeliveryAddress>> fetchMine() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/Address/get-address-by-user-id',
    );
    return _asList(
      _asMap(response.data)['data'],
    ).map(DeliveryAddress.fromJson).toList();
  }

  Future<void> create({
    required String title,
    required String street,
    required String city,
    required String country,
    required String? countryCode,
    required String? nationalAddressShortCode,
    required double latitude,
    required double longitude,
    required bool isPrimary,
  }) => _send('/api/Address/create-address', {
    'title': title,
    'street': street,
    'city': city,
    'country': country,
    'countryCode': countryCode,
    'nationalAddressShortCode': nationalAddressShortCode,
    'latitude': latitude,
    'longitude': longitude,
    'isPrimary': isPrimary,
  });

  Future<void> update({
    required DeliveryAddress address,
    required String title,
    required String street,
    required String city,
    required String country,
    required String? countryCode,
    required String? nationalAddressShortCode,
    required double latitude,
    required double longitude,
    required bool isPrimary,
  }) => _send('/api/Address/update-address', {
    'id': address.id,
    'title': title,
    'street': street,
    'city': city,
    'country': country,
    'countryCode': countryCode,
    'nationalAddressShortCode': nationalAddressShortCode,
    'latitude': latitude,
    'longitude': longitude,
    'isPrimary': isPrimary,
  });

  Future<void> delete(int id) => _dio.delete<void>(
    '/api/Address/delete-address',
    queryParameters: {'id': id},
  );

  Future<void> setPrimary(int id) => _dio.post<void>(
    '/api/Address/set-primary-address',
    queryParameters: {'id': id},
  );

  Future<void> _send(String path, Map<String, dynamic> data) async {
    final response = await _dio.post<Map<String, dynamic>>(path, data: data);
    final body = _asMap(response.data);
    if (body['isSuccess'] != true && body['success'] != true) {
      throw AddressException(
        body['message']?.toString() ?? 'تعذر حفظ العنوان.',
      );
    }
  }
}

class AddressException implements Exception {
  const AddressException(this.message);
  final String message;
  @override
  String toString() => message;
}

Map<String, dynamic> _asMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : const {};
List<Map<String, dynamic>> _asList(dynamic value) => value is List
    ? value
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .toList()
    : const [];

final addressesRepositoryProvider = Provider<AddressesRepository>(
  (ref) => AddressesRepository(ref.watch(dioProvider)),
);
