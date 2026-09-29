import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_skeleton.dart';
import '../data/admin_inventory_repository.dart';

final adminInventoryProvider =
    FutureProvider.autoDispose<List<AdminInventoryTransaction>>(
      (ref) => ref.watch(adminInventoryRepositoryProvider).fetchTransactions(),
    );

class AdminInventoryPage extends ConsumerWidget {
  const AdminInventoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(adminInventoryProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('حركات المخزون'),
        actions: [
          IconButton(
            onPressed: () => context.go('/admin'),
            icon: const Icon(Icons.dashboard_outlined),
          ),
          IconButton(
            onPressed: () => ref.invalidate(adminInventoryProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: transactions.when(
        loading: () => const SkeletonPage(),
        error: (_, _) => Center(
          child: FilledButton(
            onPressed: () => ref.invalidate(adminInventoryProvider),
            child: const Text('إعادة المحاولة'),
          ),
        ),
        data: (items) => items.isEmpty
            ? const Center(child: Text('لا توجد حركات مخزون.'))
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(adminInventoryProvider),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(18),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final incoming = item.type == 1;
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(incoming ? Icons.add : Icons.remove),
                        ),
                        title: Text(item.productName),
                        subtitle: Text(
                          item.notes.isEmpty
                              ? _date(item.date)
                              : '${item.notes} · ${_date(item.date)}',
                        ),
                        trailing: Text(
                          '${incoming ? '+' : '-'}${item.quantity}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: incoming ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

String _date(DateTime? value) => value == null
    ? 'بدون تاريخ'
    : '${value.year}/${value.month.toString().padLeft(2, '0')}/${value.day.toString().padLeft(2, '0')}';
