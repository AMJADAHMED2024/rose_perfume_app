import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/config/app_config.dart';
import '../../../core/localization/app_copy.dart';
import '../../../core/models/product.dart';
import '../../../core/state/cart_controller.dart';
import '../../../core/widgets/responsive_center.dart';

class CartPage extends StatelessWidget {
  const CartPage({
    super.key,
    required this.cart,
    required this.onContinueShopping,
    required this.onCheckout,
  });

  final CartController cart;
  final VoidCallback onContinueShopping;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);
    return AnimatedBuilder(
      animation: cart,
      builder: (context, _) {
        if (cart.count == 0) {
          return _EmptyCart(onContinueShopping: onContinueShopping, copy: copy);
        }
        return ResponsiveCenter(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: .09),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      copy.cart,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                copy.itemsInCart(cart.count),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 22),
              ...cart.products.map(
                (product) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CartProductCard(product: product, cart: cart),
                ),
              ),
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            copy.total,
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          Text(
                            '${cart.subtotal.toStringAsFixed(0)} ر.س',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: onCheckout,
                          icon: const Icon(Icons.arrow_back_rounded),
                          label: Text(copy.checkout),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CartProductCard extends StatelessWidget {
  const _CartProductCard({required this.product, required this.cart});
  final Product product;
  final CartController cart;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(
              imageUrl: _productImageUrl(product.imageUrl),
              width: 78,
              height: 78,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 5),
                Text(
                  '${product.salePrice.toStringAsFixed(0)} ر.س',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 9),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: .07),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => cart.removeOne(product),
                        icon: const Icon(Icons.remove_rounded),
                      ),
                      SizedBox(
                        width: 26,
                        child: Text(
                          '${cart.quantityFor(product)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => cart.add(product),
                        icon: const Icon(Icons.add_rounded),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

String _productImageUrl(String? path) => path?.startsWith('http') == true
    ? path!
    : '${AppConfig.apiBaseUrl}${path ?? ''}';

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onContinueShopping, required this.copy});
  final VoidCallback onContinueShopping;
  final AppCopy copy;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 70,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              copy.emptyCart,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(copy.emptyCartMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onContinueShopping,
              child: Text(copy.shopNow),
            ),
          ],
        ),
      ),
    );
  }
}
