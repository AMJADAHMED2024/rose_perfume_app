import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/network/api_client.dart';
import '../../../core/security/secure_session_store.dart';
import '../../../core/security/session_expiration.dart';
import '../../../core/notifications/push_notification_service.dart';
import '../data/auth_repository.dart';

enum AuthStatus { checking, signedOut, submitting, signedIn }

class AuthState {
  const AuthState({this.status = AuthStatus.checking, this.errorMessage});

  final AuthStatus status;
  final String? errorMessage;

  bool get isSignedIn => status == AuthStatus.signedIn;

  AuthState copyWith({AuthStatus? status, String? errorMessage}) =>
      AuthState(status: status ?? this.status, errorMessage: errorMessage);
}

final authRepositoryProvider = Provider<AuthGateway>(
  (ref) =>
      AuthRepository(ref.watch(dioProvider), ref.watch(sessionStoreProvider)),
);

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(
    ref.watch(authRepositoryProvider),
    onLogout: ref.watch(appDatabaseProvider).clearCustomerData,
    sessionExpiration: ref.watch(sessionExpirationProvider.notifier),
    pushNotifications: ref.watch(pushNotificationServiceProvider),
  ),
);

class AuthController extends StateNotifier<AuthState> {
  factory AuthController(
    AuthGateway gateway, {
    Future<void> Function()? onLogout,
    SessionExpirationNotifier? sessionExpiration,
    PushNotificationService? pushNotifications,
  }) => AuthController._(
    gateway,
    onLogout: onLogout,
    sessionExpiration: sessionExpiration,
    pushNotifications: pushNotifications,
  );

  AuthController._(
    this._gateway, {
    this.onLogout,
    SessionExpirationNotifier? sessionExpiration,
    this._pushNotifications,
  }) : super(const AuthState()) {
    _expirationSubscription = sessionExpiration?.stream.listen((_) {
      unawaited(_handleSessionExpired());
    });
    unawaited(restoreSession());
  }

  final AuthGateway _gateway;
  final Future<void> Function()? onLogout;
  StreamSubscription<int>? _expirationSubscription;
  final PushNotificationService? _pushNotifications;

  Future<void> restoreSession() async {
    final hasSession = await _gateway.hasSession();
    state = AuthState(
      status: hasSession ? AuthStatus.signedIn : AuthStatus.signedOut,
    );
    if (hasSession) {
      unawaited(_pushNotifications?.requestPermissionAndRegister());
    }
  }

  Future<void> login({required String email, required String password}) async {
    await _submit(() => _gateway.login(email: email, password: password));
  }

  Future<void> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    await _submit(
      () => _gateway.register(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      ),
    );
  }

  Future<bool> requestPasswordReset({required String email}) async {
    try {
      await _gateway.requestPasswordReset(email: email);
      return true;
    } on AuthException catch (error) {
      state = AuthState(
        status: AuthStatus.signedOut,
        errorMessage: error.message,
      );
      return false;
    } catch (_) {
      state = const AuthState(
        status: AuthStatus.signedOut,
        errorMessage: 'تعذر إرسال رمز الاستعادة. تحقق من البريد والاتصال.',
      );
      return false;
    }
  }

  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _gateway.resetPassword(token: token, newPassword: newPassword);
      return true;
    } on AuthException catch (error) {
      state = AuthState(
        status: AuthStatus.signedOut,
        errorMessage: error.message,
      );
      return false;
    } catch (_) {
      state = const AuthState(
        status: AuthStatus.signedOut,
        errorMessage:
            'تعذر إعادة تعيين كلمة المرور. تحقق من الرمز وحاول مرة أخرى.',
      );
      return false;
    }
  }

  Future<String?> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _gateway.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      return null;
    } on AuthException catch (error) {
      return error.message;
    } catch (_) {
      return 'تعذر تغيير كلمة المرور. حاول مرة أخرى.';
    }
  }

  Future<void> _submit(Future<void> Function() action) async {
    state = const AuthState(status: AuthStatus.submitting);
    try {
      await action();
      state = const AuthState(status: AuthStatus.signedIn);
      unawaited(_pushNotifications?.requestPermissionAndRegister());
    } on AuthException catch (error) {
      state = AuthState(
        status: AuthStatus.signedOut,
        errorMessage: error.message,
      );
    } catch (_) {
      state = const AuthState(
        status: AuthStatus.signedOut,
        errorMessage: 'تعذر الاتصال بالخدمة. تحقق من الإنترنت وحاول مجددًا.',
      );
    }
  }

  Future<void> logout() async {
    await _gateway.logout();
    await onLogout?.call();
    state = const AuthState(status: AuthStatus.signedOut);
  }

  Future<void> _handleSessionExpired() async {
    await onLogout?.call();
    if (!mounted) return;
    state = const AuthState(
      status: AuthStatus.signedOut,
      errorMessage: 'انتهت الجلسة. سجّل الدخول مرة أخرى.',
    );
  }

  @override
  void dispose() {
    _expirationSubscription?.cancel();
    super.dispose();
  }
}
