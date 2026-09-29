import 'package:flutter_test/flutter_test.dart';
import 'package:rose_perfume_app/features/auth/application/auth_controller.dart';
import 'package:rose_perfume_app/features/auth/data/auth_repository.dart';
import 'package:rose_perfume_app/core/security/session_expiration.dart';

void main() {
  test('restores a stored session', () async {
    final controller = AuthController(_FakeAuthGateway(sessionAvailable: true));

    await controller.restoreSession();

    expect(controller.state.isSignedIn, isTrue);
    controller.dispose();
  });

  test(
    'exposes an authentication message without marking the user signed in',
    () async {
      final controller = AuthController(
        _FakeAuthGateway(loginError: 'بيانات الدخول غير صحيحة'),
      );

      await controller.login(email: 'user@example.com', password: 'wrong');

      expect(controller.state.status, AuthStatus.signedOut);
      expect(controller.state.errorMessage, 'بيانات الدخول غير صحيحة');
      controller.dispose();
    },
  );

  test('signs out and clears customer data when a session expires', () async {
    var clearCalls = 0;
    final expiration = SessionExpirationNotifier();
    final controller = AuthController(
      _FakeAuthGateway(sessionAvailable: true),
      sessionExpiration: expiration,
      onLogout: () async => clearCalls++,
    );

    await controller.restoreSession();
    expiration.notifyExpired();
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.status, AuthStatus.signedOut);
    expect(
      controller.state.errorMessage,
      'انتهت الجلسة. سجّل الدخول مرة أخرى.',
    );
    expect(clearCalls, 1);
    controller.dispose();
    expiration.dispose();
  });
}

class _FakeAuthGateway implements AuthGateway {
  _FakeAuthGateway({this.sessionAvailable = false, this.loginError});

  final bool sessionAvailable;
  final String? loginError;

  @override
  Future<bool> hasSession() async => sessionAvailable;

  @override
  Future<void> login({required String email, required String password}) async {
    if (loginError case final message?) throw AuthException(message);
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {}

  @override
  Future<void> requestPasswordReset({required String email}) async {}

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {}

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {}
}
