import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';

/// Persistent outbox for writes created while the device is offline.
class SyncQueue {
  const SyncQueue(this._database);
  final AppDatabase _database;

  Future<void> enqueue({
    required String type,
    required Map<String, dynamic> payload,
  }) {
    final now = DateTime.now();
    return _database.enqueueOperation(
      SyncOperationsCompanion.insert(
        id: '$type-${now.microsecondsSinceEpoch}',
        type: type,
        payload: jsonEncode(payload),
        createdAt: now,
      ),
    );
  }

  Future<List<SyncOperation>> pending({DateTime? now}) async {
    final operations = await (_database.select(
      _database.syncOperations,
    )..orderBy([(table) => OrderingTerm.asc(table.createdAt)])).get();
    final currentTime = now ?? DateTime.now();
    return operations
        .where(
          (operation) =>
              operation.nextAttemptAt == null ||
              !operation.nextAttemptAt!.isAfter(currentTime),
        )
        .toList();
  }

  Future<void> complete(String id) {
    return (_database.delete(
      _database.syncOperations,
    )..where((table) => table.id.equals(id))).go();
  }

  Future<void> recordFailure(SyncOperation operation) {
    final retries = operation.retryCount + 1;
    final retryMinutes = min(1 << min(retries - 1, 6), 60);
    return (_database.update(
      _database.syncOperations,
    )..where((table) => table.id.equals(operation.id))).write(
      SyncOperationsCompanion(
        retryCount: Value(retries),
        nextAttemptAt: Value(
          DateTime.now().add(Duration(minutes: retryMinutes)),
        ),
      ),
    );
  }

  Future<void> retryImmediately(String id) {
    return (_database.update(_database.syncOperations)
          ..where((table) => table.id.equals(id)))
        .write(const SyncOperationsCompanion(nextAttemptAt: Value(null)));
  }
}

final syncQueueProvider = Provider<SyncQueue>(
  (ref) => SyncQueue(ref.watch(appDatabaseProvider)),
);
