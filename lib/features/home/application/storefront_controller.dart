import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/database/app_database.dart';
import '../data/storefront_repository.dart';
import '../domain/storefront.dart';

final storefrontRepositoryProvider = Provider<StorefrontRepository>(
  (ref) => StorefrontRepository(
    ref.watch(dioProvider),
    ref.watch(appDatabaseProvider),
  ),
);

final storefrontProvider =
    AsyncNotifierProvider<StorefrontController, Storefront>(
      StorefrontController.new,
    );

class StorefrontController extends AsyncNotifier<Storefront> {
  static const _cacheLoadTimeout = Duration(seconds: 5);
  static const _networkLoadTimeout = Duration(seconds: 25);

  @override
  Future<Storefront> build() async {
    final repository = ref.read(storefrontRepositoryProvider);
    Storefront? cached;
    try {
      cached = await repository.readCached().timeout(_cacheLoadTimeout);
    } catch (_) {
      // A damaged or unavailable local database must not block the public
      // storefront from trying the network.
    }
    if (cached != null) {
      unawaited(refresh());
      return cached;
    }
    return _fetchWithTimeout(repository);
  }

  Future<void> refresh() async {
    final next = await AsyncValue.guard(
      () => _fetchWithTimeout(ref.read(storefrontRepositoryProvider)),
    );
    if (next.hasValue) state = next;
  }

  Future<Storefront> _fetchWithTimeout(StorefrontRepository repository) =>
      repository.fetchAndCache().timeout(
        _networkLoadTimeout,
        onTimeout: () =>
            throw TimeoutException('Timed out while loading the storefront.'),
      );
}
