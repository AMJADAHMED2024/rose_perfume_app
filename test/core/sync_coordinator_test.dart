import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rose_perfume_app/core/database/app_database.dart';
import 'package:rose_perfume_app/core/sync/sync_coordinator.dart';
import 'package:rose_perfume_app/core/sync/sync_queue.dart';

void main() {
  late AppDatabase database;
  late SyncQueue queue;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    queue = SyncQueue(database);
  });

  tearDown(() => database.close());

  test(
    'replays a handled operation and removes it only after success',
    () async {
      await queue.enqueue(type: 'save_note', payload: {'id': 'note-1'});
      final handler = _Handler('save_note');
      final coordinator = SyncCoordinator(queue, handlers: [handler]);

      final report = await coordinator.syncNow();

      expect(handler.payloads, [
        {'id': 'note-1'},
      ]);
      expect(report.completed, 1);
      expect(await queue.pending(), isEmpty);
    },
  );

  test('keeps a failed operation and delays its next attempt', () async {
    await queue.enqueue(type: 'save_note', payload: {'id': 'note-1'});
    final coordinator = SyncCoordinator(
      queue,
      handlers: [_Handler('save_note', shouldFail: true)],
    );

    final report = await coordinator.syncNow();
    final stored = await database.select(database.syncOperations).getSingle();

    expect(report.failed, 1);
    expect(stored.retryCount, 1);
    expect(stored.nextAttemptAt, isNotNull);
    expect(await queue.pending(now: DateTime.now()), isEmpty);
  });

  test(
    'preserves operations when their feature is not registered yet',
    () async {
      await queue.enqueue(type: 'future_feature', payload: {'id': 'later'});
      final coordinator = SyncCoordinator(queue, handlers: const []);

      final report = await coordinator.syncNow();

      expect(report.deferred, 1);
      expect(await queue.pending(), hasLength(1));
    },
  );
}

class _Handler implements SyncOperationHandler {
  _Handler(this.type, {this.shouldFail = false});

  @override
  final String type;
  final bool shouldFail;
  final List<Map<String, dynamic>> payloads = [];

  @override
  Future<void> send(Map<String, dynamic> payload) async {
    if (shouldFail) throw StateError('Network unavailable');
    payloads.add(payload);
  }
}
