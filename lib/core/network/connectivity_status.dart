import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Network reachability for presentation only. Cached data remains usable when
/// this reports offline; it must never be used as proof that the internet is
/// actually reachable for a payment or a write.
final connectivityStatusProvider = StreamProvider<List<ConnectivityResult>>((
  ref,
) async* {
  final connectivity = Connectivity();
  yield await connectivity.checkConnectivity();
  yield* connectivity.onConnectivityChanged;
});
