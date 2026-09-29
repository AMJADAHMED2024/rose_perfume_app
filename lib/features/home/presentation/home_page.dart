import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/localization/app_copy.dart';
import '../../../core/models/product.dart';
import '../../../core/network/connectivity_status.dart';
import '../../../core/state/cart_controller.dart';
import '../../../core/widgets/responsive_center.dart';
import '../../../core/widgets/app_page_components.dart';
import '../application/storefront_controller.dart';
import '../domain/storefront.dart';

class HomePage extends ConsumerWidget {
  HomePage({super.key, required this.cart, required this.onOpenCart});
  final CartController cart;
  final VoidCallback onOpenCart;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final english = _isEnglish(context);
    final network = ref.watch(connectivityStatusProvider).valueOrNull;
    final offline =
        network != null &&
        network.every((result) => result == ConnectivityResult.none);
    return Scaffold(
      key: _scaffoldKey,
      drawer: const _StoreDrawer(),
      floatingActionButton: const _QuickContactButtons(),
      body: ref
          .watch(storefrontProvider)
          .when(
            loading: () => const _HomeSkeleton(),
            error: (_, _) => AppEmptyState(
              icon: Icons.cloud_off_outlined,
              title: 'تعذر الوصول للمتجر',
              message: 'تحقق من اتصالك ثم أعد المحاولة.',
              actionLabel: 'إعادة المحاولة',
              onAction: () => ref.read(storefrontProvider.notifier).refresh(),
            ),
            data: (store) => RefreshIndicator(
              onRefresh: () => ref.read(storefrontProvider.notifier).refresh(),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _Header(
                      onOpenCart: onOpenCart,
                      onAccount: () => context.go('/account'),
                      onMenu: () => _scaffoldKey.currentState?.openDrawer(),
                      cart: cart,
                    ),
                  ),
                  if (offline)
                    const SliverToBoxAdapter(child: _OfflineNotice()),
                  SliverToBoxAdapter(child: _Hero(sliders: store.sliders)),
                  _Section(
                    title: _text(
                      english,
                      'تسوّق حسب الفئة',
                      'Shop by category',
                    ),
                    onViewAll: () => context.go('/products'),
                    child: _Categories(items: _sortedCategories(store)),
                  ),
                  if (_bannersFor(store, const [
                    'afterCategoriesSection',
                  ]).isNotEmpty)
                    SliverToBoxAdapter(
                      child: _Banners(
                        items: _bannersFor(store, const [
                          'afterCategoriesSection',
                        ]),
                      ),
                    ),
                  _ProductsSection(
                    title: _text(
                      english,
                      'المنتجات المميزة',
                      'Featured products',
                    ),
                    products: store.featured.isEmpty
                        ? store.recent
                        : store.featured,
                    cart: cart,
                  ),
                  if (store.newArrivalsEnabled)
                    _ProductsSection(
                      title: _text(english, 'وصل حديثًا', 'New arrivals'),
                      products: store.recent,
                      cart: cart,
                    ),
                  if (_bannersFor(store, const [
                    'afterRecentlyAddSection',
                  ]).isNotEmpty)
                    SliverToBoxAdapter(
                      child: _Banners(
                        items: _bannersFor(store, const [
                          'afterRecentlyAddSection',
                        ]),
                      ),
                    ),
                  if (_bannersFor(store, const [
                    'afterFeaturedSection',
                  ]).isNotEmpty)
                    SliverToBoxAdapter(
                      child: _Banners(
                        items: _bannersFor(store, const [
                          'afterFeaturedSection',
                        ]),
                      ),
                    ),
                  if (_productsFor(store, const ['رجالي', 'men']).isNotEmpty)
                    _ProductsSection(
                      title: _text(
                        english,
                        'عطور رجالية مختارة',
                        'Men’s fragrances',
                      ),
                      products: _productsFor(store, const ['رجالي', 'men']),
                      cart: cart,
                    ),
                  if (_bannersFor(store, const ['afterMenSection']).isNotEmpty)
                    SliverToBoxAdapter(
                      child: _Banners(
                        items: _bannersFor(store, const ['afterMenSection']),
                      ),
                    ),
                  if (_productsFor(store, const ['نسائي', 'women']).isNotEmpty)
                    _ProductsSection(
                      title: _text(
                        english,
                        'عطور نسائية ساحرة',
                        'Women’s fragrances',
                      ),
                      products: _productsFor(store, const ['نسائي', 'women']),
                      cart: cart,
                    ),
                  if (_bannersFor(store, const [
                    'afterWomenSection',
                  ]).isNotEmpty)
                    SliverToBoxAdapter(
                      child: _Banners(
                        items: _bannersFor(store, const ['afterWomenSection']),
                      ),
                    ),
                  if (_productsFor(store, const [
                    'عود',
                    'بخور',
                    'oud',
                    'incense',
                  ]).isNotEmpty)
                    _ProductsSection(
                      title: _text(english, 'العود والبخور', 'Oud & incense'),
                      products: _productsFor(store, const [
                        'عود',
                        'بخور',
                        'oud',
                        'incense',
                      ]),
                      cart: cart,
                    ),
                  if (_bannersFor(store, const [
                    'afterIncenseAndOudSection',
                  ]).isNotEmpty)
                    SliverToBoxAdapter(
                      child: _Banners(
                        items: _bannersFor(store, const [
                          'afterIncenseAndOudSection',
                        ]),
                      ),
                    ),
                  if (store.sale.isNotEmpty)
                    _ProductsSection(
                      title: _text(english, 'عروض خاصة', 'Special offers'),
                      products: store.sale,
                      cart: cart,
                    ),
                  if (_bannersFor(store, const [
                    'afterDiscountedSection',
                  ]).isNotEmpty)
                    SliverToBoxAdapter(
                      child: _Banners(
                        items: _bannersFor(store, const [
                          'afterDiscountedSection',
                        ]),
                      ),
                    ),
                  if (store.testimonials.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _Testimonials(items: store.testimonials),
                    ),
                  const SliverToBoxAdapter(child: _Footer()),
                ],
              ),
            ),
          ),
    );
  }

  List<Product> _productsFor(Storefront store, List<String> terms) {
    final categoryIds = store.categories
        .where((category) {
          final name = '${category.nameAr} ${category.nameEn}'.toLowerCase();
          return terms.any((term) => name.contains(term));
        })
        .map((category) => category.id)
        .toSet();
    final matches = categoryIds.isNotEmpty
        ? store.products.where(
            (product) => categoryIds.contains(product.categoryId),
          )
        : store.products.where((product) {
            final legacyText =
                '${product.categoryNameAr ?? ''} ${product.nameAr} ${product.nameEn}'
                    .toLowerCase();
            return terms.any((term) => legacyText.contains(term));
          });
    return matches.take(10).toList();
  }

  List<StoreBanner> _bannersFor(Storefront store, List<String> positions) {
    final expected = positions.map((item) => item.toLowerCase()).toSet();
    return store.banners
        .where((item) => expected.contains(item.position.trim().toLowerCase()))
        .toList();
  }

  List<StoreCategory> _sortedCategories(Storefront store) {
    final counts = <int, int>{};
    for (final product in store.products) {
      final id = product.categoryId;
      if (id != null) counts[id] = (counts[id] ?? 0) + 1;
    }
    return [...store.categories]..sort(
      (left, right) => (counts[right.id] ?? 0).compareTo(counts[left.id] ?? 0),
    );
  }
}

class _OfflineNotice extends StatelessWidget {
  const _OfflineNotice();
  @override
  Widget build(BuildContext context) => Container(
    color: const Color(0xFF3B2540),
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
    child: const Row(
      children: [
        Icon(Icons.cloud_off_outlined, color: Color(0xFFF3D78C), size: 18),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'أنت غير متصل — نعرض آخر بيانات محفوظة على جهازك.',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({
    required this.onOpenCart,
    required this.onAccount,
    required this.onMenu,
    required this.cart,
  });
  final VoidCallback onOpenCart;
  final VoidCallback onAccount;
  final VoidCallback onMenu;
  final CartController cart;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: .97),
      boxShadow: const [BoxShadow(color: Color(0x16000000), blurRadius: 14)],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ResponsiveCenter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'بحث',
                        onPressed: () => _showStoreSearch(context),
                        icon: const Icon(Icons.search_rounded),
                      ),
                      IconButton(
                        tooltip: 'حسابي',
                        onPressed: onAccount,
                        icon: const Icon(Icons.person_outline_rounded),
                      ),
                      AnimatedBuilder(
                        animation: cart,
                        builder: (_, _) => Badge(
                          isLabelVisible: cart.count > 0,
                          label: Text('${cart.count}'),
                          child: IconButton(
                            tooltip: 'السلة',
                            onPressed: onOpenCart,
                            icon: const Icon(Icons.shopping_cart_outlined),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => context.go('/'),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: const Color(0x33F3D78C),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.asset(
                                'assets/branding/rose-logo-2026.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 7),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'روز برفيوم',
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'ROSE PERFUME',
                                  style: TextStyle(
                                    fontSize: 7,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'القائمة',
                    onPressed: onMenu,
                    icon: const Icon(Icons.menu_rounded),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (MediaQuery.sizeOf(context).width >= 720) ...[
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: .10),
          ),
          ResponsiveCenter(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Wrap(
                  spacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    _DesktopNavItem(
                      label: 'الرئيسية',
                      onTap: () => context.go('/'),
                    ),
                    _DesktopNavItem(
                      label: 'المتجر',
                      onTap: () => context.go('/products'),
                    ),
                    _DesktopNavItem(
                      label: 'من نحن',
                      onTap: () => context.push('/support/about'),
                    ),
                    _DesktopNavItem(
                      label: 'الفروع',
                      onTap: () => context.push('/branches'),
                    ),
                    _DesktopNavItem(
                      label: 'تواصل معنا',
                      onTap: () => context.push('/support/contact'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

class _DesktopNavItem extends StatelessWidget {
  const _DesktopNavItem({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onTap,
    style: TextButton.styleFrom(
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
    ),
    child: Text(label),
  );
}

class _Hero extends StatefulWidget {
  const _Hero({required this.sliders});
  final List<StoreSlider> sliders;
  @override
  State<_Hero> createState() => _HeroState();
}

class _HeroState extends State<_Hero> {
  final _controller = PageController();
  int _page = 0;
  bool _paused = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoAdvance());
  }

  void _autoAdvance() async {
    while (mounted) {
      await Future<void>.delayed(const Duration(seconds: 5));
      final count = _visibleSlides.length;
      if (!mounted || _paused || count < 2 || !_controller.hasClients) {
        continue;
      }
      final next = (_page + 1) % count;
      await _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = _visibleSlides;
    if (slides.isEmpty) return const SizedBox.shrink();
    return AspectRatio(
      aspectRatio: MediaQuery.sizeOf(context).width < 700 ? 16 / 9 : 12 / 5,
      child: MouseRegion(
        onEnter: (_) => _paused = true,
        onExit: (_) => _paused = false,
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: slides.length,
              onPageChanged: (value) => setState(() => _page = value),
              itemBuilder: (_, index) {
                final slide = slides[index];
                final source = MediaQuery.sizeOf(context).width >= 768
                    ? slide.desktopImageUrl ?? slide.mobileImageUrl
                    : slide.mobileImageUrl ?? slide.desktopImageUrl;
                return InkWell(
                  onTap: slide.link?.trim().isNotEmpty == true
                      ? () => _openStoreLink(context, slide.link!)
                      : null,
                  child: AnimatedScale(
                    scale: index == _page ? 1 : 1.025,
                    duration: const Duration(milliseconds: 700),
                    child: CachedNetworkImage(
                      imageUrl: _url(source),
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Image.asset(
                        'assets/banners/hero.jpg',
                        fit: BoxFit.cover,
                      ),
                      errorWidget: (_, _, _) => Image.asset(
                        'assets/banners/hero.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
            if (slides.length > 1 &&
                MediaQuery.sizeOf(context).width >= 768) ...[
              PositionedDirectional(
                start: 18,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _HeroArrow(
                    icon: Icons.chevron_left_rounded,
                    label: 'العرض التالي',
                    onPressed: () => _goTo((_page + 1) % slides.length),
                  ),
                ),
              ),
              PositionedDirectional(
                end: 18,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _HeroArrow(
                    icon: Icons.chevron_right_rounded,
                    label: 'العرض السابق',
                    onPressed: () =>
                        _goTo((_page - 1 + slides.length) % slides.length),
                  ),
                ),
              ),
            ],
            if (slides.length > 1)
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    slides.length,
                    (index) => Semantics(
                      button: true,
                      label: 'العرض ${index + 1}',
                      child: GestureDetector(
                        onTap: () => _goTo(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.all(3),
                          height: 7,
                          width: index == _page ? 22 : 7,
                          decoration: BoxDecoration(
                            color: index == _page
                                ? Theme.of(context).colorScheme.primary
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<StoreSlider> get _visibleSlides => widget.sliders
      .where(
        (item) =>
            item.desktopImageUrl?.isNotEmpty == true ||
            item.mobileImageUrl?.isNotEmpty == true,
      )
      .toList();

  void _goTo(int page) => _controller.animateToPage(
    page,
    duration: const Duration(milliseconds: 350),
    curve: Curves.easeOutCubic,
  );
}

class _HeroArrow extends StatelessWidget {
  const _HeroArrow({
    required this.icon,
    required this.label,
    required this.onPressed,
  });
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white.withValues(alpha: .9),
    shape: const CircleBorder(),
    child: IconButton(
      tooltip: label,
      onPressed: onPressed,
      icon: Icon(icon, color: Theme.of(context).colorScheme.primary),
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.onViewAll});
  final String title;
  final Widget child;
  final VoidCallback? onViewAll;
  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);
    return SliverToBoxAdapter(
      child: ResponsiveCenter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (onViewAll != null)
                    TextButton.icon(
                      onPressed: onViewAll,
                      icon: const Icon(Icons.arrow_back_rounded, size: 17),
                      label: Text(copy.viewAll),
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _Categories extends StatefulWidget {
  const _Categories({required this.items});
  final List<StoreCategory> items;

  @override
  State<_Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<_Categories> {
  static const _cardWidth = 104.0;
  static const _gap = 12.0;
  final _controller = ScrollController();
  var _offset = 0.0;
  var _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_trackProgress);
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoScroll());
  }

  void _trackProgress() {
    if (!_controller.hasClients) return;
    final max = _controller.position.maxScrollExtent;
    final next = max <= 0 ? 0.0 : _controller.offset / max;
    if ((next - _progress).abs() > .01 && mounted) {
      setState(() => _progress = next.clamp(0.0, 1.0));
    }
  }

  Future<void> _autoScroll() async {
    while (mounted) {
      await Future<void>.delayed(const Duration(seconds: 4));
      if (!mounted || widget.items.length < 2 || !_controller.hasClients) {
        continue;
      }
      final maximum = _controller.position.maxScrollExtent;
      if (maximum <= 0) continue;
      _offset = _offset + _cardWidth + _gap;
      if (_offset > maximum) _offset = 0;
      await _controller.animateTo(
        _offset,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 122,
    child: Column(
      children: [
        Expanded(
          child: ListView.separated(
            controller: _controller,
            padding: const EdgeInsetsDirectional.only(end: 2),
            scrollDirection: Axis.horizontal,
            itemCount: widget.items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              final item = widget.items[index];
              return SizedBox(
                width: 104,
                child: InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () => context.go('/products?category=${item.id}'),
                  child: Column(
                    children: [
                      Container(
                        width: 78,
                        height: 78,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: .16),
                            width: 2,
                          ),
                        ),
                        child: item.imageUrl?.isNotEmpty == true
                            ? CachedNetworkImage(
                                imageUrl: _url(item.imageUrl),
                                fit: BoxFit.cover,
                                placeholder: (_, _) => Image.asset(
                                  _categoryFallback(index),
                                  fit: BoxFit.cover,
                                ),
                                errorWidget: (_, _, _) => Image.asset(
                                  _categoryFallback(index),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Image.asset(
                                _categoryFallback(index),
                                fit: BoxFit.cover,
                              ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        _isEnglish(context) && item.nameEn.isNotEmpty
                            ? item.nameEn
                            : item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: 42,
          height: 3,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: .14),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: AlignmentDirectional.centerStart,
          child: FractionallySizedBox(
            widthFactor: widget.items.length < 2 ? 1 : .28 + (.72 * _progress),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _ProductsSection extends StatefulWidget {
  const _ProductsSection({
    required this.title,
    required this.products,
    required this.cart,
  });
  final String title;
  final List<Product> products;
  final CartController cart;

  @override
  State<_ProductsSection> createState() => _ProductsSectionState();
}

class _ProductsSectionState extends State<_ProductsSection> {
  final _controller = ScrollController();
  Timer? _timer;
  var _offset = 0.0;
  var _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_trackProgress);
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _advance());
  }

  void _trackProgress() {
    if (!_controller.hasClients) return;
    final max = _controller.position.maxScrollExtent;
    final next = max <= 0 ? 0.0 : _controller.offset / max;
    if ((next - _progress).abs() > .01 && mounted) {
      setState(() => _progress = next.clamp(0.0, 1.0));
    }
  }

  void _advance() {
    if (!mounted || widget.products.length < 2 || !_controller.hasClients) {
      return;
    }
    final max = _controller.position.maxScrollExtent;
    if (max <= 0) return;
    _offset += 202;
    if (_offset > max) _offset = 0;
    _controller.animateTo(
      _offset,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _Section(
    title: widget.title,
    onViewAll: () => context.go('/products'),
    child: SizedBox(
      height: 316,
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              controller: _controller,
              padding: const EdgeInsetsDirectional.only(end: 2),
              scrollDirection: Axis.horizontal,
              itemCount: widget.products.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, index) => _ProductCard(
                product: widget.products[index],
                cart: widget.cart,
              ),
            ),
          ),
          const SizedBox(height: 7),
          Container(
            width: 52,
            height: 3,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: AlignmentDirectional.centerStart,
            child: FractionallySizedBox(
              widthFactor: widget.products.length < 2
                  ? 1
                  : .24 + (.76 * _progress),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _Banners extends StatelessWidget {
  const _Banners({required this.items});
  final List<StoreBanner> items;

  @override
  Widget build(BuildContext context) => ResponsiveCenter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        children: items
            .where((item) => item.imageUrl.isNotEmpty)
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    onTap: item.link.trim().isEmpty
                        ? null
                        : () => _openStoreLink(context, item.link),
                    child: CachedNetworkImage(
                      imageUrl: _url(item.imageUrl),
                      width: double.infinity,
                      fit: BoxFit.contain,
                      placeholder: (_, _) => const AspectRatio(
                        aspectRatio: 16 / 6,
                        child: _BannerPlaceholder(),
                      ),
                      errorWidget: (_, _, _) => Image.asset(
                        'assets/banners/hero.jpg',
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    ),
  );
}

class _BannerPlaceholder extends StatelessWidget {
  const _BannerPlaceholder();
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: .08),
    ),
    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
  );
}

class _Testimonials extends StatefulWidget {
  const _Testimonials({required this.items});
  final List<StoreTestimonial> items;
  @override
  State<_Testimonials> createState() => _TestimonialsState();
}

class _TestimonialsState extends State<_Testimonials> {
  final _controller = ScrollController();
  Timer? _timer;
  var _offset = 0.0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_controller.hasClients || widget.items.length < 2) return;
      final max = _controller.position.maxScrollExtent;
      if (max <= 0) return;
      _offset += 302;
      if (_offset > max) _offset = 0;
      _controller.animateTo(
        _offset,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ResponsiveCenter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppCopy.of(context).customerStories,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 206,
            child: ListView.separated(
              controller: _controller,
              scrollDirection: Axis.horizontal,
              itemCount: widget.items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, index) {
                final item = widget.items[index];
                return SizedBox(
                  width: 290,
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: .12),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 23,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: .12),
                                child: Text(
                                  item.name.trim().isEmpty
                                      ? '?'
                                      : item.name.trim().substring(0, 1),
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    if (item.job.isNotEmpty)
                                      Text(
                                        item.job,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelSmall,
                                      ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.format_quote_rounded,
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: .24),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Text(
                              item.review,
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(height: 1.6),
                            ),
                          ),
                          const Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 15,
                                color: Color(0xFFF3D78C),
                              ),
                              Icon(
                                Icons.star_rounded,
                                size: 15,
                                color: Color(0xFFF3D78C),
                              ),
                              Icon(
                                Icons.star_rounded,
                                size: 15,
                                color: Color(0xFFF3D78C),
                              ),
                              Icon(
                                Icons.star_rounded,
                                size: 15,
                                color: Color(0xFFF3D78C),
                              ),
                              Icon(
                                Icons.star_rounded,
                                size: 15,
                                color: Color(0xFFF3D78C),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.cart});
  final Product product;
  final CartController cart;
  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context).width;
    final width = viewport < 520 ? (viewport - 52) / 2 : 196.0;
    final discounted =
        product.isDiscounted &&
        product.discountPrice != null &&
        product.discountPrice! < product.price;
    final lowStock =
        product.stockQuantity != null &&
        product.stockQuantity! > 0 &&
        product.stockQuantity! < 10;
    final scheme = Theme.of(context).colorScheme;
    final copy = AppCopy.of(context);
    final english = copy.isEnglish;
    final productName = english && product.nameEn.isNotEmpty
        ? product.nameEn
        : product.name;
    return SizedBox(
      width: width,
      child: Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.primary.withValues(alpha: .12)),
        ),
        child: InkWell(
          onTap: () => context.push('/products/${product.id}'),
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const RadialGradient(
                            center: Alignment(0, -.35),
                            colors: [Color(0xFFFFFFFF), Color(0xFFF4EDE7)],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: product.imageUrl?.isNotEmpty == true
                              ? CachedNetworkImage(
                                  imageUrl: _url(product.imageUrl),
                                  fit: BoxFit.contain,
                                  placeholder: (_, _) => Image.asset(
                                    'assets/categories/perfumes.jpeg',
                                    fit: BoxFit.cover,
                                  ),
                                  errorWidget: (_, _, _) => Image.asset(
                                    'assets/categories/perfumes.jpeg',
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(Icons.image_outlined),
                        ),
                      ),
                      PositionedDirectional(
                        top: 7,
                        start: 7,
                        end: 7,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (discounted)
                              _ProductPill(
                                label: copy.sale,
                                color: Color(0xFFB3261E),
                              )
                            else
                              const SizedBox.shrink(),
                            if (product.offer?.trim().isNotEmpty == true)
                              Flexible(
                                child: _ProductPill(
                                  label: product.offer!.trim(),
                                  color: scheme.primary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (lowStock)
                        PositionedDirectional(
                          bottom: 7,
                          start: 7,
                          child: _ProductPill(
                            label: copy.lowStock(product.stockQuantity!),
                            color: Colors.white,
                            foreground: scheme.primary,
                          ),
                        ),
                      if (!product.isInStock)
                        DecoratedBox(
                          decoration: const BoxDecoration(
                            color: Color(0x88000000),
                          ),
                          child: Center(
                            child: _ProductPill(
                              label: copy.outOfStock,
                              color: Color(0xE0202020),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 9),
                SizedBox(
                  height: 32,
                  child: Text(
                    productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      '${product.salePrice.toStringAsFixed(2)} ر.س',
                      style: TextStyle(
                        color: scheme.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (discounted) ...[
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          product.price.toStringAsFixed(2),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: scheme.onSurface.withValues(alpha: .48),
                            decoration: TextDecoration.lineThrough,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(38),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          textStyle: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: product.isInStock
                            ? () => cart.add(product)
                            : null,
                        icon: const Icon(
                          Icons.shopping_cart_outlined,
                          size: 16,
                        ),
                        label: Text(copy.add),
                      ),
                    ),
                    const SizedBox(width: 7),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(38, 38),
                        padding: EdgeInsets.zero,
                        side: BorderSide(
                          color: scheme.primary.withValues(alpha: .25),
                        ),
                      ),
                      onPressed: () => context.push('/products/${product.id}'),
                      child: const Icon(Icons.visibility_outlined, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductPill extends StatelessWidget {
  const _ProductPill({
    required this.label,
    required this.color,
    this.foreground = Colors.white,
  });
  final String label;
  final Color color;
  final Color foreground;
  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxWidth: 100),
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: foreground,
        fontSize: 9,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _Footer extends StatelessWidget {
  const _Footer();
  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);
    return Column(
      children: [
        const _PaymentMethodsStrip(),
        Container(
          margin: const EdgeInsets.only(top: 0),
          color: const Color(0xFF311328),
          child: Column(
            children: [
              ResponsiveCenter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 36, 24, 30),
                  child: Wrap(
                    spacing: 28,
                    runSpacing: 30,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 265, child: _FooterBrand()),
                      SizedBox(
                        width: 168,
                        child: _FooterColumn(
                          title: copy.quickLinks,
                          children: [
                            _FooterLink(label: copy.aboutUs, section: 'about'),
                            _FooterLink(
                              label: copy.contactUs,
                              section: 'contact',
                            ),
                            _FooterLink(
                              label: copy.branches,
                              section: 'branches',
                            ),
                            _FooterLink(
                              label: copy.privacy,
                              section: 'privacy',
                            ),
                            _FooterLink(label: copy.terms, section: 'terms'),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 220,
                        child: _FooterColumn(
                          title: copy.contactUs,
                          children: [
                            _FooterContact(
                              icon: Icons.mail_outline,
                              label: 'info@roseperfume.com.sa',
                              target: 'mailto:info@roseperfume.com.sa',
                            ),
                            _FooterContact(
                              icon: Icons.chat_bubble_outline,
                              label: '0541990905',
                              target: 'https://wa.me/966541990905',
                            ),
                            _FooterContact(
                              icon: Icons.location_on_outlined,
                              label: copy.country,
                              onTap: () => context.push('/branches'),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 235, child: _LegalStoreInfo(copy: copy)),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                color: const Color(0xFF624837),
                child: ResponsiveCenter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 13,
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: 8,
                      children: [
                        const Text(
                          '© 2026 روز برفيوم — جميع الحقوق محفوظة',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Wrap(
                          spacing: 3,
                          children: [
                            _SocialButton(
                              icon: Icons.chat_bubble_outline,
                              target: 'https://wa.me/966541990905',
                            ),
                            _SocialButton(
                              icon: Icons.emoji_emotions_outlined,
                              target: 'https://snapchat.com/t/5EpgFUH3',
                            ),
                            _SocialButton(
                              icon: Icons.alternate_email,
                              target: 'https://x.com/roseperfume_ksa',
                            ),
                            _SocialButton(
                              icon: Icons.camera_alt_outlined,
                              target: 'https://www.instagram.com/roseperfumerr',
                            ),
                            _SocialButton(
                              icon: Icons.music_note_outlined,
                              target: 'https://www.tiktok.com/@roseperfumer1',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const _VerifiedBusinessCard(),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodsStrip extends StatefulWidget {
  const _PaymentMethodsStrip();
  @override
  State<_PaymentMethodsStrip> createState() => _PaymentMethodsStripState();
}

class _PaymentMethodsStripState extends State<_PaymentMethodsStrip> {
  final _controller = ScrollController();
  var _offset = 0.0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _move());
  }

  Future<void> _move() async {
    while (mounted) {
      await Future<void>.delayed(const Duration(seconds: 3));
      if (!mounted || !_controller.hasClients) continue;
      final max = _controller.position.maxScrollExtent;
      if (max <= 0) continue;
      _offset = _offset + 100;
      if (_offset > max) _offset = 0;
      await _controller.animateTo(
        _offset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
    color: const Color(0xFFF3F1F2),
    height: 58,
    child: ListView(
      controller: _controller,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
      scrollDirection: Axis.horizontal,
      children: const [
        _PaymentLogo(asset: 'assets/branding/payments/visa.png', label: 'Visa'),
        _PaymentLogo(asset: 'assets/branding/payments/mada.svg', label: 'MADA'),
        _PaymentLogo(
          asset: 'assets/branding/payments/apple_pay.svg',
          label: 'Apple Pay',
        ),
        _PaymentLogo(
          asset: 'assets/branding/payments/tabby.png',
          label: 'Tabby',
        ),
        _PaymentLogo(
          asset: 'assets/branding/payments/tamara.png',
          label: 'Tamara',
        ),
        _PaymentLogo(
          asset: 'assets/branding/payments/stc_pay.png',
          label: 'stc pay',
        ),
        _PaymentLogo(
          asset: 'assets/branding/payments/google_pay.png',
          label: 'Google Pay',
        ),
      ],
    ),
  );
}

class _PaymentLogo extends StatelessWidget {
  const _PaymentLogo({this.asset, required this.label});
  final String? asset;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    width: 92,
    margin: const EdgeInsetsDirectional.only(end: 12),
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
    ),
    child: asset == null
        ? Center(
            child: Text(
              label,
              textDirection: TextDirection.ltr,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
            ),
          )
        : asset!.endsWith('.svg')
        ? SvgPicture.asset(
            asset!,
            fit: BoxFit.contain,
            placeholderBuilder: (_) => Center(child: Text(label)),
          )
        : Image.asset(
            asset!,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => Center(child: Text(label)),
          ),
  );
}

class _LegalStoreInfo extends StatelessWidget {
  const _LegalStoreInfo({required this.copy});
  final AppCopy copy;
  @override
  Widget build(BuildContext context) => _FooterColumn(
    title: copy.storeInfo,
    children: [
      DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0x14FFFFFF),
          borderRadius: BorderRadius.all(Radius.circular(12)),
          border: Border.fromBorderSide(BorderSide(color: Color(0x26FFFFFF))),
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: SvgPicture.asset(
                  'assets/branding/vat-certificate.svg',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'رقم شهادة الضريبة',
                      style: TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                    const Text(
                      '4031079377',
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'الرقم الضريبي',
                      style: TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                    const Text(
                      '311343549900003',
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _VerifiedBusinessCard extends StatelessWidget {
  const _VerifiedBusinessCard();
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 15),
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: Color(0x1FFFFFFF))),
    ),
    child: Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => launchUrl(Uri.parse('https://business.sa')),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0x14FFFFFF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x26FFFFFF)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 42,
                height: 42,
                child: Image(
                  image: AssetImage('assets/branding/verified-business.png'),
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'متجر موثوق',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'موثوق لدى منصة الأعمال',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
              SizedBox(width: 8),
              Icon(Icons.open_in_new, color: Colors.white70, size: 17),
            ],
          ),
        ),
      ),
    ),
  );
}

class _FooterBrand extends StatelessWidget {
  const _FooterBrand();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/branding/header_logo.png',
              width: 92,
              height: 48,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'روز برفيوم',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      const Text(
        'عطور أصلية، توصيل موثوق، وتجربة تسوّق راقية صُممت بعناية.',
        style: TextStyle(color: Colors.white70, height: 1.65),
      ),
      const SizedBox(height: 10),
      const Row(
        children: [
          Icon(Icons.verified_outlined, color: Color(0xFFF3D78C), size: 18),
          SizedBox(width: 6),
          Text(
            'تسوّق بثقة وأمان',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    ],
  );
}

class _FooterColumn extends StatelessWidget {
  const _FooterColumn({required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: Color(0xFFF3D78C),
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 8),
      ...children,
    ],
  );
}

class _FooterContact extends StatelessWidget {
  const _FooterContact({
    required this.icon,
    required this.label,
    this.target,
    this.onTap,
  });
  final IconData icon;
  final String label;
  final String? target;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => TextButton.icon(
    onPressed:
        onTap ?? (target == null ? null : () => launchUrl(Uri.parse(target!))),
    style: TextButton.styleFrom(
      foregroundColor: Colors.white70,
      padding: EdgeInsets.zero,
      alignment: AlignmentDirectional.centerStart,
    ),
    icon: Icon(icon, size: 17),
    label: Text(label),
  );
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.icon, required this.target});
  final IconData icon;
  final String target;
  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: () =>
        launchUrl(Uri.parse(target), mode: LaunchMode.externalApplication),
    tooltip: 'فتح الرابط',
    color: Colors.white,
    icon: Icon(icon),
  );
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label, required this.section});
  final String label;
  final String section;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () =>
        context.push(section == 'branches' ? '/branches' : '/support/$section'),
    style: TextButton.styleFrom(foregroundColor: Colors.white),
    child: Text(label),
  );
}

Future<void> _showStoreSearch(BuildContext context) async {
  final controller = TextEditingController();
  final copy = AppCopy.of(context);
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        6,
        20,
        20 + MediaQuery.viewInsetsOf(sheetContext).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            copy.searchStore,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onSubmitted: (value) {
              Navigator.pop(sheetContext);
              context.go('/products?q=${Uri.encodeComponent(value.trim())}');
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded),
              hintText: copy.searchHint,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(sheetContext);
              context.go(
                '/products?q=${Uri.encodeComponent(controller.text.trim())}',
              );
            },
            icon: const Icon(Icons.search_rounded),
            label: Text(copy.search),
          ),
        ],
      ),
    ),
  );
  controller.dispose();
}

bool _isEnglish(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'en';

String _text(bool english, String arabic, String englishText) =>
    english ? englishText : arabic;

String _url(String? path) {
  final value = path?.trim().replaceAll('\\', '/') ?? '';
  if (value.startsWith('http')) return value;
  return '${AppConfig.apiBaseUrl}${value.startsWith('/') ? value : '/$value'}';
}

Future<void> _openStoreLink(BuildContext context, String link) async {
  final value = link.trim();
  if (value.isEmpty) return;
  final uri = Uri.tryParse(value);
  if (uri != null && uri.hasScheme && uri.scheme != 'roseperfume') {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    return;
  }
  if (context.mounted) {
    context.go(value.startsWith('/') ? value : '/$value');
  }
}

String _categoryFallback(int index) => switch (index % 4) {
  0 => 'assets/categories/perfumes.jpeg',
  1 => 'assets/categories/oud.jpeg',
  2 => 'assets/categories/incense.jpeg',
  _ => 'assets/categories/gifts.jpeg',
};

class _QuickContactButtons extends StatelessWidget {
  const _QuickContactButtons();
  static const _phone = '+966541990905';
  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.ltr,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'call-us',
          tooltip: 'اتصل بنا',
          backgroundColor: const Color(0xFF311328),
          foregroundColor: Colors.white,
          onPressed: () => launchUrl(Uri.parse('tel:$_phone')),
          child: const Icon(Icons.phone_outlined),
        ),
        const SizedBox(width: 12),
        FloatingActionButton(
          heroTag: 'whatsapp-us',
          tooltip: 'واتساب',
          backgroundColor: const Color(0xFF25D366),
          foregroundColor: Colors.white,
          onPressed: () => launchUrl(
            Uri.parse(
              'https://wa.me/966541990905?text=${Uri.encodeComponent('مرحباً، أحتاج مساعدة من روز برفيوم')}',
            ),
            mode: LaunchMode.externalApplication,
          ),
          child: const Icon(Icons.chat_bubble_outline),
        ),
      ],
    ),
  );
}

class _StoreDrawer extends StatelessWidget {
  const _StoreDrawer();
  @override
  Widget build(BuildContext context) => Drawer(
    child: SafeArea(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF311328), Color(0xFF7B3B5E)],
              ),
            ),
            child: Row(
              children: [
                Image.asset('assets/branding/logo.png', width: 58),
                const SizedBox(width: 12),
                const Text(
                  'روز برفيوم\nROSE PERFUME',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1.8,
                  ),
                ),
              ],
            ),
          ),
          _drawerItem(context, Icons.home_outlined, 'الرئيسية', '/'),
          _drawerItem(
            context,
            Icons.storefront_outlined,
            'المتجر',
            '/products',
          ),
          _drawerItem(
            context,
            Icons.location_on_outlined,
            'فروعنا',
            '/branches',
          ),
          _drawerItem(
            context,
            Icons.auto_awesome_outlined,
            'من نحن',
            '/support/about',
          ),
          _drawerItem(context, Icons.person_outline, 'حسابي', '/account'),
          const Divider(),
          _drawerItem(
            context,
            Icons.support_agent_outlined,
            'تواصل معنا',
            '/support/contact',
          ),
          _drawerItem(
            context,
            Icons.assignment_return_outlined,
            'سياسة الاسترجاع',
            '/support/returns',
          ),
          _drawerItem(
            context,
            Icons.gavel_outlined,
            'الشروط والأحكام',
            '/support/terms',
          ),
          _drawerItem(
            context,
            Icons.privacy_tip_outlined,
            'سياسة الخصوصية',
            '/support/privacy',
          ),
        ],
      ),
    ),
  );
  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String label,
    String route,
  ) => ListTile(
    leading: Icon(icon),
    title: Text(label),
    trailing: const Icon(Icons.chevron_left),
    onTap: () {
      Navigator.pop(context);
      context.go(route);
    },
  );
}

class _HomeSkeleton extends StatefulWidget {
  const _HomeSkeleton();
  @override
  State<_HomeSkeleton> createState() => _HomeSkeletonState();
}

class _HomeSkeletonState extends State<_HomeSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (_, _) {
      final shade = Color.lerp(
        const Color(0xFFE7DDE3),
        const Color(0xFFF7F3F5),
        controller.value,
      )!;
      Widget block(double width, double height, {double radius = 16}) =>
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: shade,
              borderRadius: BorderRadius.circular(radius),
            ),
          );
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          block(double.infinity, 58, radius: 0),
          const SizedBox(height: 18),
          block(double.infinity, 210),
          const SizedBox(height: 28),
          block(150, 24),
          const SizedBox(height: 15),
          SizedBox(
            height: 104,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (_, _) => Column(
                children: [
                  block(70, 70, radius: 40),
                  const SizedBox(height: 9),
                  block(64, 12, radius: 6),
                ],
              ),
            ),
          ),
          const SizedBox(height: 27),
          block(160, 24),
          const SizedBox(height: 14),
          SizedBox(
            height: 235,
            child: Row(
              children: List.generate(
                2,
                (_) => Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 12),
                    child: block(double.infinity, 235),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
