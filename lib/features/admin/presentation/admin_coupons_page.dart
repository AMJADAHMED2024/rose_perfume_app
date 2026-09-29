import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_skeleton.dart';
import '../application/admin_coupons_controller.dart';
import '../data/admin_coupons_repository.dart';

class AdminCouponsPage extends ConsumerStatefulWidget {
  const AdminCouponsPage({super.key});

  @override
  ConsumerState<AdminCouponsPage> createState() => _AdminCouponsPageState();
}

class _AdminCouponsPageState extends ConsumerState<AdminCouponsPage> {
  final _search = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _searchCoupons(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref.read(adminCouponsControllerProvider.notifier).search(value);
    });
  }

  Future<void> _edit([AdminCoupon? coupon]) async {
    final draft = await showDialog<AdminCouponDraft>(
      context: context,
      builder: (_) => _CouponDialog(coupon: coupon),
    );
    if (draft == null || !mounted) return;
    try {
      await ref
          .read(adminCouponsControllerProvider.notifier)
          .save(coupon: coupon, draft: draft);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              coupon == null ? 'تمت إضافة الكوبون.' : 'تم تحديث الكوبون.',
            ),
          ),
        );
      }
    } on StateError catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message.toString())));
      }
    }
  }

  Future<void> _delete(AdminCoupon coupon) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الكوبون؟'),
        content: Text('سيُحذف الكود ${coupon.code} نهائيًا.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(adminCouponsControllerProvider.notifier).delete(coupon);
    } on StateError catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminCouponsControllerProvider);
    final notifier = ref.read(adminCouponsControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الكوبونات'),
        actions: [
          IconButton(
            tooltip: 'لوحة التحكم',
            onPressed: () => context.go('/admin'),
            icon: const Icon(Icons.dashboard_outlined),
          ),
          IconButton(
            tooltip: 'تحديث',
            onPressed: state.isLoading ? null : notifier.load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _edit,
        icon: const Icon(Icons.add),
        label: const Text('كوبون جديد'),
      ),
      body: RefreshIndicator(
        onRefresh: notifier.load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18),
          children: [
            TextField(
              controller: _search,
              onChanged: _searchCoupons,
              onSubmitted: notifier.search,
              decoration: const InputDecoration(
                labelText: 'ابحث بالكود',
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
                child: Center(child: Text('لا توجد كوبونات مطابقة.')),
              )
            else ...[
              Card(
                child: Column(
                  children: state.data!.items
                      .map(
                        (coupon) => ListTile(
                          leading: Icon(
                            coupon.isPercentage
                                ? Icons.percent
                                : Icons.payments_outlined,
                          ),
                          title: Text(
                            coupon.code,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            '${_discountLabel(coupon)} · ينتهي ${_date(coupon.expiryDate)}',
                          ),
                          trailing: Wrap(
                            children: [
                              IconButton(
                                tooltip: 'تعديل',
                                onPressed: () => _edit(coupon),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                tooltip: 'حذف',
                                onPressed: () => _delete(coupon),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 14),
              _Pagination(
                data: state.data!,
                isLoading: state.isLoading,
                onPage: notifier.goToPage,
              ),
            ],
            const SizedBox(height: 70),
          ],
        ),
      ),
    );
  }
}

class _CouponDialog extends StatefulWidget {
  const _CouponDialog({this.coupon});
  final AdminCoupon? coupon;

  @override
  State<_CouponDialog> createState() => _CouponDialogState();
}

class _CouponDialogState extends State<_CouponDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _code;
  late final TextEditingController _discount;
  late DateTime _expiry;
  late bool _percentage;

  @override
  void initState() {
    super.initState();
    final draft = widget.coupon == null
        ? null
        : AdminCouponDraft.fromCoupon(widget.coupon!);
    _code = TextEditingController(text: draft?.code);
    _discount = TextEditingController(text: draft?.discount.toString() ?? '');
    _expiry = draft?.expiryDate ?? DateTime.now().add(const Duration(days: 30));
    _percentage = draft?.isPercentage ?? true;
  }

  @override
  void dispose() {
    _code.dispose();
    _discount.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDate: _expiry.isBefore(DateTime.now()) ? DateTime.now() : _expiry,
    );
    if (picked != null && mounted) setState(() => _expiry = picked);
  }

  void _save() {
    if (!(_form.currentState?.validate() ?? false)) return;
    Navigator.pop(
      context,
      AdminCouponDraft(
        code: _code.text.trim(),
        discount: double.parse(_discount.text.trim()),
        expiryDate: _expiry,
        isPercentage: _percentage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.coupon == null ? 'إضافة كوبون' : 'تعديل الكوبون'),
    content: SizedBox(
      width: 440,
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _code,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(labelText: 'الكود'),
              validator: (value) =>
                  value?.trim().isNotEmpty == true ? null : 'الكود مطلوب',
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _discount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: _percentage ? 'نسبة الخصم' : 'خصم ثابت بالريال',
              ),
              validator: (value) {
                final amount = double.tryParse(value?.trim() ?? '');
                if (amount == null ||
                    amount <= 0 ||
                    (_percentage && amount > 100)) {
                  return _percentage
                      ? 'أدخل نسبة من 1 إلى 100'
                      : 'أدخل مبلغًا موجبًا';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('الخصم نسبة مئوية'),
              value: _percentage,
              onChanged: (value) => setState(() => _percentage = value),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('تاريخ الانتهاء'),
              subtitle: Text(_date(_expiry)),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: _pickDate,
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('إلغاء'),
      ),
      FilledButton(onPressed: _save, child: const Text('حفظ')),
    ],
  );
}

class _Pagination extends StatelessWidget {
  const _Pagination({
    required this.data,
    required this.isLoading,
    required this.onPage,
  });
  final AdminCouponsPageData data;
  final bool isLoading;
  final ValueChanged<int> onPage;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text('${data.totalCount} كوبونًا')),
      IconButton(
        onPressed: isLoading || data.pageNumber <= 1
            ? null
            : () => onPage(data.pageNumber - 1),
        icon: const Icon(Icons.chevron_right),
      ),
      Text('${data.pageNumber} / ${data.totalPages}'),
      IconButton(
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

String _discountLabel(AdminCoupon coupon) => coupon.isPercentage
    ? '${coupon.discount.toStringAsFixed(0)}% خصم'
    : '${coupon.discount.toStringAsFixed(0)} ر.س خصم';
String _date(DateTime? date) => date == null
    ? 'غير محدد'
    : '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
