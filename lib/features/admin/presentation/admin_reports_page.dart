import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_skeleton.dart';
import '../application/admin_reports_controller.dart';
import '../data/admin_analytics_repository.dart';
import '../data/admin_report_exporter.dart';

class AdminReportsPage extends ConsumerWidget {
  const AdminReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminReportsControllerProvider);
    final controller = ref.read(adminReportsControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير التفصيلية'),
        actions: [
          PopupMenuButton<_ReportExportAction>(
            tooltip: 'تصدير أو طباعة',
            enabled: !state.isLoading && state.dashboard != null,
            onSelected: (action) => _export(context, state.dashboard!, action),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: _ReportExportAction.csv,
                child: ListTile(
                  leading: Icon(Icons.table_chart_outlined),
                  title: Text('تصدير CSV'),
                ),
              ),
              PopupMenuItem(
                value: _ReportExportAction.pdf,
                child: ListTile(
                  leading: Icon(Icons.picture_as_pdf_outlined),
                  title: Text('مشاركة PDF'),
                ),
              ),
              PopupMenuItem(
                value: _ReportExportAction.print,
                child: ListTile(
                  leading: Icon(Icons.print_outlined),
                  title: Text('طباعة التقرير'),
                ),
              ),
            ],
            icon: const Icon(Icons.ios_share_outlined),
          ),
          IconButton(
            tooltip: 'تحديث التقرير',
            onPressed: state.isLoading ? null : controller.load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: state.isLoading && state.dashboard == null
          ? const SkeletonPage(layout: SkeletonLayout.dashboard)
          : RefreshIndicator(
              onRefresh: controller.load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(18),
                children: [
                  _ReportHero(from: state.from, to: state.to),
                  const SizedBox(height: 14),
                  _ReportFilters(state: state),
                  if (state.errorMessage case final message?) ...[
                    const SizedBox(height: 14),
                    _MessageCard(message: message),
                  ],
                  if (state.dashboard case final dashboard?) ...[
                    const SizedBox(height: 22),
                    _ReportBody(dashboard: dashboard),
                  ] else ...[
                    const SizedBox(height: 28),
                    _EmptyReport(onRetry: controller.load),
                  ],
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Future<void> _export(
    BuildContext context,
    AdminDashboard dashboard,
    _ReportExportAction action,
  ) async {
    try {
      final exporter = const AdminReportExporter();
      switch (action) {
        case _ReportExportAction.csv:
          await exporter.shareCsv(dashboard);
        case _ReportExportAction.pdf:
          await exporter.sharePdf(dashboard);
        case _ReportExportAction.print:
          await exporter.printPdf(dashboard);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر إنشاء أو طباعة التقرير الآن.')),
        );
      }
    }
  }
}

enum _ReportExportAction { csv, pdf, print }

class _ReportHero extends StatelessWidget {
  const _ReportHero({required this.from, required this.to});
  final DateTime from;
  final DateTime to;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: const LinearGradient(
        colors: [Color(0xFF311328), Color(0xFF8B456B)],
        begin: AlignmentDirectional.topStart,
        end: AlignmentDirectional.bottomEnd,
      ),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          radius: 27,
          backgroundColor: Colors.white24,
          child: Icon(
            Icons.query_stats_outlined,
            color: Colors.white,
            size: 29,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'تقرير المتجر التشغيلي',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'البيانات من ${_date(from)} إلى ${_date(to)} — مباشرة من خادم الإدارة.',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ReportFilters extends ConsumerWidget {
  const _ReportFilters({required this.state});
  final AdminReportsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(adminReportsControllerProvider.notifier);
    final selectedDays = state.to.difference(state.from).inDays + 1;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ...[7, 30, 90].map(
              (days) => ChoiceChip(
                label: Text('آخر $days يوم'),
                selected: selectedDays == days,
                onSelected: state.isLoading
                    ? null
                    : (_) => controller.selectPreset(days),
              ),
            ),
            OutlinedButton.icon(
              onPressed: state.isLoading
                  ? null
                  : () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 365),
                        ),
                        lastDate: DateTime.now(),
                        initialDateRange: DateTimeRange(
                          start: state.from,
                          end: state.to,
                        ),
                        helpText: 'اختر فترة التقرير',
                        cancelText: 'إلغاء',
                        confirmText: 'عرض التقرير',
                      );
                      if (picked != null) {
                        await controller.selectRange(picked.start, picked.end);
                      }
                    },
              icon: const Icon(Icons.date_range_outlined),
              label: Text('${_date(state.from)} — ${_date(state.to)}'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({required this.dashboard});
  final AdminDashboard dashboard;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _SectionTitle(
        title: 'ملخص المبيعات',
        subtitle: 'مقارنة تلقائية بالفترة السابقة المماثلة.',
      ),
      const SizedBox(height: 10),
      _MetricGrid(dashboard: dashboard),
      const SizedBox(height: 26),
      const _SectionTitle(
        title: 'اتجاه المبيعات والتشغيل',
        subtitle: 'الإيراد هنا للطلبات المؤكدة؛ حالات الطلب تعرض جميع الطلبات.',
      ),
      const SizedBox(height: 10),
      _ResponsiveColumns(
        children: [
          _SalesTrendCard(points: dashboard.salesTrend),
          _OperationsCard(operations: dashboard.operations),
        ],
      ),
      const SizedBox(height: 12),
      _ResponsiveColumns(
        children: [
          _OrderStatusCard(statuses: dashboard.orderStatuses),
          _SalesLeakageCard(leakage: dashboard.salesLeakage),
        ],
      ),
      const SizedBox(height: 26),
      const _SectionTitle(
        title: 'العملاء',
        subtitle:
            'تمييز نمو العملاء واحتياج إعادة التفاعل دون كشف بيانات أكثر من اللازم.',
      ),
      const SizedBox(height: 10),
      _CustomerSummaryCard(customers: dashboard.customers),
      const SizedBox(height: 12),
      _TopCustomersCard(customers: dashboard.topCustomers),
      const SizedBox(height: 26),
      const _SectionTitle(
        title: 'الأداء التجاري',
        subtitle:
            'المنتجات والتصنيفات التي تقود الإيراد، مع عناصر تحتاج تحريكًا.',
      ),
      const SizedBox(height: 10),
      _ResponsiveColumns(
        children: [
          _TopProductsCard(products: dashboard.topProducts),
          _CategoryPerformanceCard(categories: dashboard.topCategories),
        ],
      ),
      const SizedBox(height: 12),
      _ResponsiveColumns(
        children: [
          _SlowMovingCard(products: dashboard.slowMovingProducts),
          _StockAlertsCard(alerts: dashboard.stockAlerts),
        ],
      ),
      const SizedBox(height: 26),
      const _SectionTitle(
        title: 'القنوات والمناطق',
        subtitle:
            'تقسيم الطلبات المؤكدة بحسب طريقة الدفع والمدينة وشركة الشحن.',
      ),
      const SizedBox(height: 10),
      _ResponsiveColumns(
        wideColumns: 3,
        children: [
          _BreakdownCard(
            title: 'طرق الدفع',
            icon: Icons.credit_card_outlined,
            items: dashboard.paymentMethods,
          ),
          _BreakdownCard(
            title: 'أعلى المدن',
            icon: Icons.location_on_outlined,
            items: dashboard.topCities,
          ),
          _BreakdownCard(
            title: 'شركات الشحن',
            icon: Icons.local_shipping_outlined,
            items: dashboard.shippingCompanies,
          ),
        ],
      ),
      const SizedBox(height: 26),
      const _SectionTitle(
        title: 'العروض والكوبونات',
        subtitle:
            'الإيراد المنسوب للكوبونات لا يساوي قيمة الخصم؛ كلاهما ظاهر بوضوح.',
      ),
      const SizedBox(height: 10),
      _ResponsiveColumns(
        children: [
          _CouponComparisonCard(comparison: dashboard.couponComparison),
          _CouponsCard(coupons: dashboard.coupons),
        ],
      ),
      const SizedBox(height: 12),
      _BreakdownCard(
        title: 'أداء المنتجات المخفضة',
        icon: Icons.sell_outlined,
        items: dashboard.productDiscountPerformance,
      ),
    ],
  );
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.dashboard});
  final AdminDashboard dashboard;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 920
          ? 4
          : constraints.maxWidth >= 540
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
          icon: Icons.stacked_line_chart_outlined,
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
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: columns == 1
            ? 3.25
            : columns == 2
            ? 1.85
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
    final isPositive = (change ?? 0) >= 0;
    final color = isPositive
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
                    isPositive ? Icons.trending_up : Icons.trending_down,
                    size: 16,
                    color: color,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${change.abs().toStringAsFixed(1)}% عن الفترة السابقة',
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

class _ResponsiveColumns extends StatelessWidget {
  const _ResponsiveColumns({required this.children, this.wideColumns = 2});
  final List<Widget> children;
  final int wideColumns;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 1020 ? wideColumns : 1;
      final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: children
            .map((child) => SizedBox(width: width, child: child))
            .toList(),
      );
    },
  );
}

class _SalesTrendCard extends StatelessWidget {
  const _SalesTrendCard({required this.points});
  final List<AdminSalesTrendPoint> points;

  @override
  Widget build(BuildContext context) => _ReportCard(
    title: 'اتجاه الإيراد المؤكد',
    subtitle:
        'تجميع ${points.length > 31 ? 'أسبوعي/شهري' : 'يومي'} حسب فترة التقرير.',
    child: points.isEmpty
        ? const _NoData(text: 'لا توجد مبيعات مؤكدة خلال هذه الفترة.')
        : _TrendGraph(points: points),
  );
}

class _TrendGraph extends StatelessWidget {
  const _TrendGraph({required this.points});
  final List<AdminSalesTrendPoint> points;

  @override
  Widget build(BuildContext context) {
    final total = points.fold<double>(0, (sum, point) => sum + point.revenue);
    final first = points.first;
    final last = points.last;
    return Semantics(
      label: 'إجمالي اتجاه الإيراد ${_money(total)} ريال سعودي',
      child: Column(
        children: [
          SizedBox(
            height: 172,
            width: double.infinity,
            child: CustomPaint(
              painter: _TrendPainter(
                values: points.map((point) => point.revenue).toList(),
                color: Theme.of(context).colorScheme.primary,
                gridColor: Theme.of(context).dividerColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_shortDate(first.periodStart)),
              Text('الإجمالي ${_money(total)} ر.س'),
              Text(_shortDate(last.periodStart)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter({
    required this.values,
    required this.color,
    required this.gridColor,
  });
  final List<double> values;
  final Color color;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = gridColor.withValues(alpha: .45)
      ..strokeWidth = 1;
    for (var step = 1; step < 4; step++) {
      final y = size.height * step / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    if (values.isEmpty) return;
    final maxValue = math.max(values.reduce(math.max), 1).toDouble();
    final barGap = values.length > 24 ? 2.0 : 5.0;
    final barWidth = math
        .max(2, (size.width - barGap * (values.length - 1)) / values.length)
        .toDouble();
    final paint = Paint()..color = color;
    for (var index = 0; index < values.length; index++) {
      final height = values[index] / maxValue * (size.height - 8);
      final left = index * (barWidth + barGap);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, size.height - height, barWidth, height),
          const Radius.circular(4),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}

class _OperationsCard extends StatelessWidget {
  const _OperationsCard({required this.operations});
  final AdminOperations operations;

  @override
  Widget build(BuildContext context) => _ReportCard(
    title: 'تشغيل الطلبات',
    subtitle: 'الحالات التي تستحق متابعة فريق التشغيل.',
    child: _KeyValueList(
      rows: [
        ('طلبات جديدة', operations.newOrders, Icons.mark_email_unread_outlined),
        ('بانتظار الدفع', operations.awaitingPayment, Icons.payment_outlined),
        ('فشل الدفع', operations.paymentFailures, Icons.error_outline),
        ('قيد التحضير', operations.inPreparation, Icons.inventory_2_outlined),
        ('في الطريق', operations.inTransit, Icons.local_shipping_outlined),
        ('طلبات مرفوضة', operations.rejectedOrders, Icons.cancel_outlined),
        ('مخزون منخفض', operations.lowStock, Icons.warning_amber_outlined),
        (
          'نفد المخزون',
          operations.outOfStock,
          Icons.remove_shopping_cart_outlined,
        ),
      ],
    ),
  );
}

class _OrderStatusCard extends StatelessWidget {
  const _OrderStatusCard({required this.statuses});
  final List<AdminOrderStatus> statuses;

  @override
  Widget build(BuildContext context) => _ReportCard(
    title: 'توزيع حالات الطلبات',
    subtitle: 'قيمة الطلبات وليست جميعها إيرادًا مؤكدًا.',
    child: statuses.isEmpty
        ? const _NoData(text: 'لا توجد طلبات خلال هذه الفترة.')
        : Column(
            children: statuses.map((status) {
              final total = statuses.fold<int>(
                0,
                (sum, item) => sum + item.orders,
              );
              final share = total == 0 ? 0.0 : status.orders / total;
              return Padding(
                padding: const EdgeInsets.only(bottom: 13),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(status.label)),
                        Text(
                          '${status.orders} · ${(share * 100).toStringAsFixed(0)}%',
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    LinearProgressIndicator(value: share, minHeight: 7),
                    const SizedBox(height: 4),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        'قيمة الطلبات ${_money(status.totalOrderValue)} ر.س',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
  );
}

class _SalesLeakageCard extends StatelessWidget {
  const _SalesLeakageCard({required this.leakage});
  final AdminSalesLeakage leakage;

  @override
  Widget build(BuildContext context) => _ReportCard(
    title: 'تسرب المبيعات',
    subtitle: 'طلبات لم تتحول إلى إيراد مؤكد خلال الفترة.',
    child: _ResponsiveColumns(
      children: [
        _LeakageTile(
          label: 'فشل الدفع',
          orders: leakage.paymentFailureOrders,
          value: leakage.paymentFailureValue,
          color: Theme.of(context).colorScheme.errorContainer,
        ),
        _LeakageTile(
          label: 'طلبات مرفوضة',
          orders: leakage.rejectedOrders,
          value: leakage.rejectedValue,
          color: Theme.of(context).colorScheme.tertiaryContainer,
        ),
      ],
    ),
  );
}

class _LeakageTile extends StatelessWidget {
  const _LeakageTile({
    required this.label,
    required this.orders,
    required this.value,
    required this.color,
  });
  final String label;
  final int orders;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 8),
          Text(
            '${_money(value)} ر.س',
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
          ),
          Text('$orders طلب', style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    ),
  );
}

class _CustomerSummaryCard extends StatelessWidget {
  const _CustomerSummaryCard({required this.customers});
  final AdminCustomerSummary customers;

  @override
  Widget build(BuildContext context) {
    final entries = [
      ('عملاء جدد', customers.newCustomers, Icons.person_add_alt_1_outlined),
      ('عملاء مشترون', customers.purchasingCustomers, Icons.people_outline),
      ('عملاء عائدون', customers.returningCustomers, Icons.repeat_outlined),
      (
        'معدل تكرار الشراء',
        customers.repeatPurchaseRate == null
            ? '—'
            : '${customers.repeatPurchaseRate!.toStringAsFixed(1)}%',
        Icons.percent_outlined,
      ),
      (
        'عملاء مميزون',
        customers.premiumCustomers,
        Icons.workspace_premium_outlined,
      ),
      (
        'مسجلو المكافآت',
        customers.rewardEnrolledCustomers,
        Icons.card_giftcard_outlined,
      ),
      (
        'غير نشطين 90 يومًا',
        customers.inactiveCustomersLast90Days,
        Icons.person_off_outlined,
      ),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: entries
              .map(
                (entry) => SizedBox(
                  width: 175,
                  child: Row(
                    children: [
                      Icon(
                        entry.$3,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${entry.$2}',
                              style: const TextStyle(
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
              )
              .toList(),
        ),
      ),
    );
  }
}

class _TopCustomersCard extends StatelessWidget {
  const _TopCustomersCard({required this.customers});
  final List<AdminTopCustomer> customers;

  @override
  Widget build(BuildContext context) => _ReportCard(
    title: 'أفضل العملاء',
    subtitle: 'مرتّبون بالإيراد المؤكد في الفترة المحددة.',
    child: customers.isEmpty
        ? const _NoData(text: 'لا يوجد عملاء مشترون خلال هذه الفترة.')
        : Column(
            children: customers
                .map(
                  (customer) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(child: Text('${customer.id}')),
                    title: Text(customer.label),
                    subtitle: Wrap(
                      spacing: 6,
                      children: [
                        Text('${customer.orders} طلب'),
                        if (customer.isPremium) const _Tag(text: 'مميز'),
                        if (customer.rewardEnrolled) const _Tag(text: 'مكافآت'),
                      ],
                    ),
                    trailing: Text(
                      '${_money(customer.revenue)} ر.س',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                )
                .toList(),
          ),
  );
}

class _TopProductsCard extends StatelessWidget {
  const _TopProductsCard({required this.products});
  final List<AdminTopProduct> products;

  @override
  Widget build(BuildContext context) => _ReportCard(
    title: 'المنتجات الأعلى أداءً',
    subtitle: 'مرتبة بالإيراد، مع متابعة المخزون الحالي.',
    child: products.isEmpty
        ? const _NoData(text: 'لا توجد مبيعات مؤكدة خلال هذه الفترة.')
        : Column(
            children: products
                .map(
                  (product) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(child: Text('${product.id}')),
                    title: Text(product.name),
                    subtitle: Text(
                      '${product.categoryName.isEmpty ? 'بدون تصنيف' : product.categoryName} · ${product.unitsSold} قطعة · ${product.orders} طلب · مخزون ${product.currentStock}',
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

class _CategoryPerformanceCard extends StatelessWidget {
  const _CategoryPerformanceCard({required this.categories});
  final List<AdminCategoryPerformance> categories;

  @override
  Widget build(BuildContext context) => _ReportCard(
    title: 'التصنيفات الأعلى أداءً',
    subtitle: 'تصنيفات المنتجات داخل الطلبات المؤكدة.',
    child: categories.isEmpty
        ? const _NoData(text: 'لا توجد تصنيفات لها مبيعات في هذه الفترة.')
        : Column(
            children: categories
                .map(
                  (category) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(category.label),
                    subtitle: Text(
                      '${category.unitsSold} قطعة · ${category.orders} طلب',
                    ),
                    trailing: Text(
                      '${_money(category.revenue)} ر.س',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                )
                .toList(),
          ),
  );
}

class _SlowMovingCard extends StatelessWidget {
  const _SlowMovingCard({required this.products});
  final List<AdminSlowMovingProduct> products;

  @override
  Widget build(BuildContext context) => _ReportCard(
    title: 'منتجات بطيئة الحركة',
    subtitle:
        'الأقل مبيعًا مع المخزون الحالي؛ استخدمها كإشارة مراجعة لا كقرار تلقائي.',
    child: products.isEmpty
        ? const _NoData(text: 'لا توجد منتجات صالحة للتحليل في هذه الفترة.')
        : Column(
            children: products
                .map(
                  (product) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.hourglass_bottom_outlined),
                    title: Text(product.name),
                    subtitle: Text(product.categoryName),
                    trailing: Text(
                      '${product.unitsSold} مبيع\nمخزون ${product.currentStock}',
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                )
                .toList(),
          ),
  );
}

class _StockAlertsCard extends StatelessWidget {
  const _StockAlertsCard({required this.alerts});
  final List<AdminStockAlert> alerts;

  @override
  Widget build(BuildContext context) => _ReportCard(
    title: 'تنبيهات المخزون',
    subtitle: 'اللقطة الحالية للمخزون وليست تاريخًا محفوظًا على الجهاز.',
    child: alerts.isEmpty
        ? const _NoData(text: 'لا توجد تنبيهات مخزون الآن.')
        : Column(
            children: alerts
                .map(
                  (alert) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.warning_amber_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    title: Text(alert.name),
                    subtitle: Text(
                      '${alert.label} · المتاح ${alert.currentStock} من حد ${alert.minimumStock} · مبيعات الفترة ${alert.unitsSold}',
                    ),
                  ),
                )
                .toList(),
          ),
  );
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({
    required this.title,
    required this.icon,
    required this.items,
  });
  final String title;
  final IconData icon;
  final List<AdminBreakdown> items;

  @override
  Widget build(BuildContext context) => _ReportCard(
    title: title,
    titleIcon: icon,
    child: items.isEmpty
        ? const _NoData(text: 'لا توجد بيانات للفترة المحددة.')
        : Column(
            children: items
                .map(
                  (item) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.label),
                    subtitle: Text('${item.orders} طلب'),
                    trailing: Text(
                      '${_money(item.revenue)} ر.س',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                )
                .toList(),
          ),
  );
}

class _CouponComparisonCard extends StatelessWidget {
  const _CouponComparisonCard({required this.comparison});
  final AdminCouponComparison comparison;

  @override
  Widget build(BuildContext context) => _ReportCard(
    title: 'مقارنة أثر الكوبونات',
    subtitle: 'الإيراد المقارن لا يعني أن الكوبون سبب البيع بمفرده.',
    child: Column(
      children: [
        _CouponComparisonRow(
          label: 'مع كوبون',
          orders: comparison.ordersWithCoupon,
          revenue: comparison.revenueWithCoupon,
          detail:
              'قيمة الخصم ${_money(comparison.discountAmountWithCoupon)} ر.س',
          highlighted: true,
        ),
        const SizedBox(height: 10),
        _CouponComparisonRow(
          label: 'بدون كوبون',
          orders: comparison.ordersWithoutCoupon,
          revenue: comparison.revenueWithoutCoupon,
          detail: 'لا توجد قيمة خصم مسجلة',
        ),
      ],
    ),
  );
}

class _CouponComparisonRow extends StatelessWidget {
  const _CouponComparisonRow({
    required this.label,
    required this.orders,
    required this.revenue,
    required this.detail,
    this.highlighted = false,
  });
  final String label;
  final int orders;
  final double revenue;
  final String detail;
  final bool highlighted;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: highlighted
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Padding(
      padding: const EdgeInsets.all(13),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_money(revenue)} ر.س',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                '$orders طلب · $detail',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _CouponsCard extends StatelessWidget {
  const _CouponsCard({required this.coupons});
  final List<AdminCoupon> coupons;

  @override
  Widget build(BuildContext context) => _ReportCard(
    title: 'أفضل الكوبونات',
    subtitle: 'مرتّبة بالإيراد المؤكد المنسوب لكل كوبون.',
    child: coupons.isEmpty
        ? const _NoData(text: 'لم يستخدم أي كوبون في الطلبات المؤكدة.')
        : Column(
            children: coupons
                .map(
                  (coupon) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.confirmation_number_outlined),
                    title: Text(coupon.label),
                    subtitle: Text(
                      '${coupon.orders} طلب · خصم ${_money(coupon.discountAmount)} ر.س',
                    ),
                    trailing: Text(
                      '${_money(coupon.revenue)} ر.س',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                )
                .toList(),
          ),
  );
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.title,
    required this.child,
    this.subtitle,
    this.titleIcon,
  });
  final String title;
  final String? subtitle;
  final IconData? titleIcon;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (titleIcon case final icon?) ...[
                Icon(
                  icon,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle case final text?) ...[
            const SizedBox(height: 4),
            Text(text, style: Theme.of(context).textTheme.bodySmall),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    ),
  );
}

class _KeyValueList extends StatelessWidget {
  const _KeyValueList({required this.rows});
  final List<(String, int, IconData)> rows;

  @override
  Widget build(BuildContext context) => Column(
    children: rows
        .map(
          (row) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Icon(
                  row.$3,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 9),
                Expanded(child: Text(row.$1)),
                Text(
                  '${row.$2}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        )
        .toList(),
  );
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
        style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 3),
      Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      color: Theme.of(context).colorScheme.primary,
      fontSize: 12,
    ),
  );
}

class _NoData extends StatelessWidget {
  const _NoData({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Center(child: Text(text, textAlign: TextAlign.center)),
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

class _EmptyReport extends StatelessWidget {
  const _EmptyReport({required this.onRetry});
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined, size: 48),
          const SizedBox(height: 12),
          const Text('لم نتمكن من تحميل التقرير.'),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
        ],
      ),
    ),
  );
}

String _money(double value) =>
    value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);

String _whole(double value) => value.toStringAsFixed(0);

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

String _shortDate(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}';
