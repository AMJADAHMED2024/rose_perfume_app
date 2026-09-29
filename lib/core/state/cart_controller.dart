import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import '../database/app_database.dart';
import '../models/product.dart';

class CartController extends ChangeNotifier {
  final Map<String, _CartEntry> _items = {};
  final AppDatabase _database;

  CartController(this._database) {
    unawaited(_restore());
  }

  int get count => _items.values.fold(0, (sum, entry) => sum + entry.quantity);

  Iterable<Product> get products => _items.values.map((entry) => entry.product);

  int quantityFor(Product product) => _items[product.cartKey]?.quantity ?? 0;

  double get subtotal => products.fold(
    0,
    (sum, product) => sum + product.salePrice * quantityFor(product),
  );

  double get totalWeightKg => products.fold(
    0,
    (sum, product) => sum + product.weightKg * quantityFor(product),
  );

  void add(Product product) {
    _items.update(
      product.cartKey,
      (entry) => _CartEntry(product, entry.quantity + 1),
      ifAbsent: () => _CartEntry(product, 1),
    );
    unawaited(_persist());
    notifyListeners();
  }

  void removeOne(Product product) {
    final entry = _items[product.cartKey];
    if (entry == null) return;
    if (entry.quantity == 1) {
      _items.remove(product.cartKey);
    } else {
      _items[product.cartKey] = _CartEntry(product, entry.quantity - 1);
    }
    unawaited(_persist());
    notifyListeners();
  }

  Future<void> clear() async {
    _items.clear();
    await _persist();
    notifyListeners();
  }

  Future<void> _restore() async {
    final rows = await _database.readCartItems();
    try {
      for (final item in rows) {
        final product = Product.fromJson(
          Map<String, dynamic>.from(jsonDecode(item.productPayload) as Map),
        );
        final quantity = item.quantity;
        if (quantity > 0) {
          _items[product.cartKey] = _CartEntry(product, quantity);
        }
      }
      notifyListeners();
    } on FormatException {
      // Ignore an invalid cached cart; it will be replaced on the next change.
    }
  }

  Future<void> _persist() async {
    await _database.replaceCartItems(
      _items.values
          .map(
            (entry) => LocalCartItemsCompanion.insert(
              productId: entry.product.cartKey,
              productPayload: jsonEncode(entry.product.toJson()),
              quantity: entry.quantity,
              updatedAt: DateTime.now(),
            ),
          )
          .toList(),
    );
  }
}

class _CartEntry {
  const _CartEntry(this.product, this.quantity);
  final Product product;
  final int quantity;
}
