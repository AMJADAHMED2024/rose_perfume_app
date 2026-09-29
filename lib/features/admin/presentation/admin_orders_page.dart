import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/security/secure_session_store.dart';
import '../../../core/security/session_identity.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../application/admin_orders_controller.dart';
import '../data/admin_orders_repository.dart';

class AdminOrdersPage extends ConsumerStatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  ConsumerState<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends ConsumerState<AdminOrdersPage> {
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
        return const Scaffold(body: SkeletonPage());
      }
      if (snapshot.data != true) {
        return Scaffold(
          appBar: AppBar(title: const Text('إدارة الطلبات')),
          body: Center(
            child: FilledButton(
              onPressed: () => context.go('/account'),
              child: const Text('العودة إلى الحساب'),
            ),
          ),
        );
      }
      return const _OrdersView();
    },
  );
}

class _OrdersView extends ConsumerStatefulWidget {
  const _OrdersView();

  @override
  ConsumerState<_OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends ConsumerState<_OrdersView> {
  final _search = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref.read(adminOrdersControllerProvider.notifier).search(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminOrdersControllerProvider);
    final controller = ref.read(adminOrdersControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الطلبات'),
        actions: [
          IconButton(
            tooltip: 'لوحة التحكم',
            onPressed: () => context.go('/admin'),
            icon: const Icon(Icons.dashboard_outlined),
          ),
          IconButton(
            tooltip: 'تحديث',
            onPressed: state.isLoading ? null : controller.load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18),
          children: [
            TextField(
              controller: _search,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              onSubmitted: controller.search,
              decoration: const InputDecoration(
                labelText: 'ابحث برقم الطلب أو العميل',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 14),
            if (state.errorMessage case final message?)
              _ErrorCard(message: message),
            if (state.errorMessage != null) const SizedBox(height: 14),
            if (state.isLoading && state.data == null)
              const Padding(
                padding: EdgeInsets.only(top: 56),
                child: SkeletonList(),
              )
            else if (state.data?.items.isEmpty ?? true)
              const Padding(
                padding: EdgeInsets.only(top: 56),
                child: Center(child: Text('لا توجد طلبات مطابقة.')),
              )
            else ...[
              _OrdersTable(orders: state.data!.items),
              const SizedBox(height: 14),
              _Pagination(
                data: state.data!,
                isLoading: state.isLoading,
                onPage: controller.goToPage,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OrdersTable extends StatelessWidget {
  const _OrdersTable({required this.orders});
  final List<AdminOrder> orders;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('الطلب')),
          DataColumn(label: Text('العميل')),
          DataColumn(label: Text('الحالة')),
          DataColumn(label: Text('الإجمالي')),
          DataColumn(label: Text('التفاصيل')),
        ],
        rows: orders
            .map(
              (order) => DataRow(
                cells: [
                  DataCell(Text('#${order.id}')),
                  DataCell(Text(order.customerName)),
                  DataCell(_StatusChip(status: order.status)),
                  DataCell(Text('${_money(order.totalPrice)} ر.س')),
                  DataCell(
                    IconButton(
                      tooltip: 'عرض تفاصيل الطلب',
                      onPressed: () => _showOrderDetails(context, order),
                      icon: const Icon(Icons.visibility_outlined),
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    ),
  );
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
      5 => ('قيد التحضير', Colors.indigo),
      6 => ('في الطريق', Colors.purple),
      7 => ('مكتمل', Colors.green),
      _ => ('قيد المراجعة', Colors.grey),
    };
    return Chip(
      label: Text(label, style: TextStyle(color: color.shade800)),
      backgroundColor: color.shade50,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _Pagination extends StatelessWidget {
  const _Pagination({
    required this.data,
    required this.isLoading,
    required this.onPage,
  });
  final AdminOrdersPageData data;
  final bool isLoading;
  final ValueChanged<int> onPage;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text('${data.totalCount} طلبًا')),
      IconButton(
        tooltip: 'الصفحة السابقة',
        onPressed: isLoading || data.pageNumber <= 1
            ? null
            : () => onPage(data.pageNumber - 1),
        icon: const Icon(Icons.chevron_right),
      ),
      Text('${data.pageNumber} / ${data.totalPages}'),
      IconButton(
        tooltip: 'الصفحة التالية',
        onPressed: isLoading || data.pageNumber >= data.totalPages
            ? null
            : () => onPage(data.pageNumber + 1),
        icon: const Icon(Icons.chevron_left),
      ),
    ],
  );
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.errorContainer,
    child: Padding(padding: const EdgeInsets.all(14), child: Text(message)),
  );
}

void _showOrderDetails(BuildContext context, AdminOrder order) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: FractionallySizedBox(
        heightFactor: .8,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'طلب #${order.id}',
              style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _DetailLine(label: 'العميل', value: order.customerName),
            _DetailLine(label: 'الدفع', value: order.paymentMethod),
            if (order.couponCode case final coupon?)
              _DetailLine(label: 'الكوبون', value: coupon),
            if (order.shippingAddress case final address?)
              _DetailLine(label: 'العنوان', value: address),
            const Divider(height: 30),
            const Text(
              'المنتجات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (order.items.isEmpty)
              const Text('لا توجد تفاصيل منتجات متاحة لهذا الطلب.')
            else
              ...order.items.map(
                (item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.name),
                  subtitle: Text(
                    '${item.quantity} × ${_money(item.price)} ر.س',
                  ),
                  trailing: Text('${_money(item.quantity * item.price)} ر.س'),
                ),
              ),
            const Divider(height: 30),
            _DetailLine(
              label: 'الإجمالي',
              value: '${_money(order.totalPrice)} ر.س',
              emphasized: true,
            ),
          ],
        ),
      ),
    ),
  );
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.label,
    required this.value,
    this.emphasized = false,
  });
  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: emphasized
                ? const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)
                : null,
          ),
        ),
      ],
    ),
  );
}

String _money(num value) =>
    value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
