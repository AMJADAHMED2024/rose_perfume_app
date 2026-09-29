import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_skeleton.dart';
import '../data/admin_notifications_repository.dart';

final adminNotificationsProvider =
    FutureProvider.autoDispose<List<AdminNotification>>(
      (ref) => ref.watch(adminNotificationsRepositoryProvider).fetch(),
    );

class AdminNotificationsPage extends ConsumerWidget {
  const AdminNotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(adminNotificationsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('إشعارات الإدارة'),
        actions: [
          IconButton(
            onPressed: () => context.go('/admin'),
            icon: const Icon(Icons.dashboard_outlined),
          ),
          IconButton(
            onPressed: () => ref.invalidate(adminNotificationsProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _send(context, ref),
        icon: const Icon(Icons.send_outlined),
        label: const Text('إرسال إشعار'),
      ),
      body: notifications.when(
        loading: () => const SkeletonPage(),
        error: (_, _) => const Center(child: Text('تعذر تحميل الإشعارات.')),
        data: (items) => items.isEmpty
            ? const Center(child: Text('لا توجد إشعارات.'))
            : ListView.builder(
                padding: const EdgeInsets.all(18),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.notifications_outlined),
                      title: Text(item.title),
                      subtitle: Text(
                        '${item.description}${item.userId == 0 ? ' · للجميع' : ' · العميل #${item.userId}'}',
                      ),
                      trailing: IconButton(
                        onPressed: () => _delete(context, ref, item),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _send(BuildContext context, WidgetRef ref) async {
    final draft = await showDialog<_NotificationDraft>(
      context: context,
      builder: (_) => const _SendDialog(),
    );
    if (draft == null) return;
    try {
      await ref
          .read(adminNotificationsRepositoryProvider)
          .send(
            title: draft.title,
            description: draft.description,
            userId: draft.userId,
          );
      ref.invalidate(adminNotificationsProvider);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تعذر إرسال الإشعار.')));
      }
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    AdminNotification notification,
  ) async {
    try {
      await ref
          .read(adminNotificationsRepositoryProvider)
          .delete(notification.id);
      ref.invalidate(adminNotificationsProvider);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تعذر حذف الإشعار.')));
      }
    }
  }
}

class _NotificationDraft {
  const _NotificationDraft({
    required this.title,
    required this.description,
    this.userId,
  });
  final String title;
  final String description;
  final int? userId;
}

class _SendDialog extends StatefulWidget {
  const _SendDialog();
  @override
  State<_SendDialog> createState() => _SendDialogState();
}

class _SendDialogState extends State<_SendDialog> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _customer = TextEditingController();
  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _customer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('إرسال إشعار'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _title,
          decoration: const InputDecoration(labelText: 'العنوان'),
        ),
        TextField(
          controller: _description,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'الرسالة'),
        ),
        TextField(
          controller: _customer,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'رقم العميل — اتركه فارغًا للإرسال للجميع',
          ),
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
            _NotificationDraft(
              title: _title.text.trim(),
              description: _description.text.trim(),
              userId: int.tryParse(_customer.text.trim()),
            ),
          );
        },
        child: const Text('إرسال'),
      ),
    ],
  );
}
