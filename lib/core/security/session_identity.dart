import 'dart:convert';

import 'secure_session_store.dart';

/// Reads only non-sensitive identity claims from the already secured JWT.
/// Authorization still belongs to the server; this is solely for partitioning
/// device-local data by the currently signed-in customer.
class SessionIdentity {
  const SessionIdentity._();

  static Future<int?> userId(SessionStore store) async {
    final payload = await _claims(store);
    if (payload == null) return null;
    final value =
        payload['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ??
        payload['nameid'] ??
        payload['sub'];
    final id = value is int ? value : int.tryParse(value?.toString() ?? '');
    return id != null && id > 0 ? id : null;
  }

  /// This only decides whether to show the administration entry point.
  /// Every administrative API endpoint remains protected by the server role.
  static Future<bool> isAdmin(SessionStore store) async {
    final payload = await _claims(store);
    if (payload == null) return false;
    const roleClaims = [
      'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/role',
      'role',
      'roles',
    ];
    return roleClaims.any((key) => _hasAdminRole(payload[key]));
  }

  static Future<Map<String, dynamic>?> _claims(SessionStore store) async {
    final token = await store.readToken();
    if (token == null) return null;
    final parts = token.split('.');
    if (parts.length != 3) return null;
    try {
      final decoded = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } on FormatException {
      return null;
    }
  }

  static bool _hasAdminRole(dynamic value) {
    if (value is List) return value.any(_hasAdminRole);
    return value?.toString().toLowerCase() == 'admin';
  }
}
