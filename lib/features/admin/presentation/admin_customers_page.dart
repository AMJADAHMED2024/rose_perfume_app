import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../data/admin_customers_repository.dart';
import 'admin_customer_editor.dart';

final adminCustomersProvider = FutureProvider.autoDispose
    .family<AdminCustomersPageData, ({int page, String search})>(
      (ref, query) => ref
          .watch(adminCustomersRepositoryProvider)
          .fetch(page: query.page, search: query.search),
    );

class AdminCustomersPage extends ConsumerStatefulWidget {
  const AdminCustomersPage({super.key});
  @override
  ConsumerState<AdminCustomersPage> createState() => _AdminCustomersPageState();
}

class _AdminCustomersPageState extends ConsumerState<AdminCustomersPage> {
  final search = TextEditingController();
  Timer? debounce;
  int page = 1;
  String value = '';
  @override
  void dispose() {
    debounce?.cancel();
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = (page: page, search: value);
    final async = ref.watch(adminCustomersProvider(query));
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة العملاء'),
        actions: [
          IconButton(
            onPressed: () => context.go('/admin'),
            icon: const Icon(Icons.dashboard_outlined),
          ),
          IconButton(
            onPressed: () => ref.invalidate(adminCustomersProvider(query)),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createCustomer,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('إضافة عميل'),
      ),
      body: async.when(
        loading: () => const SkeletonPage(),
        error: (_, _) => const Center(child: Text('تعذر تحميل العملاء.')),
        data: (data) => ListView(
          padding: const EdgeInsets.all(18),
          children: [
            TextField(
              controller: search,
              onChanged: (text) {
                debounce?.cancel();
                debounce = Timer(const Duration(milliseconds: 350), () {
                  setState(() {
                    value = text.trim();
                    page = 1;
                  });
                });
              },
              decoration: const InputDecoration(
                labelText: 'ابحث بالاسم أو البريد',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 14),
            if (data.items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(28),
                child: Center(child: Text('لا توجد نتائج.')),
              )
            else
              Card(
                child: Column(
                  children: data.items
                      .map(
                        (customer) => ListTile(
                          leading: CircleAvatar(child: Text('${customer.id}')),
                          title: Text(customer.name),
                          subtitle: Text(
                            '${customer.email}${customer.phone.isEmpty ? '' : ' · ${customer.phone}'}',
                          ),
                          trailing: Switch(
                            value: customer.status,
                            onChanged: (next) =>
                                _setStatus(context, customer, next),
                          ),
                          onTap: () =>
                              context.push('/admin/customers/${customer.id}'),
                        ),
                      )
                      .toList(),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Text('${data.total} عميل')),
                IconButton(
                  onPressed: page > 1 ? () => setState(() => page--) : null,
                  icon: const Icon(Icons.chevron_right),
                ),
                Text('$page / ${data.pages}'),
                IconButton(
                  onPressed: page < data.pages
                      ? () => setState(() => page++)
                      : null,
                  icon: const Icon(Icons.chevron_left),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setStatus(
    BuildContext context,
    AdminCustomer customer,
    bool active,
  ) async {
    try {
      await ref
          .read(adminCustomersRepositoryProvider)
          .setStatus(customer, active);
      ref.invalidate(adminCustomersProvider((page: page, search: value)));
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر تحديث حالة العميل.')),
        );
      }
    }
  }

  Future<void> _createCustomer() async {
    final draft = await showAdminCustomerEditor(context);
    if (draft == null) return;
    try {
      await ref.read(adminCustomersRepositoryProvider).create(draft);
      ref.invalidate(adminCustomersProvider((page: page, search: value)));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إنشاء حساب العميل بنجاح.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر إنشاء العميل. تأكد أن البريد غير مستخدم.'),
          ),
        );
      }
    }
  }
}
