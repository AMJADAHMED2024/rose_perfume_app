import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/localization/app_copy.dart';
import '../../../core/models/product.dart';
import '../../../core/network/api_client.dart';
import '../../../core/state/cart_controller.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../../../core/widgets/app_page_components.dart';
import '../../home/application/storefront_controller.dart';
import '../../reviews/presentation/product_reviews_section.dart';
import 'widgets/product_gallery.dart';

final productDetailProvider = FutureProvider.autoDispose
    .family<Product, String>((ref, id) async {
      final response = await ref
          .watch(dioProvider)
          .get<dynamic>('/api/product/get-by-id', queryParameters: {'id': id});
      final body = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : const <String, dynamic>{};
      final data = body['data'] is Map
          ? Map<String, dynamic>.from(body['data'] as Map)
          : const <String, dynamic>{};
      return Product.fromJson(data);
    });

final selectedProductVariantProvider = StateProvider.autoDispose
    .family<ProductVariant?, String>((ref, _) => null);

class ProductDetailPage extends ConsumerWidget {
  const ProductDetailPage({
    super.key,
    required this.productId,
    required this.cart,
  });
  final String productId;
  final CartController cart;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = AppCopy.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: ref
          .watch(storefrontProvider)
          .when(
            loading: () => const SkeletonPage(layout: SkeletonLayout.details),
            error: (_, _) => AppEmptyState(
              icon: Icons.cloud_off_outlined,
              title: copy.pair('تعذر تحميل المنتج', 'Could not load product'),
              message: copy.pair(
                'تحقق من اتصالك ثم حاول مرة أخرى.',
                'Check your connection and try again.',
              ),
            ),
            data: (store) {
              final matches = store.products.where(
                (item) => item.id == productId,
              );
              if (matches.isEmpty) {
                return AppEmptyState(
                  icon: Icons.search_off_rounded,
                  title: copy.pair('المنتج غير موجود', 'Product not found'),
                  message: copy.pair(
                    'قد يكون المنتج غير متاح أو تم نقله من المتجر.',
                    'The product may be unavailable or moved from the store.',
                  ),
                );
              }
              final loadedProduct = ref.watch(productDetailProvider(productId));
              final product = loadedProduct.valueOrNull ?? matches.first;
              final selectedVariant = ref.watch(
                selectedProductVariantProvider(productId),
              );
              final visibleProduct = selectedVariant == null
                  ? product
                  : product.withVariant(selectedVariant);
              final reviewProductId = int.tryParse(visibleProduct.id);
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      LayoutBuilder(
                        builder: (context, size) {
                          final images = visibleProduct.imageUrls.isNotEmpty
                              ? visibleProduct.imageUrls
                              : visibleProduct.imageUrl == null
                              ? const <String>[]
                              : [visibleProduct.imageUrl!];
                          final image = ProductGallery(
                            images: images,
                            label:
                                copy.isEnglish || visibleProduct.nameAr.isEmpty
                                ? visibleProduct.nameEn
                                : visibleProduct.nameAr,
                          );
                          final details = AppSectionCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  visibleProduct.categoryNameAr ??
                                      'Rose Perfume',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  copy.isEnglish ||
                                          visibleProduct.nameAr.isEmpty
                                      ? visibleProduct.nameEn
                                      : visibleProduct.nameAr,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  visibleProduct.descriptionAr?.isNotEmpty ==
                                          true
                                      ? visibleProduct.descriptionAr!
                                      : copy.pair(
                                          'عطر أصلي مختار بعناية من روز برفيوم.',
                                          'An authentic fragrance, carefully selected by Rose Perfume.',
                                        ),
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  children: [
                                    Text(
                                      '${visibleProduct.salePrice.toStringAsFixed(0)} ر.س',
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    if (visibleProduct.isDiscounted) ...[
                                      const SizedBox(width: 10),
                                      Text(
                                        '${visibleProduct.price.toStringAsFixed(0)} ر.س',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: .42),
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                if (!visibleProduct.isInStock) ...[
                                  const SizedBox(height: 14),
                                  AppFeedbackBanner(
                                    message: copy.pair(
                                      'هذا المنتج غير متاح حالياً.',
                                      'This product is currently unavailable.',
                                    ),
                                    tone: AppBannerTone.warning,
                                  ),
                                ],
                                const SizedBox(height: 20),
                                if (product.variants.isNotEmpty) ...[
                                  Text(
                                    copy.pair('اختر الحجم', 'Choose size'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: product.variants
                                        .map(
                                          (variant) => ChoiceChip(
                                            label: Text(
                                              '${variant.name.isEmpty ? '${variant.weightInGram.toStringAsFixed(0)} ${copy.pair('جم', 'g')}' : variant.name} · ${variant.price.toStringAsFixed(0)} ${copy.pair('ر.س', 'SAR')}',
                                            ),
                                            selected:
                                                selectedVariant?.id ==
                                                variant.id,
                                            onSelected: (_) =>
                                                ref
                                                        .read(
                                                          selectedProductVariantProvider(
                                                            productId,
                                                          ).notifier,
                                                        )
                                                        .state =
                                                    selectedVariant?.id ==
                                                        variant.id
                                                    ? null
                                                    : variant,
                                          ),
                                        )
                                        .toList(),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                                SizedBox(
                                  width: 230,
                                  child: FilledButton.icon(
                                    onPressed: visibleProduct.isInStock
                                        ? () => cart.add(visibleProduct)
                                        : null,
                                    icon: const Icon(
                                      Icons.add_shopping_cart_outlined,
                                    ),
                                    label: Text(
                                      copy.pair('أضف للسلة', 'Add to cart'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                          return size.maxWidth >= 700
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 460,
                                        child: image,
                                      ),
                                    ),
                                    const SizedBox(width: 40),
                                    Expanded(child: details),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 390, child: image),
                                    const SizedBox(height: 24),
                                    details,
                                  ],
                                );
                        },
                      ),
                      if (reviewProductId != null)
                        ProductReviewsSection(productId: reviewProductId),
                      _SimilarProducts(
                        productId: product.id,
                        categoryId: product.categoryId,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}

class _SimilarProducts extends ConsumerWidget {
  const _SimilarProducts({required this.productId, required this.categoryId});

  final String productId;
  final int? categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = AppCopy.of(context);
    return ref
        .watch(storefrontProvider)
        .maybeWhen(
          data: (store) {
            final items = store.products
                .where(
                  (item) =>
                      item.id != productId &&
                      (categoryId == null || item.categoryId == categoryId),
                )
                .take(4)
                .toList();
            if (items.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    copy.pair('قد يعجبك أيضًا', 'You may also like'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 190,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (_, index) {
                        final item = items[index];
                        return SizedBox(
                          width: 180,
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () => context.push('/products/${item.id}'),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withValues(alpha: .04),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: _productImageUrl(
                                            item.imageUrl,
                                          ),
                                          fit: BoxFit.contain,
                                          errorWidget: (_, _, _) => Icon(
                                            Icons.auto_awesome_outlined,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      copy.isEnglish || item.nameAr.isEmpty
                                          ? item.nameEn
                                          : item.nameAr,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      '${item.salePrice.toStringAsFixed(0)} ر.س',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
          orElse: () => const SizedBox.shrink(),
        );
  }
}

String _productImageUrl(String? path) => path?.startsWith('http') == true
    ? path!
    : '${AppConfig.apiBaseUrl}${path ?? ''}';
