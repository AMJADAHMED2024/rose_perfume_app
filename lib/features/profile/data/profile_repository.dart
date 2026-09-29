import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

class CustomerProfileData {
  const CustomerProfileData({
    required this.name,
    required this.email,
    this.phone,
    this.nationality,
  });
  final String name;
  final String email;
  final String? phone;
  final String? nationality;

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'nationality': nationality,
  };

  factory CustomerProfileData.fromJson(Map<String, dynamic> json) =>
      CustomerProfileData(
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phone: json['phone']?.toString(),
        nationality: json['nationality']?.toString(),
      );
}

class ProfileRepository {
  const ProfileRepository(this._dio);
  final Dio _dio;

  Future<CustomerProfileData> fetch() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/User/user-profile',
    );
    return CustomerProfileData.fromJson(_asMap(_asMap(response.data)['data']));
  }

  Future<void> update(CustomerProfileData profile) async {
    await updatePayload(profile.toJson());
  }

  Future<void> updatePayload(Map<String, dynamic> payload) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/api/User/update-user-profile',
      data: payload,
    );
    final body = _asMap(response.data);
    if (body['isSuccess'] != true && body['success'] != true) {
      throw ProfileException(
        body['message']?.toString() ?? 'تعذر تحديث الحساب.',
      );
    }
  }
}

class ProfileException implements Exception {
  const ProfileException(this.message);
  final String message;
}

Map<String, dynamic> _asMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : const {};

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(dioProvider)),
);
