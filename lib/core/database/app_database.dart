import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'app_database.g.dart';

class StorefrontCache extends Table {
  TextColumn get id => text()();
  TextColumn get payload => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalCartItems extends Table {
  TextColumn get productId => text()();
  TextColumn get productPayload => text()();
  IntColumn get quantity => integer()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {productId};
}

class SyncOperations extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get payload => text()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// A durable reference to a gateway session. It deliberately contains no card
/// or payment credentials: only identifiers returned by the server, so the app
/// can safely resume payment tracking after an external browser/app return.
class PaymentSessions extends Table {
  TextColumn get invoiceId => text()();
  IntColumn get orderId => integer()();
  TextColumn get paymentType => text().nullable()();
  TextColumn get invoiceUrl => text().nullable()();
  TextColumn get invoiceStatus => text().nullable()();
  TextColumn get shipmentId => text().nullable()();
  TextColumn get labelUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastCheckedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {invoiceId};
}

/// Cached order history is scoped to the authenticated customer. It contains
/// display-only server data and is never used to create, update or pay orders.
class OrderHistorySnapshots extends Table {
  IntColumn get userId => integer()();
  TextColumn get payload => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {userId};
}

/// Cached notification inbox scoped to the authenticated customer. It is
/// display-only and cannot be used to send, acknowledge or modify a server
/// notification while offline.
class NotificationSnapshots extends Table {
  IntColumn get userId => integer()();
  TextColumn get payload => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {userId};
}

@DriftDatabase(
  tables: [
    StorefrontCache,
    LocalCartItems,
    SyncOperations,
    PaymentSessions,
    OrderHistorySnapshots,
    NotificationSnapshots,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(
        executor ??
            driftDatabase(
              name: 'rose_perfume',
              native: const DriftNativeOptions(shareAcrossIsolates: true),
              web: DriftWebOptions(
                sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                driftWorker: Uri.parse('drift_worker.js'),
              ),
            ),
      );

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(syncOperations, syncOperations.nextAttemptAt);
      }
      if (from < 3) {
        await migrator.createTable(paymentSessions);
      }
      if (from < 4) {
        await migrator.createTable(orderHistorySnapshots);
      }
      if (from < 5) {
        await migrator.createTable(notificationSnapshots);
      }
    },
  );

  Future<String?> readStorefrontPayload() async {
    final row = await (select(
      storefrontCache,
    )..where((table) => table.id.equals('storefront'))).getSingleOrNull();
    return row?.payload;
  }

  Future<DateTime?> readStorefrontUpdatedAt() async {
    final row = await (select(
      storefrontCache,
    )..where((table) => table.id.equals('storefront'))).getSingleOrNull();
    return row?.updatedAt;
  }

  Future<void> saveStorefrontPayload(String payload) =>
      into(storefrontCache).insertOnConflictUpdate(
        StorefrontCacheCompanion.insert(
          id: 'storefront',
          payload: payload,
          updatedAt: DateTime.now(),
        ),
      );

  Future<List<LocalCartItem>> readCartItems() => select(localCartItems).get();

  Future<void> replaceCartItems(List<LocalCartItemsCompanion> items) async {
    await transaction(() async {
      await delete(localCartItems).go();
      if (items.isNotEmpty) {
        await batch((batch) => batch.insertAll(localCartItems, items));
      }
    });
  }

  Future<void> enqueueOperation(SyncOperationsCompanion operation) =>
      into(syncOperations).insertOnConflictUpdate(operation);

  Future<PaymentSession?> readLatestPaymentSession() =>
      (select(paymentSessions)
            ..orderBy([(table) => OrderingTerm.desc(table.createdAt)])
            ..limit(1))
          .getSingleOrNull();

  Future<PaymentSession?> readPaymentSession(String invoiceId) => (select(
    paymentSessions,
  )..where((table) => table.invoiceId.equals(invoiceId))).getSingleOrNull();

  Future<void> savePaymentSession(PaymentSessionsCompanion session) =>
      into(paymentSessions).insertOnConflictUpdate(session);

  Future<String?> readOrderHistoryPayload(int userId) async => (await (select(
    orderHistorySnapshots,
  )..where((table) => table.userId.equals(userId))).getSingleOrNull())?.payload;

  Future<void> saveOrderHistoryPayload({
    required int userId,
    required String payload,
  }) => into(orderHistorySnapshots).insertOnConflictUpdate(
    OrderHistorySnapshotsCompanion.insert(
      userId: Value(userId),
      payload: payload,
      updatedAt: DateTime.now(),
    ),
  );

  Future<String?> readNotificationPayload(int userId) async => (await (select(
    notificationSnapshots,
  )..where((table) => table.userId.equals(userId))).getSingleOrNull())?.payload;

  Future<void> saveNotificationPayload({
    required int userId,
    required String payload,
  }) => into(notificationSnapshots).insertOnConflictUpdate(
    NotificationSnapshotsCompanion.insert(
      userId: Value(userId),
      payload: payload,
      updatedAt: DateTime.now(),
    ),
  );

  /// Clears only customer-specific material when a session ends. Storefront
  /// content stays available offline for the next visitor.
  Future<void> clearCustomerData() => transaction(() async {
    await delete(localCartItems).go();
    // Pending operations are tied to the authenticated customer. Never replay
    // a previous customer's changes after someone else signs in on this device.
    await delete(syncOperations).go();
    await delete(paymentSessions).go();
    await delete(orderHistorySnapshots).go();
    await delete(notificationSnapshots).go();
  });
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(() {
    database.close();
  });
  return database;
});
