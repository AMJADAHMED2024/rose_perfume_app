import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Broadcasts an authenticated-session expiry to application state. The token
/// itself is cleared by the network client; listeners can then remove only
/// customer-owned local data and return the UI to signed-out state.
class SessionExpirationNotifier extends StateNotifier<int> {
  SessionExpirationNotifier() : super(0);

  void notifyExpired() => state++;
}

final sessionExpirationProvider =
    StateNotifierProvider<SessionExpirationNotifier, int>(
      (ref) => SessionExpirationNotifier(),
    );
