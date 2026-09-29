import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rose_perfume_app/core/security/secure_session_store.dart';
import 'package:rose_perfume_app/core/security/session_identity.dart';

void main() {
  test(
    'reads the .NET role and customer id claims from a signed token payload',
    () async {
      final store = _MemorySessionStore(
        _token({
          'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier':
              '42',
          'http://schemas.microsoft.com/ws/2008/06/identity/claims/role':
              'Admin',
        }),
      );

      expect(await SessionIdentity.userId(store), 42);
      expect(await SessionIdentity.isAdmin(store), isTrue);
    },
  );

  test(
    'does not treat a customer role or malformed token as administrator',
    () async {
      expect(
        await SessionIdentity.isAdmin(
          _MemorySessionStore(_token({'role': 'User'})),
        ),
        isFalse,
      );
      expect(
        await SessionIdentity.isAdmin(_MemorySessionStore('not-a-token')),
        isFalse,
      );
    },
  );
}

class _MemorySessionStore implements SessionStore {
  _MemorySessionStore(this._tokenValue);
  String? _tokenValue;

  @override
  Future<void> clearToken() async => _tokenValue = null;

  @override
  Future<String?> readToken() async => _tokenValue;

  @override
  Future<void> writeToken(String token) async => _tokenValue = token;
}

String _token(Map<String, dynamic> claims) {
  final header = base64Url.encode(utf8.encode(jsonEncode({'alg': 'none'})));
  final payload = base64Url.encode(utf8.encode(jsonEncode(claims)));
  return '$header.$payload.signature';
}
