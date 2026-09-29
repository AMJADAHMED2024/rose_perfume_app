import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../security/session_expiration.dart';
import '../security/secure_session_store.dart';

// Android's secure-storage plugin can occasionally take too long to answer
// while an app is being brought back from the background. Requests must still
// be allowed to run anonymously in that case; otherwise every public
// storefront request remains queued before Dio's own network timeouts start.
const _sessionReadTimeout = Duration(seconds: 4);

final dioProvider = Provider<Dio>((ref) {
  final sessionStore = ref.watch(sessionStoreProvider);
  final sessionExpiration = ref.watch(sessionExpirationProvider.notifier);
  final client = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: const {'Accept': 'application/json'},
    ),
  );
  client.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? token;
        try {
          token = await sessionStore.readToken().timeout(_sessionReadTimeout);
        } catch (_) {
          // A session token is optional for public endpoints. Continue the
          // request instead of leaving the app on its loading screen.
        }
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 &&
            error.requestOptions.extra['preserveSessionOnUnauthorized'] !=
                true) {
          try {
            await sessionStore.clearToken().timeout(_sessionReadTimeout);
          } catch (_) {
            // Session expiry must never hold an HTTP error open indefinitely.
          }
          sessionExpiration.notifyExpired();
        }
        handler.next(error);
      },
    ),
  );
  return client;
});
