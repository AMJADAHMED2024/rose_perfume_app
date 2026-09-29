import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/adaptive_layout.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../../auth/application/auth_controller.dart';
import '../../orders/application/orders_controller.dart';
import '../../orders/data/orders_repository.dart';

class CustomerDashboardPage extends ConsumerWidget {
  const CustomerDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(authControllerProvider).isSignedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('لوحة الحساب')),
        body: Center(
          child: FilledButton(
            onPressed: () => context.go('/account'),
            child: const Text('سجّل الدخول لعرض حسابك'),
          ),
        ),
      );
    }
    final state = ref.watch(ordersControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة الحساب'),
        actions: [
          IconButton(
            tooltip: 'تحديث',
            onPressed: state.isLoading
                ? null
                : ref.read(ordersControllerProvider.notifier).load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: state.isLoading && state.orders.isEmpty
          ? const SkeletonPage(layout: SkeletonLayout.dashboard)
          : RefreshIndicator(
              onRefresh: ref.read(ordersControllerProvider.notifier).load,
              child: AdaptivePage(
                maxWidth: 1024,
                child: _DashboardContent(
                  orders: state.orders,
                  showingCachedData: state.isShowingCachedData,
                  errorMessage: state.errorMessage,
                ),
              ),
            ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.orders,
    required this.showingCachedData,
    this.errorMessage,
  });
  final List<CustomerOrder> orders;
  final bool showingCachedData;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final active = orders.where((order) => order.status < 7).length;
    final completed = orders.where((order) => order.status == 7).length;
    final spent = orders
        .where((order) => order.status == 7)
        .fold<double>(0, (total, order) => total + order.totalPrice);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(18),
      children: [
        _WelcomeCard(orderCount: orders.length),
        const SizedBox(height: 18),
        if (showingCachedData || errorMessage != null) ...[
          _InfoBanner(
            text:
                errorMessage ??
                'تعرض آخر نسخة محفوظة من طلباتك. اسحب للتحديث عند عودة الإنترنت.',
          ),
          const SizedBox(height: 14),
        ],
        AdaptiveGrid(
          minimumTileWidth: 150,
          childAspectRatio: 1.35,
          children: [
            _MetricCard(
              icon: Icons.receipt_long_outlined,
              label: 'إجمالي الطلبات',
              value: '${orders.length}',
            ),
            _MetricCard(
              icon: Icons.local_shipping_outlined,
              label: 'طلبات قيد المتابعة',
              value: '$active',
            ),
            _MetricCard(
              icon: Icons.task_alt_outlined,
              label: 'طلبات مكتملة',
              value: '$completed',
            ),
            _MetricCard(
              icon: Icons.account_balance_wallet_outlined,
              label: 'إجمالي المكتمل',
              value: '${spent.toStringAsFixed(0)} ر.س',
            ),
          ],
        ),
        const SizedBox(height: 26),
        Row(
          children: [
            const Text(
              'أحدث الطلبات',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.go('/orders'),
              child: const Text('عرض الكل'),
            ),
          ],
        ),
        if (orders.isEmpty)
          const _EmptyOrdersCard()
        else
          ...orders
              .take(3)
              .map(
                (order) => Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: _RecentOrderCard(order: order),
                ),
              ),
        const SizedBox(height: 24),
        FilledButton.tonalIcon(
          onPressed: () => context.go('/addresses'),
          icon: const Icon(Icons.location_on_outlined),
          label: const Text('إدارة عناوين التوصيل'),
        ),
      ],
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.orderCount});
  final int orderCount;

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
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مرحبًا بك في روز برفيوم',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'تابع طلباتك وعناوينك من مكان واحد.',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        CircleAvatar(
          radius: 27,
          backgroundColor: Colors.white24,
          child: Text(
            '$orderCount',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    ),
  );
}

class _RecentOrderCard extends StatelessWidget {
  const _RecentOrderCard({required this.order});
  final CustomerOrder order;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: CircleAvatar(child: Icon(_statusIcon(order.status))),
      title: Text('طلب #${order.id}'),
      subtitle: Text(_statusLabel(order.status)),
      trailing: Text(
        '${order.totalPrice.toStringAsFixed(0)} ر.س',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      onTap: () => context.go('/orders'),
    ),
  );
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(text),
  );
}

class _EmptyOrdersCard extends StatelessWidget {
  const _EmptyOrdersCard();

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          const Icon(Icons.shopping_bag_outlined, size: 52),
          const SizedBox(height: 10),
          const Text('لم تنشئ طلبًا بعد.'),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: () => context.go('/products'),
            child: const Text('تصفح العطور'),
          ),
        ],
      ),
    ),
  );
}

IconData _statusIcon(int status) => switch (status) {
  7 => Icons.task_alt_outlined,
  6 => Icons.local_shipping_outlined,
  2 || 4 => Icons.error_outline,
  _ => Icons.inventory_2_outlined,
};

String _statusLabel(int status) => switch (status) {
  1 => 'طلب جديد',
  2 => 'مرفوض',
  3 => 'بانتظار الدفع',
  4 => 'فشل الدفع',
  5 => 'قيد التحضير',
  6 => 'في الطريق',
  7 => 'مكتمل',
  _ => 'قيد المراجعة',
};
