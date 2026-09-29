import 'dart:async';

import 'package:dio/dio.dart';

import '../../../core/security/secure_session_store.dart';

abstract interface class AuthGateway {
  Future<bool> hasSession();
  Future<void> login({required String email, required String password});
  Future<void> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  });
  Future<void> requestPasswordReset({required String email});
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });
  Future<void> logout();
}

class AuthRepository implements AuthGateway {
  const AuthRepository(this._dio, this._sessionStore);

  final Dio _dio;
  final SessionStore _sessionStore;

  @override
  Future<bool> hasSession() async {
    try {
      return (await _sessionStore.readToken().timeout(
            const Duration(seconds: 4),
          ))?.isNotEmpty ??
          false;
    } on TimeoutException {
      // Do not leave the account page in its startup spinner if Android's
      // keystore is temporarily unavailable after reopening the app.
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> login({required String email, required String password}) {
    return _authenticate(
      endpoint: '/api/Auth/login',
      payload: {'email': email, 'password': password},
    );
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  }) {
    return _authenticate(
      endpoint: '/api/Auth/register',
      payload: {
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password,
        'role': 2,
      },
    );
  }

  Future<void> _authenticate({
    required String endpoint,
    required Map<String, dynamic> payload,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      endpoint,
      data: payload,
      options: Options(extra: const {'preserveSessionOnUnauthorized': true}),
    );
    final body = response.data ?? const <String, dynamic>{};
    final isSuccess = body['isSuccess'] == true || body['success'] == true;
    final token = body['data'];
    if (!isSuccess || token is! String || token.isEmpty) {
      throw AuthException(
        body['message'] as String? ?? 'تعذر إتمام المصادقة. حاول مرة أخرى.',
      );
    }
    await _sessionStore.writeToken(token);
  }

  @override
  Future<void> requestPasswordReset({required String email}) =>
      _submitUnauthenticated('/api/Auth/forgot-password', {
        'email': email.trim(),
      });

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) => _submitUnauthenticated('/api/Auth/reset-password', {
    'token': token.trim(),
    'newPassword': newPassword,
  });

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) => _submitAuthenticated('/api/Auth/change-password', {
    'oldPassword': oldPassword,
    'newPassword': newPassword,
  });

  Future<void> _submitUnauthenticated(
    String endpoint,
    Map<String, dynamic> payload,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      endpoint,
      data: payload,
      options: Options(extra: const {'preserveSessionOnUnauthorized': true}),
    );
    final body = response.data ?? const <String, dynamic>{};
    if (body['isSuccess'] != true && body['success'] != true) {
      throw AuthException(
        body['message']?.toString() ?? 'تعذر إتمام الطلب. حاول مرة أخرى.',
      );
    }
  }

  Future<void> _submitAuthenticated(
    String endpoint,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        endpoint,
        data: payload,
      );
      final body = response.data ?? const <String, dynamic>{};
      if (body['isSuccess'] != true && body['success'] != true) {
        throw AuthException(
          body['message']?.toString() ?? 'تعذر إتمام الطلب. حاول مرة أخرى.',
        );
      }
    } on DioException catch (error) {
      final data = error.response?.data;
      final message = data is Map ? data['message']?.toString() : null;
      throw AuthException(message ?? 'تعذر إتمام الطلب. حاول مرة أخرى.');
    }
  }

  @override
  Future<void> logout() => _sessionStore.clearToken();
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
