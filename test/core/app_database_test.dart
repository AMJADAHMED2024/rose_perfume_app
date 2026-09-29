import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:rose_perfume_app/core/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('persists a storefront snapshot with its refresh time', () async {
    final refreshedAt = DateTime(2026, 9, 22);
    await database
        .into(database.storefrontCache)
        .insert(
          StorefrontCacheCompanion.insert(
            id: 'storefront',
            payload: '{"products":[]}',
            updatedAt: refreshedAt,
          ),
        );

    expect(await database.readStorefrontPayload(), '{"products":[]}');
    expect(await database.readStorefrontUpdatedAt(), refreshedAt);
  });

  test('replaces cart lines as one local snapshot', () async {
    final updatedAt = DateTime(2026, 9, 22);
    await database.replaceCartItems([
      LocalCartItemsCompanion.insert(
        productId: 'rose-1',
        productPayload: '{"id":"rose-1"}',
        quantity: 2,
        updatedAt: updatedAt,
      ),
    ]);

    final items = await database.readCartItems();
    expect(items, hasLength(1));
    expect(items.single.productId, 'rose-1');
    expect(items.single.quantity, 2);
  });

  test('keeps the latest payment session across app restarts', () async {
    final createdAt = DateTime(2026, 9, 23, 1);
    await database.savePaymentSession(
      PaymentSessionsCompanion.insert(
        invoiceId: 'invoice-42',
        orderId: 42,
        paymentType: const Value('MYFATOORAH'),
        invoiceStatus: const Value('Pending'),
        createdAt: createdAt,
      ),
    );

    final payment = await database.readLatestPaymentSession();
    expect(payment?.invoiceId, 'invoice-42');
    expect(payment?.orderId, 42);
    expect(payment?.invoiceStatus, 'Pending');
  });

  test('keeps order history isolated by customer', () async {
    await database.saveOrderHistoryPayload(userId: 101, payload: '[{"id":1}]');
    await database.saveOrderHistoryPayload(userId: 202, payload: '[{"id":2}]');

    expect(await database.readOrderHistoryPayload(101), '[{"id":1}]');
    expect(await database.readOrderHistoryPayload(202), '[{"id":2}]');
  });

  test('keeps notification inboxes isolated by customer', () async {
    await database.saveNotificationPayload(userId: 101, payload: '[{"id":1}]');
    await database.saveNotificationPayload(userId: 202, payload: '[{"id":2}]');

    expect(await database.readNotificationPayload(101), '[{"id":1}]');
    expect(await database.readNotificationPayload(202), '[{"id":2}]');
  });

  test('clears account data but keeps the storefront cache', () async {
    await database.saveStorefrontPayload('{"products":["rose"]}');
    await database.saveOrderHistoryPayload(userId: 101, payload: '[]');
    await database.saveNotificationPayload(userId: 101, payload: '[]');
    await database.savePaymentSession(
      PaymentSessionsCompanion.insert(
        invoiceId: 'invoice-private',
        orderId: 7,
        createdAt: DateTime(2026, 9, 23),
      ),
    );

    await database.clearCustomerData();

    expect(await database.readStorefrontPayload(), '{"products":["rose"]}');
    expect(await database.readOrderHistoryPayload(101), isNull);
    expect(await database.readNotificationPayload(101), isNull);
    expect(await database.readLatestPaymentSession(), isNull);
  });
}
