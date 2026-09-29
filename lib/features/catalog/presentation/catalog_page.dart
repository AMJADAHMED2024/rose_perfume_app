import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/localization/app_copy.dart';
import '../../../core/models/product.dart';
import '../../../core/state/cart_controller.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../../../core/widgets/app_page_components.dart';
import '../../../core/widgets/adaptive_layout.dart';
import '../../home/application/storefront_controller.dart';

class CatalogPage extends ConsumerStatefulWidget {
  const CatalogPage({
    super.key,
    required this.cart,
    this.initialCategoryId,
    this.initialQuery = '',
  });
  final CartController cart;
  final int? initialCategoryId;
  final String initialQuery;
  @override
  ConsumerState<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends ConsumerState<CatalogPage> {
  String _query = '';
  int? _categoryId;
  bool _saleOnly = false;
  double? _minimumPrice;
  double? _maximumPrice;
  _CatalogSort _sort = _CatalogSort.featured;
  @override
  void initState() {
    super.initState();
    _categoryId = widget.initialCategoryId;
    _query = widget.initialQuery.trim();
  }

  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);
    final state = ref.watch(storefrontProvider);
    return Scaffold(
      appBar: AppBar(title: Text(copy.shop)),
      body: state.when(
        loading: () => const SkeletonPage(layout: SkeletonLayout.grid),
        error: (_, _) => const AppEmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'تعذر تحميل المنتجات',
          message: 'تحقق من اتصالك ثم أعد المحاولة.',
        ),
        data: (store) {
          final prices = store.products.map((product) => product.salePrice);
          final catalogMinimum = prices.isEmpty
              ? 0.0
              : prices.reduce((value, price) => value < price ? value : price);
          final rawMaximum = prices.isEmpty
              ? 1.0
              : prices.reduce((value, price) => value > price ? value : price);
          final catalogMaximum = rawMaximum <= catalogMinimum
              ? catalogMinimum + 1
              : rawMaximum;
          final minimumPrice = (_minimumPrice ?? catalogMinimum).clamp(
            catalogMinimum,
            catalogMaximum,
          );
          final maximumPrice = (_maximumPrice ?? catalogMaximum).clamp(
            minimumPrice,
            catalogMaximum,
          );
          var products = store.products.where(
            (item) =>
                (!_saleOnly || item.isDiscounted) &&
                item.salePrice >= minimumPrice &&
                item.salePrice <= maximumPrice,
          );
          if (_categoryId != null) {
            products = products.where((item) => item.categoryId == _categoryId);
          }
          if (_query.isNotEmpty) {
            products = products.where(
              (item) => item.name.toLowerCase().contains(_query.toLowerCase()),
            );
          }
          final items = products.toList()
            ..sort(
              (left, right) => switch (_sort) {
                _CatalogSort.priceLowToHigh => left.salePrice.compareTo(
                  right.salePrice,
                ),
                _CatalogSort.priceHighToLow => right.salePrice.compareTo(
                  left.salePrice,
                ),
                _CatalogSort.name => left.name.compareTo(right.name),
                _CatalogSort.featured => (right.isFeatured ? 1 : 0).compareTo(
                  left.isFeatured ? 1 : 0,
                ),
              },
            );
          return AdaptivePage(
            maxWidth: 1280,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 1100
                    ? 4
                    : constraints.maxWidth >= 680
                    ? 3
                    : 2;
                return CustomScrollView(
                  slivers: [
                    const SliverPadding(
                      padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
                      sliver: SliverToBoxAdapter(
                        child: AppPageHeader(
                          title: 'اكتشف عطورنا',
                          subtitle: 'اختيارات فاخرة تناسب كل مناسبة.',
                          icon: Icons.auto_awesome_outlined,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
                      sliver: SliverToBoxAdapter(
                        child: TextField(
                          onChanged: (value) => setState(() => _query = value),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText: copy.searchHint,
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 48,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            ChoiceChip(
                              label: Text(copy.all),
                              selected: _categoryId == null,
                              onSelected: (_) =>
                                  setState(() => _categoryId = null),
                            ),
                            const SizedBox(width: 8),
                            ...store.categories.map(
                              (category) => Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  end: 8,
                                ),
                                child: ChoiceChip(
                                  label: Text(category.name),
                                  selected: _categoryId == category.id,
                                  onSelected: (_) =>
                                      setState(() => _categoryId = category.id),
                                ),
                              ),
                            ),
                            FilterChip(
                              label: Text(copy.offers),
                              selected: _saleOnly,
                              onSelected: (value) =>
                                  setState(() => _saleOnly = value),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      sliver: SliverToBoxAdapter(
                        child: Card(
                          child: ExpansionTile(
                            leading: const Icon(Icons.tune_outlined),
                            title: Text(copy.filters),
                            childrenPadding: const EdgeInsets.fromLTRB(
                              16,
                              0,
                              16,
                              16,
                            ),
                            children: [
                              DropdownButtonFormField<_CatalogSort>(
                                initialValue: _sort,
                                decoration: const InputDecoration(
                                  labelText: 'الترتيب',
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: _CatalogSort.featured,
                                    child: Text('الأكثر تميزًا'),
                                  ),
                                  DropdownMenuItem(
                                    value: _CatalogSort.priceLowToHigh,
                                    child: Text('السعر: من الأقل للأعلى'),
                                  ),
                                  DropdownMenuItem(
                                    value: _CatalogSort.priceHighToLow,
                                    child: Text('السعر: من الأعلى للأقل'),
                                  ),
                                  DropdownMenuItem(
                                    value: _CatalogSort.name,
                                    child: Text('الاسم'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _sort = value);
                                  }
                                },
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'السعر: ${minimumPrice.toStringAsFixed(0)} - ${maximumPrice.toStringAsFixed(0)} ر.س',
                              ),
                              RangeSlider(
                                min: catalogMinimum,
                                max: catalogMaximum,
                                values: RangeValues(minimumPrice, maximumPrice),
                                onChanged: (range) => setState(() {
                                  _minimumPrice = range.start;
                                  _maximumPrice = range.end;
                                }),
                              ),
                              Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: TextButton(
                                  onPressed: () => setState(() {
                                    _minimumPrice = null;
                                    _maximumPrice = null;
                                    _sort = _CatalogSort.featured;
                                  }),
                                  child: Text(copy.resetFilters),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (items.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: AppEmptyState(
                          icon: Icons.search_off_rounded,
                          title: 'لا توجد نتائج مطابقة',
                          message: copy.noMatchingProducts,
                          actionLabel: 'إعادة التصفية',
                          onAction: () => setState(() {
                            _query = '';
                            _categoryId = null;
                            _saleOnly = false;
                            _minimumPrice = null;
                            _maximumPrice = null;
                          }),
                        ),
                      ),
                    SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverGrid.builder(
                        itemCount: items.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: .62,
                        ),
                        itemBuilder: (_, index) => _CatalogCard(
                          product: items[index],
                          cart: widget.cart,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

enum _CatalogSort { featured, priceLowToHigh, priceHighToLow, name }

class _CatalogCard extends StatelessWidget {
  const _CatalogCard({required this.product, required this.cart});
  final Product product;
  final CartController cart;
  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => context.push('/products/${product.id}'),
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: .035),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: _url(product.imageUrl),
                        fit: BoxFit.contain,
                        errorWidget: (_, _, _) =>
                            const Icon(Icons.image_not_supported_outlined),
                      ),
                    ),
                  ),
                  if (product.isDiscounted)
                    PositionedDirectional(
                      top: 8,
                      start: 8,
                      child: _ProductBadge(
                        label: 'عرض',
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  if (!product.isInStock)
                    const PositionedDirectional(
                      top: 8,
                      end: 8,
                      child: _ProductBadge(
                        label: 'نفد',
                        color: Color(0xFF6E6568),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 11),
            SizedBox(
              height: 40,
              child: Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '${product.salePrice.toStringAsFixed(0)} ر.س',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (product.isDiscounted) ...[
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      product.price.toStringAsFixed(0),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: .42),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: product.isInStock ? () => cart.add(product) : null,
                icon: const Icon(Icons.add_shopping_cart_outlined, size: 18),
                label: Text(product.isInStock ? 'أضف للسلة' : 'غير متاح'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ProductBadge extends StatelessWidget {
  const _ProductBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(9),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

String _url(String? path) => path?.startsWith('http') == true
    ? path!
    : '${AppConfig.apiBaseUrl}${path ?? ''}';
