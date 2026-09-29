import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_skeleton.dart';
import '../data/admin_customers_repository.dart';
import '../data/admin_notifications_repository.dart';
import '../data/admin_orders_repository.dart';
import 'admin_customer_editor.dart';

final adminCustomerDetailProvider = FutureProvider.autoDispose
    .family<AdminCustomer, int>(
      (ref, id) => ref.watch(adminCustomersRepositoryProvider).fetchById(id),
    );

final adminCustomerOrdersProvider = FutureProvider.autoDispose
    .family<AdminOrdersPageData, int>(
      (ref, id) =>
          ref.watch(adminOrdersRepositoryProvider).fetchCustomerOrders(id),
    );

class AdminCustomerDetailPage extends ConsumerWidget {
  const AdminCustomerDetailPage({super.key, required this.customerId});
  final int customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customer = ref.watch(adminCustomerDetailProvider(customerId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('ملف العميل'),
        actions: [
          IconButton(
            tooltip: 'تحديث',
            onPressed: () =>
                ref.invalidate(adminCustomerDetailProvider(customerId)),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'تعديل بيانات العميل',
            onPressed: customer.valueOrNull == null
                ? null
                : () => _edit(context, ref, customer.value!),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: customer.when(
        loading: () => const SkeletonPage(layout: SkeletonLayout.details),
        error: (_, _) => _ErrorState(
          onRetry: () =>
              ref.invalidate(adminCustomerDetailProvider(customerId)),
        ),
        data: (item) => ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _ProfileHeader(customer: item),
            const SizedBox(height: 14),
            _ProfileCard(customer: item),
            const SizedBox(height: 20),
            _CustomerOrders(customerId: customerId),
            const SizedBox(height: 20),
            const Text(
              'إجراءات الإدارة',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            _ActionCard(
              icon: Icons.notifications_active_outlined,
              title: 'إرسال إشعار خاص',
              subtitle: 'يرسل مباشرة إلى صندوق إشعارات العميل.',
              onTap: () => _sendNotification(context, ref, item),
            ),
            const SizedBox(height: 8),
            _ActionCard(
              icon: item.status
                  ? Icons.block_outlined
                  : Icons.check_circle_outline,
              title: item.status ? 'تعطيل الحساب' : 'تفعيل الحساب',
              subtitle: item.status
                  ? 'يمنع العميل من استخدام حسابه حتى يعاد تفعيله.'
                  : 'يعيد السماح للعميل باستخدام حسابه.',
              destructive: item.status,
              onTap: () => _setStatus(context, ref, item, !item.status),
            ),
            const SizedBox(height: 8),
            _ActionCard(
              icon: Icons.delete_outline,
              title: 'حذف الحساب',
              subtitle: 'حذف منطقي يحافظ على تاريخ الطلبات ويمنع تسجيل الدخول.',
              destructive: true,
              onTap: () => _delete(context, ref, item),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    AdminCustomer customer,
  ) async {
    final draft = await showAdminCustomerEditor(context, customer: customer);
    if (draft == null) return;
    try {
      await ref
          .read(adminCustomersRepositoryProvider)
          .update(customer.id, draft);
      ref.invalidate(adminCustomerDetailProvider(customerId));
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم حفظ بيانات العميل.')));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر حفظ بيانات العميل.')),
        );
      }
    }
  }

  Future<void> _setStatus(
    BuildContext context,
    WidgetRef ref,
    AdminCustomer customer,
    bool active,
  ) async {
    try {
      await ref
          .read(adminCustomersRepositoryProvider)
          .setStatus(customer, active);
      ref.invalidate(adminCustomerDetailProvider(customerId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(active ? 'تم تفعيل الحساب.' : 'تم تعطيل الحساب.'),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر تحديث حالة الحساب.')),
        );
      }
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    AdminCustomer customer,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف حساب العميل؟'),
        content: Text(
          'سيُعطّل حساب ${customer.name} ويُخفى من إدارة العملاء، مع الاحتفاظ بتاريخ طلباته.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف الحساب'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(adminCustomersRepositoryProvider).delete(customer.id);
      if (context.mounted) context.go('/admin/customers');
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تعذر حذف الحساب.')));
      }
    }
  }

  Future<void> _sendNotification(
    BuildContext context,
    WidgetRef ref,
    AdminCustomer customer,
  ) async {
    final draft = await showDialog<_NotificationDraft>(
      context: context,
      builder: (_) => _NotificationDialog(customer: customer),
    );
    if (draft == null) return;
    try {
      await ref
          .read(adminNotificationsRepositoryProvider)
          .send(
            title: draft.title,
            description: draft.description,
            userId: customer.id,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال الإشعار للعميل.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تعذر إرسال الإشعار.')));
      }
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.customer});
  final AdminCustomer customer;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      gradient: const LinearGradient(
        colors: [Color(0xFF311328), Color(0xFF7B3B5E)],
      ),
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 29,
          backgroundColor: Colors.white24,
          child: Text(
            '${customer.id}',
            style: const TextStyle(color: Colors.white, fontSize: 19),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customer.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                customer.email,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        Icon(
          customer.status
              ? Icons.verified_user_outlined
              : Icons.person_off_outlined,
          color: customer.status ? const Color(0xFFF3D78C) : Colors.white70,
        ),
      ],
    ),
  );
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.customer});
  final AdminCustomer customer;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.mail_outline,
            label: 'البريد الإلكتروني',
            value: customer.email,
          ),
          _DetailRow(
            icon: Icons.phone_outlined,
            label: 'الهاتف',
            value: customer.phone.isEmpty ? 'غير مسجل' : customer.phone,
          ),
          _DetailRow(
            icon: Icons.badge_outlined,
            label: 'الدور',
            value: customer.role,
          ),
          _DetailRow(
            icon: Icons.toggle_on_outlined,
            label: 'الحالة',
            value: customer.status ? 'نشط' : 'معطّل',
          ),
          _DetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'تاريخ التسجيل',
            value: customer.createdAt == null
                ? 'غير متاح'
                : _date(customer.createdAt!),
          ),
        ],
      ),
    ),
  );
}

class _CustomerOrders extends ConsumerWidget {
  const _CustomerOrders({required this.customerId});
  final int customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(adminCustomerOrdersProvider(customerId));
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: orders.when(
          loading: () => const SizedBox(
            height: 76,
            child: AppSkeleton(child: SkeletonBox(height: 76, radius: 16)),
          ),
          error: (_, _) => Row(
            children: [
              const Expanded(child: Text('تعذر تحميل سجل الطلبات.')),
              TextButton(
                onPressed: () =>
                    ref.invalidate(adminCustomerOrdersProvider(customerId)),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
          data: (data) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long_outlined),
                  const SizedBox(width: 9),
                  const Expanded(
                    child: Text(
                      'سجل الطلبات',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text('${data.totalCount} طلب'),
                ],
              ),
              const SizedBox(height: 7),
              if (data.items.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('لا توجد طلبات لهذا العميل حتى الآن.'),
                )
              else
                ...data.items.map(
                  (order) => ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 18,
                      child: Text('#${order.id}'),
                    ),
                    title: Text('${order.totalPrice.toStringAsFixed(0)} ر.س'),
                    subtitle: Text(
                      '${_date(order.createdAt?.toLocal() ?? DateTime.now())} · ${_orderStatus(order.status)}',
                    ),
                    children: [
                      if (order.shippingAddress != null)
                        ListTile(
                          dense: true,
                          leading: const Icon(Icons.local_shipping_outlined),
                          title: Text(order.shippingAddress!),
                        ),
                      ...order.items.map(
                        (line) => ListTile(
                          dense: true,
                          title: Text(line.name),
                          subtitle: Text(
                            'الكمية: ${line.quantity}${line.variantName == null ? '' : ' · ${line.variantName}'}',
                          ),
                          trailing: Text(
                            '${line.price.toStringAsFixed(0)} ر.س',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String _orderStatus(int status) => switch (status) {
  0 => 'قيد المراجعة',
  1 => 'مقبول',
  2 => 'مرفوض',
  3 => 'قيد الشحن',
  4 => 'مكتمل',
  _ => 'حالة الطلب: $status',
};

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(child: Text(label)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(
        icon,
        color: destructive
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_left),
      onTap: onTap,
    ),
  );
}

class _NotificationDraft {
  const _NotificationDraft(this.title, this.description);
  final String title;
  final String description;
}

class _NotificationDialog extends StatefulWidget {
  const _NotificationDialog({required this.customer});
  final AdminCustomer customer;
  @override
  State<_NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<_NotificationDialog> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('إشعار إلى ${widget.customer.name}'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _title,
          decoration: const InputDecoration(labelText: 'العنوان'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _description,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'الرسالة'),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('إلغاء'),
      ),
      FilledButton(
        onPressed: () {
          if (_title.text.trim().isEmpty || _description.text.trim().isEmpty) {
            return;
          }
          Navigator.pop(
            context,
            _NotificationDraft(_title.text.trim(), _description.text.trim()),
          );
        },
        child: const Text('إرسال'),
      ),
    ],
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.cloud_off_outlined, size: 48),
        const SizedBox(height: 12),
        const Text('تعذر تحميل ملف العميل.'),
        const SizedBox(height: 10),
        FilledButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
      ],
    ),
  );
}

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
