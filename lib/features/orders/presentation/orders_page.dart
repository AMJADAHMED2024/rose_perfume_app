import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../../../core/widgets/app_page_components.dart';
import '../../auth/application/auth_controller.dart';
import '../application/orders_controller.dart';
import '../data/orders_repository.dart';

class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = AppCopy.of(context);
    if (!ref.watch(authControllerProvider).isSignedIn) {
      return Scaffold(
        appBar: AppBar(title: Text(copy.orders)),
        body: Center(
          child: FilledButton(
            onPressed: () => context.go('/account'),
            child: Text(copy.signInToOrders),
          ),
        ),
      );
    }
    final state = ref.watch(ordersControllerProvider);
    final controller = ref.read(ordersControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text(copy.orders)),
      body: RefreshIndicator(
        onRefresh: controller.load,
        child: state.isLoading
            ? const SkeletonPage()
            : state.orders.isEmpty && state.errorMessage != null
            ? _ErrorState(
                message: state.errorMessage!,
                onRetry: controller.load,
              )
            : state.orders.isEmpty
            ? _EmptyOrders(copy: copy)
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(18),
                children: [
                  AppPageHeader(
                    title: copy.orders,
                    subtitle: copy.ordersSubtitle,
                    icon: Icons.inventory_2_outlined,
                  ),
                  const SizedBox(height: 20),
                  if (state.isShowingCachedData)
                    const _CacheBanner(
                      text:
                          'تعرض آخر نسخة محفوظة. اسحب للتحديث عند عودة الإنترنت.',
                    ),
                  if (state.errorMessage case final message?)
                    _CacheBanner(text: message),
                  for (final order in state.orders) ...[
                    _OrderCard(order: order),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final CustomerOrder order;

  @override
  Widget build(BuildContext context) => Card(
    child: ExpansionTile(
      leading: CircleAvatar(child: Icon(_statusIcon(order.status))),
      title: Text('طلب #${order.id}'),
      subtitle: Text(_dateLabel(order.createdAt)),
      trailing: _StatusChip(status: order.status),
      childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      children: [
        const Divider(),
        for (final item in order.items)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(item.productName),
            subtitle: Text(
              '${item.quantity} قطعة'
              '${item.productVariantName == null ? '' : ' · ${item.productVariantName}'}',
            ),
            trailing: Text(
              '${(item.price * item.quantity).toStringAsFixed(0)} ر.س',
            ),
          ),
        const Divider(),
        _AmountRow(label: 'الإجمالي', amount: order.totalPrice),
        if (order.paymentMethod?.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('الدفع: ${order.paymentMethod}'),
          ),
        if (order.shipmentId?.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('رقم الشحنة: ${order.shipmentId}'),
          ),
        if (order.labelUrl?.isNotEmpty == true)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () => _openShipment(context, order.labelUrl!),
              icon: const Icon(Icons.local_shipping_outlined),
              label: const Text('فتح تفاصيل الشحنة'),
            ),
          ),
      ],
    ),
  );

  static IconData _statusIcon(int status) => switch (status) {
    6 => Icons.local_shipping_outlined,
    7 => Icons.task_alt_outlined,
    2 || 4 => Icons.error_outline,
    _ => Icons.inventory_2_outlined,
  };

  static String _dateLabel(DateTime? date) => date == null
      ? 'تاريخ الطلب غير متاح'
      : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  Future<void> _openShipment(BuildContext context, String url) async {
    if (!await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        ) &&
        context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تعذر فتح رابط الشحنة.')));
    }
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final int status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      1 => ('جديد', Colors.blue),
      2 => ('مرفوض', Colors.red),
      3 => ('بانتظار الدفع', Colors.orange),
      4 => ('فشل الدفع', Colors.red),
      5 => ('قيد التحضير', Colors.deepPurple),
      6 => ('في الطريق', Colors.teal),
      7 => ('مكتمل', Colors.green),
      8 => ('تأكيد تمارا', Colors.green),
      _ => ('قيد المراجعة', Colors.grey),
    };
    return Chip(
      label: Text(label, style: TextStyle(color: color)),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.35)),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({required this.label, required this.amount});
  final String label;
  final double amount;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      const Spacer(),
      Text('${amount.toStringAsFixed(2)} ر.س'),
    ],
  );
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders({required this.copy});
  final AppCopy copy;
  @override
  Widget build(BuildContext context) => AppEmptyState(
    icon: Icons.receipt_long_outlined,
    title: copy.emptyOrders,
    message: copy.emptyOrdersMessage,
    actionLabel: copy.browseFragrances,
    onAction: () => context.go('/products'),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;
  @override
  Widget build(BuildContext context) => AppEmptyState(
    icon: Icons.cloud_off_outlined,
    title: 'تعذر تحميل الطلبات',
    message: message,
    actionLabel: 'إعادة المحاولة',
    onAction: onRetry,
  );
}

class _CacheBanner extends StatelessWidget {
  const _CacheBanner({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: AppFeedbackBanner(message: text, tone: AppBannerTone.warning),
  );
}
