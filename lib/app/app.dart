import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_breakpoints.dart';
import '../core/database/app_database.dart';
import '../core/payment/payment_return_link.dart';
import '../core/preferences/theme_mode_controller.dart';
import '../core/preferences/locale_controller.dart';
import '../core/state/cart_controller.dart';
import '../core/sync/sync_coordinator.dart';
import '../features/auth/application/auth_controller.dart';
import '../features/admin/presentation/admin_dashboard_page.dart';
import '../features/admin/presentation/admin_access_gate.dart';
import '../features/admin/presentation/admin_reports_page.dart';
import '../features/admin/presentation/admin_coupons_page.dart';
import '../features/admin/presentation/admin_categories_page.dart';
import '../features/admin/presentation/admin_content_page.dart';
import '../features/admin/presentation/admin_inventory_page.dart';
import '../features/admin/presentation/admin_variants_page.dart';
import '../features/admin/presentation/admin_customers_page.dart';
import '../features/admin/presentation/admin_customer_detail_page.dart';
import '../features/admin/presentation/admin_product_images_page.dart';
import '../features/admin/presentation/admin_notifications_page.dart';
import '../features/admin/presentation/admin_orders_page.dart';
import '../features/admin/presentation/admin_products_page.dart';
import '../features/admin/presentation/admin_storefront_page.dart';
import '../features/admin/presentation/admin_settings_page.dart';
import '../features/cart/presentation/cart_page.dart';
import '../features/auth/presentation/account_page.dart';
import '../features/addresses/presentation/addresses_page.dart';
import '../features/checkout/presentation/checkout_page.dart';
import '../features/payment/presentation/payment_status_page.dart';
import '../features/profile/presentation/profile_page.dart';
import '../features/support/presentation/support_page.dart';
import '../features/branches/presentation/branches_page.dart';
import '../features/catalog/presentation/catalog_page.dart';
import '../features/catalog/presentation/product_detail_page.dart';
import '../features/dashboard/presentation/customer_dashboard_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/orders/presentation/orders_page.dart';
import '../features/notifications/presentation/notifications_page.dart';
import 'theme/app_theme.dart';

class RosePerfumeApp extends ConsumerStatefulWidget {
  const RosePerfumeApp({super.key});
  @override
  ConsumerState<RosePerfumeApp> createState() => _RosePerfumeAppState();
}

class _RosePerfumeAppState extends ConsumerState<RosePerfumeApp>
    with WidgetsBindingObserver {
  late final CartController _cart;
  late final GoRouter _router;
  late final StreamSubscription<List<ConnectivityResult>> _connectivity;
  late final StreamSubscription<Uri> _paymentReturnLinks;
  final AppLinks _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(ref.read(syncCoordinatorProvider).syncNow());
    _connectivity = Connectivity().onConnectivityChanged.listen((results) {
      if (results.any((result) => result != ConnectivityResult.none)) {
        unawaited(ref.read(syncCoordinatorProvider).syncNow());
      }
    });
    _cart = CartController(ref.read(appDatabaseProvider));
    _router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) =>
              StoreShell(cart: _cart, index: 0, onLogout: _logout),
        ),
        GoRoute(
          path: '/cart',
          builder: (_, _) =>
              StoreShell(cart: _cart, index: 1, onLogout: _logout),
        ),
        GoRoute(
          path: '/account',
          builder: (_, _) =>
              StoreShell(cart: _cart, index: 2, onLogout: _logout),
        ),
        GoRoute(
          path: '/products',
          builder: (_, state) => CatalogPage(
            cart: _cart,
            initialCategoryId: int.tryParse(
              state.uri.queryParameters['category'] ?? '',
            ),
            initialQuery: state.uri.queryParameters['q'] ?? '',
          ),
        ),
        GoRoute(
          path: '/products/:id',
          builder: (_, state) => ProductDetailPage(
            productId: state.pathParameters['id']!,
            cart: _cart,
          ),
        ),
        GoRoute(
          path: '/checkout',
          builder: (context, _) =>
              CheckoutPage(cart: _cart, onBack: () => context.go('/cart')),
        ),
        GoRoute(
          path: '/payment-status',
          builder: (_, _) => const PaymentStatusPage(),
        ),
        GoRoute(
          path: '/payment-status/:invoiceId',
          builder: (_, state) =>
              PaymentStatusPage(invoiceId: state.pathParameters['invoiceId']),
        ),
        GoRoute(path: '/orders', builder: (_, _) => const OrdersPage()),
        GoRoute(
          path: '/dashboard',
          builder: (_, _) => const CustomerDashboardPage(),
        ),
        GoRoute(
          path: '/admin',
          builder: (_, _) => const AdminAccessGate(child: AdminDashboardPage()),
        ),
        GoRoute(
          path: '/admin/reports',
          builder: (_, _) => const AdminAccessGate(child: AdminReportsPage()),
        ),
        GoRoute(
          path: '/admin/orders',
          builder: (_, _) => const AdminAccessGate(child: AdminOrdersPage()),
        ),
        GoRoute(
          path: '/admin/products',
          builder: (_, _) => const AdminAccessGate(child: AdminProductsPage()),
        ),
        GoRoute(
          path: '/admin/coupons',
          builder: (_, _) => const AdminAccessGate(child: AdminCouponsPage()),
        ),
        GoRoute(
          path: '/admin/categories',
          builder: (_, _) =>
              const AdminAccessGate(child: AdminCategoriesPage()),
        ),
        GoRoute(
          path: '/admin/inventory-transactions',
          builder: (_, _) => const AdminAccessGate(child: AdminInventoryPage()),
        ),
        GoRoute(
          path: '/admin/product-variants',
          builder: (_, _) => const AdminAccessGate(child: AdminVariantsPage()),
        ),
        GoRoute(
          path: '/admin/customers',
          builder: (_, _) => const AdminAccessGate(child: AdminCustomersPage()),
        ),
        GoRoute(
          path: '/admin/customers/:id',
          builder: (_, state) => AdminAccessGate(
            child: AdminCustomerDetailPage(
              customerId: int.parse(state.pathParameters['id']!),
            ),
          ),
        ),
        GoRoute(
          path: '/admin/products/:id/images',
          builder: (_, state) => AdminAccessGate(
            child: AdminProductImagesPage(
              productId: int.parse(state.pathParameters['id']!),
            ),
          ),
        ),
        GoRoute(
          path: '/admin/notifications',
          builder: (_, _) =>
              const AdminAccessGate(child: AdminNotificationsPage()),
        ),
        GoRoute(
          path: '/admin/content',
          builder: (_, _) => const AdminAccessGate(child: AdminContentPage()),
        ),
        GoRoute(
          path: '/admin/storefront',
          builder: (_, _) =>
              const AdminAccessGate(child: AdminStorefrontPage()),
        ),
        GoRoute(
          path: '/admin/settings',
          builder: (_, _) => const AdminAccessGate(child: AdminSettingsPage()),
        ),
        GoRoute(path: '/addresses', builder: (_, _) => const AddressesPage()),
        GoRoute(path: '/branches', builder: (_, _) => const BranchesPage()),
        GoRoute(path: '/profile', builder: (_, _) => const ProfilePage()),
        GoRoute(
          path: '/notifications',
          builder: (_, _) => const NotificationsPage(),
        ),
        GoRoute(
          path: '/support/:section',
          builder: (_, state) => SupportPage(
            section: supportSectionFromRoute(state.pathParameters['section']!),
          ),
        ),
      ],
    );
    _paymentReturnLinks = _appLinks.uriLinkStream.listen(_handlePaymentLink);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivity.cancel();
    _paymentReturnLinks.cancel();
    _cart.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await ref.read(authControllerProvider.notifier).logout();
    await _cart.clear();
  }

  void _handlePaymentLink(Uri uri) {
    final invoiceId = paymentInvoiceIdFromUri(uri);
    if (invoiceId == null) {
      return;
    }
    _router.go('/payment-status/${Uri.encodeComponent(invoiceId)}');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(ref.read(syncCoordinatorProvider).syncNow());
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'روز برفيوم',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: ref.watch(themeModeProvider),
    locale: ref.watch(localeProvider),
    supportedLocales: const [Locale('ar'), Locale('en')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    routerConfig: _router,
  );
}

class StoreShell extends StatelessWidget {
  const StoreShell({
    super.key,
    required this.cart,
    required this.index,
    required this.onLogout,
  });
  final CartController cart;
  final int index;
  final Future<void> Function() onLogout;
  void _select(BuildContext context, int value) => context.go(switch (value) {
    0 => '/',
    1 => '/cart',
    _ => '/account',
  });
  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(cart: cart, onOpenCart: () => context.go('/cart')),
      CartPage(
        cart: cart,
        onContinueShopping: () => context.go('/products'),
        onCheckout: () => context.go('/checkout'),
      ),
      AccountPage(onLogout: onLogout),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= AppBreakpoints.medium;
        return Scaffold(
          body: Column(
            children: [
              const _ShippingAnnouncement(),
              Expanded(
                child: wide
                    ? Row(
                        children: [
                          _Rail(
                            index: index,
                            cart: cart,
                            onSelected: (value) => _select(context, value),
                          ),
                          const VerticalDivider(width: 1),
                          Expanded(child: SafeArea(child: pages[index])),
                        ],
                      )
                    : SafeArea(child: pages[index]),
              ),
            ],
          ),
          bottomNavigationBar: wide
              ? null
              : _BottomBar(
                  index: index,
                  cart: cart,
                  onSelected: (value) => _select(context, value),
                ),
        );
      },
    );
  }
}

class _ShippingAnnouncement extends ConsumerWidget {
  const _ShippingAnnouncement();

  @override
  Widget build(BuildContext context, WidgetRef ref) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 380;

      return Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF321426), Color(0xFF51253E)],
            begin: AlignmentDirectional.centerStart,
            end: AlignmentDirectional.centerEnd,
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 16,
          vertical: 4,
        ),
        child: SafeArea(
          bottom: false,
          child: Center(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Color(0x1FFFFFFF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_shipping_outlined,
                    color: const Color(0xFFF3D78C),
                    size: compact ? 14 : 16,
                  ),
                ),
                SizedBox(width: compact ? 6 : 9),
                Expanded(
                  child: Text(
                    'شحن مجاني للطلبات المؤهلة داخل السعودية ودول الخليج',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    textScaler: TextScaler.noScaling,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 10 : 11.5,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'تغيير اللغة',
                  visualDensity: compact
                      ? VisualDensity.compact
                      : VisualDensity.standard,
                  constraints: BoxConstraints.tightFor(
                    width: compact ? 36 : 44,
                    height: 36,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () => ref.read(localeProvider.notifier).toggle(),
                  color: const Color(0xFFF3D78C),
                  icon: Text(
                    ref.watch(localeProvider).languageCode == 'ar' ? 'EN' : 'ع',
                    style: TextStyle(
                      fontSize: compact ? 12 : 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'تغيير المظهر',
                  visualDensity: compact
                      ? VisualDensity.compact
                      : VisualDensity.standard,
                  constraints: BoxConstraints.tightFor(
                    width: compact ? 36 : 48,
                    height: 36,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () =>
                      ref.read(themeModeProvider.notifier).toggle(),
                  color: const Color(0xFFF3D78C),
                  icon: Icon(
                    ref.watch(themeModeProvider) == ThemeMode.dark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    size: compact ? 19 : 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _Rail extends StatelessWidget {
  const _Rail({
    required this.index,
    required this.cart,
    required this.onSelected,
  });
  final int index;
  final CartController cart;
  final ValueChanged<int> onSelected;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: cart,
    builder: (_, _) => NavigationRail(
      selectedIndex: index,
      onDestinationSelected: onSelected,
      labelType: NavigationRailLabelType.all,
      destinations: [
        const NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('الرئيسية'),
        ),
        NavigationRailDestination(
          icon: Badge(
            isLabelVisible: cart.count > 0,
            label: Text('${cart.count}'),
            child: const Icon(Icons.shopping_bag_outlined),
          ),
          selectedIcon: const Icon(Icons.shopping_bag),
          label: const Text('السلة'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: Text('حسابي'),
        ),
      ],
    ),
  );
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.index,
    required this.cart,
    required this.onSelected,
  });
  final int index;
  final CartController cart;
  final ValueChanged<int> onSelected;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: cart,
    builder: (_, _) => NavigationBar(
      selectedIndex: index,
      onDestinationSelected: onSelected,
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'الرئيسية',
        ),
        NavigationDestination(
          icon: Badge(
            isLabelVisible: cart.count > 0,
            label: Text('${cart.count}'),
            child: const Icon(Icons.shopping_bag_outlined),
          ),
          selectedIcon: const Icon(Icons.shopping_bag),
          label: 'السلة',
        ),
        const NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'حسابي',
        ),
      ],
    ),
  );
}
