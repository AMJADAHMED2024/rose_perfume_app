import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/security/secure_session_store.dart';
import '../../../core/security/session_identity.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../application/admin_dashboard_controller.dart';
import '../data/admin_analytics_repository.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  late final Future<bool> _isAdmin;

  @override
  void initState() {
    super.initState();
    _isAdmin = SessionIdentity.isAdmin(ref.read(sessionStoreProvider));
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
    future: _isAdmin,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Scaffold(
          body: SkeletonPage(layout: SkeletonLayout.dashboard),
        );
      }
      if (snapshot.data != true) return const _NotAuthorizedPage();
      return const _AdminDashboardView();
    },
  );
}

class _NotAuthorizedPage extends StatelessWidget {
  const _NotAuthorizedPage();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('لوحة التحكم')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.admin_panel_settings_outlined,
                    size: 52,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'هذه الصفحة مخصّصة للإدارة',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'يجب تسجيل الدخول بحساب يملك صلاحية المدير للوصول إلى المؤشرات التشغيلية.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () => context.go('/account'),
                    child: const Text('العودة إلى الحساب'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _AdminDashboardView extends ConsumerWidget {
  const _AdminDashboardView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminDashboardControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        actions: [
          PopupMenuButton<_AdminDestination>(
            tooltip: 'أقسام الإدارة',
            icon: const Icon(Icons.grid_view_rounded),
            onSelected: (destination) => context.go(destination.route),
            itemBuilder: (_) => _adminDestinations
                .map(
                  (destination) => PopupMenuItem(
                    value: destination,
                    child: Row(
                      children: [
                        Icon(destination.icon, size: 20),
                        const SizedBox(width: 10),
                        Text(destination.label),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          IconButton(
            tooltip: 'تحديث البيانات',
            onPressed: state.isLoading
                ? null
                : ref.read(adminDashboardControllerProvider.notifier).load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: state.isLoading && state.dashboard == null
          ? const SkeletonPage(layout: SkeletonLayout.dashboard)
          : RefreshIndicator(
              onRefresh: ref
                  .read(adminDashboardControllerProvider.notifier)
                  .load,
              child: _DashboardBody(state: state),
            ),
    );
  }
}

class _AdminDestination {
  const _AdminDestination(this.label, this.route, this.icon);
  final String label;
  final String route;
  final IconData icon;
}

const _adminDestinations = [
  _AdminDestination(
    'التقارير التفصيلية',
    '/admin/reports',
    Icons.query_stats_outlined,
  ),
  _AdminDestination('الطلبات', '/admin/orders', Icons.receipt_long_outlined),
  _AdminDestination('المنتجات', '/admin/products', Icons.inventory_2_outlined),
  _AdminDestination('التصنيفات', '/admin/categories', Icons.category_outlined),
  _AdminDestination(
    'متغيرات المنتجات',
    '/admin/product-variants',
    Icons.tune_outlined,
  ),
  _AdminDestination(
    'المخزون',
    '/admin/inventory-transactions',
    Icons.history_outlined,
  ),
  _AdminDestination(
    'الكوبونات',
    '/admin/coupons',
    Icons.confirmation_number_outlined,
  ),
  _AdminDestination('العملاء', '/admin/customers', Icons.people_outline),
  _AdminDestination(
    'الإشعارات',
    '/admin/notifications',
    Icons.notifications_outlined,
  ),
  _AdminDestination('المحتوى', '/admin/content', Icons.article_outlined),
  _AdminDestination(
    'واجهة المتجر',
    '/admin/storefront',
    Icons.storefront_outlined,
  ),
  _AdminDestination('الإعدادات', '/admin/settings', Icons.settings_outlined),
];

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({required this.state});
  final AdminDashboardState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = state.dashboard;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(18),
      children: [
        _Hero(rangeDays: state.rangeDays),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [7, 30, 90]
              .map(
                (days) => ChoiceChip(
                  label: Text('آخر $days يوم'),
                  selected: state.rangeDays == days,
                  onSelected: (_) => ref
                      .read(adminDashboardControllerProvider.notifier)
                      .selectRange(days),
                ),
              )
              .toList(),
        ),
        if (state.errorMessage case final message?) ...[
          const SizedBox(height: 14),
          _MessageCard(message: message),
        ],
        if (dashboard == null) ...[
          const SizedBox(height: 22),
          _EmptyState(
            onRetry: ref.read(adminDashboardControllerProvider.notifier).load,
          ),
        ] else ...[
          const SizedBox(height: 18),
          _SalesMetrics(dashboard: dashboard),
          const SizedBox(height: 24),
          _SectionTitle(
            title: 'تشغيل المتجر',
            subtitle: 'حالة الطلبات والمخزون التي تحتاج متابعة',
          ),
          const SizedBox(height: 10),
          _OperationsGrid(operations: dashboard.operations),
          const SizedBox(height: 24),
          _SectionTitle(
            title: 'أكثر المنتجات أداءً',
            subtitle: 'مرتبّة بالإيراد خلال الفترة المختارة',
          ),
          const SizedBox(height: 10),
          _TopProducts(products: dashboard.topProducts),
          const SizedBox(height: 24),
          _SectionTitle(
            title: 'تنبيهات المخزون',
            subtitle: 'لا تحفظ هذه البيانات إداريًا على الجهاز',
          ),
          const SizedBox(height: 10),
          _StockAlerts(alerts: dashboard.stockAlerts),
        ],
        const SizedBox(height: 26),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.rangeDays});
  final int rangeDays;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: const LinearGradient(
        colors: [Color(0xFF311328), Color(0xFF7B3B5E)],
        begin: AlignmentDirectional.topStart,
        end: AlignmentDirectional.bottomEnd,
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'نظرة تشغيلية واضحة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'مؤشرات حية لآخر $rangeDays يومًا من خادم الإدارة.',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        const CircleAvatar(
          radius: 28,
          backgroundColor: Colors.white24,
          child: Icon(Icons.insights_outlined, color: Colors.white, size: 30),
        ),
      ],
    ),
  );
}

class _SalesMetrics extends StatelessWidget {
  const _SalesMetrics({required this.dashboard});
  final AdminDashboard dashboard;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 940
          ? 4
          : constraints.maxWidth >= 560
          ? 2
          : 1;
      final cards = [
        _MetricCard(
          label: 'الإيراد المؤكد',
          value: '${_money(dashboard.revenue.current)} ر.س',
          metric: dashboard.revenue,
          icon: Icons.account_balance_wallet_outlined,
        ),
        _MetricCard(
          label: 'الطلبات المؤكدة',
          value: _whole(dashboard.orders.current),
          metric: dashboard.orders,
          icon: Icons.receipt_long_outlined,
        ),
        _MetricCard(
          label: 'متوسط قيمة الطلب',
          value: '${_money(dashboard.averageOrderValue.current)} ر.س',
          metric: dashboard.averageOrderValue,
          icon: Icons.equalizer_outlined,
        ),
        _MetricCard(
          label: 'القطع المباعة',
          value: _whole(dashboard.itemsSold.current),
          metric: dashboard.itemsSold,
          icon: Icons.shopping_bag_outlined,
        ),
      ];
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: columns,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: columns == 1
            ? 3.2
            : columns == 2
            ? 1.9
            : 1.35,
        children: cards,
      );
    },
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.metric,
    required this.icon,
  });
  final String label;
  final String value;
  final AdminMetric metric;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final change = metric.changePercentage;
    final positive = (change ?? 0) >= 0;
    final color = positive
        ? const Color(0xFF1B7F5B)
        : Theme.of(context).colorScheme.error;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 3),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 6),
            if (change == null)
              const Text('لا توجد مقارنة سابقة', style: TextStyle(fontSize: 12))
            else
              Row(
                children: [
                  Icon(
                    positive ? Icons.trending_up : Icons.trending_down,
                    size: 16,
                    color: color,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${change.abs().toStringAsFixed(1)}% مقارنة بالفترة السابقة',
                    style: TextStyle(fontSize: 12, color: color),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _OperationsGrid extends StatelessWidget {
  const _OperationsGrid({required this.operations});
  final AdminOperations operations;

  @override
  Widget build(BuildContext context) {
    final entries = [
      ('طلبات جديدة', operations.newOrders, Icons.mark_email_unread_outlined),
      ('بانتظار الدفع', operations.awaitingPayment, Icons.payment_outlined),
      ('فشل الدفع', operations.paymentFailures, Icons.error_outline),
      ('قيد التحضير', operations.inPreparation, Icons.inventory_2_outlined),
      ('في الطريق', operations.inTransit, Icons.local_shipping_outlined),
      ('مخزون منخفض', operations.lowStock, Icons.warning_amber_outlined),
      (
        'نفد المخزون',
        operations.outOfStock,
        Icons.remove_shopping_cart_outlined,
      ),
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: entries
          .map(
            (entry) => SizedBox(
              width: 180,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Icon(
                        entry.$3,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${entry.$2}',
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              entry.$1,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _TopProducts extends StatelessWidget {
  const _TopProducts({required this.products});
  final List<AdminTopProduct> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const _NoDataCard(text: 'لا توجد مبيعات مؤكدة خلال هذه الفترة.');
    }
    return Card(
      child: Column(
        children: products
            .map(
              (product) => ListTile(
                leading: CircleAvatar(child: Text('${product.id}')),
                title: Text(product.name),
                subtitle: Text(
                  '${product.categoryName.isEmpty ? 'بدون تصنيف' : product.categoryName} · ${product.unitsSold} قطعة · مخزون ${product.currentStock}',
                ),
                trailing: Text(
                  '${_money(product.revenue)} ر.س',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _StockAlerts extends StatelessWidget {
  const _StockAlerts({required this.alerts});
  final List<AdminStockAlert> alerts;

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const _NoDataCard(text: 'لا توجد تنبيهات مخزون في الوقت الحالي.');
    }
    return Card(
      child: Column(
        children: alerts
            .map(
              (alert) => ListTile(
                leading: Icon(
                  Icons.warning_amber_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(alert.name),
                subtitle: Text(
                  '${alert.label} · المتاح ${alert.currentStock} من حد أدنى ${alert.minimumStock}',
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 3),
      Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.errorContainer,
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
      ),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRetry});
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined, size: 48),
          const SizedBox(height: 12),
          const Text('لم نتمكن من تحميل بيانات الإدارة.'),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
        ],
      ),
    ),
  );
}

class _NoDataCard extends StatelessWidget {
  const _NoDataCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Text(text, textAlign: TextAlign.center),
    ),
  );
}

String _money(double value) =>
    value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);

String _whole(double value) => value.toStringAsFixed(0);
