import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sync_queue.dart';

/// A feature owns a handler for each remote write it can safely replay.
abstract interface class SyncOperationHandler {
  String get type;

  Future<void> send(Map<String, dynamic> payload);
}

class SyncReport {
  const SyncReport({
    required this.attempted,
    required this.completed,
    required this.deferred,
    required this.failed,
    this.wasAlreadyRunning = false,
  });

  const SyncReport.alreadyRunning()
    : attempted = 0,
      completed = 0,
      deferred = 0,
      failed = 0,
      wasAlreadyRunning = true;

  final int attempted;
  final int completed;
  final int deferred;
  final int failed;
  final bool wasAlreadyRunning;
}

/// Replays due operations in creation order and preserves failures for retry.
class SyncCoordinator {
  SyncCoordinator(
    this._queue, {
    required Iterable<SyncOperationHandler> handlers,
  }) : _handlers = {for (final handler in handlers) handler.type: handler};

  final SyncQueue _queue;
  final Map<String, SyncOperationHandler> _handlers;
  bool _isSyncing = false;

  Future<SyncReport> syncNow() async {
    if (_isSyncing) return const SyncReport.alreadyRunning();
    _isSyncing = true;

    var attempted = 0;
    var completed = 0;
    var deferred = 0;
    var failed = 0;

    try {
      for (final operation in await _queue.pending()) {
        final handler = _handlers[operation.type];
        if (handler == null) {
          deferred++;
          continue;
        }

        attempted++;
        try {
          final payload = Map<String, dynamic>.from(
            jsonDecode(operation.payload) as Map,
          );
          await handler.send(payload);
          await _queue.complete(operation.id);
          completed++;
        } catch (_) {
          await _queue.recordFailure(operation);
          failed++;
        }
      }
    } finally {
      _isSyncing = false;
    }

    return SyncReport(
      attempted: attempted,
      completed: completed,
      deferred: deferred,
      failed: failed,
    );
  }
}

/// Features will register their operation handlers here as their APIs are added.
final syncCoordinatorProvider = Provider<SyncCoordinator>(
  (ref) => SyncCoordinator(
    ref.watch(syncQueueProvider),
    handlers: ref.watch(syncOperationHandlersProvider),
  ),
);

/// The composition root registers feature handlers here. The core remains
/// independent from feature APIs and an operation is never replayed implicitly.
final syncOperationHandlersProvider = Provider<List<SyncOperationHandler>>(
  (ref) => const [],
);
