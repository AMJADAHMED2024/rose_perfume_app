import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_skeleton.dart';
import '../data/admin_settings_repository.dart';

final _newArrivalsSettingsProvider =
    FutureProvider.autoDispose<NewArrivalsSettings>(
      (ref) => ref.watch(adminSettingsRepositoryProvider).fetchNewArrivals(),
    );

class AdminSettingsPage extends ConsumerStatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  ConsumerState<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends ConsumerState<AdminSettingsPage> {
  bool? _enabled;
  double? _count;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(_newArrivalsSettingsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات المتجر'),
        actions: [
          IconButton(
            onPressed: () => context.go('/admin'),
            icon: const Icon(Icons.dashboard_outlined),
          ),
        ],
      ),
      body: settings.when(
        loading: () => const SkeletonPage(layout: SkeletonLayout.form),
        error: (_, _) => Center(
          child: FilledButton(
            onPressed: () => ref.invalidate(_newArrivalsSettingsProvider),
            child: const Text('إعادة المحاولة'),
          ),
        ),
        data: (value) {
          final enabled = _enabled ?? value.enabled;
          final count = _count ?? value.productCount.toDouble();
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.new_releases_outlined),
                          SizedBox(width: 10),
                          Text(
                            'قسم وصل حديثًا',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'يُستخدم هذا الإعداد في تطبيق Flutter والواجهة المرجعية عبر نفس الخادم.',
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('إظهار القسم في الرئيسية'),
                        value: enabled,
                        onChanged: _saving
                            ? null
                            : (next) => setState(() => _enabled = next),
                      ),
                      const SizedBox(height: 8),
                      Text('عدد المنتجات: ${count.round()}'),
                      Slider(
                        min: 1,
                        max: 12,
                        divisions: 11,
                        label: '${count.round()}',
                        value: count,
                        onChanged: _saving
                            ? null
                            : (next) => setState(() => _count = next),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: FilledButton.icon(
                          onPressed: _saving
                              ? null
                              : () => _save(enabled, count.round()),
                          icon: _saving
                              ? const SkeletonInline()
                              : const Icon(Icons.save_outlined),
                          label: Text(_saving ? 'جارٍ الحفظ' : 'حفظ الإعداد'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'إعدادات وسائل الدفع والشحن تحتاج عقد API وإدارة بيانات حقيقية في الخلفية. لم يتم نسخ بطاقات React التجريبية لأنها لا تحفظ أي إعداد فعلي.',
                    style: TextStyle(height: 1.6),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _save(bool enabled, int count) async {
    setState(() => _saving = true);
    try {
      await ref
          .read(adminSettingsRepositoryProvider)
          .saveNewArrivals(
            NewArrivalsSettings(enabled: enabled, productCount: count),
          );
      ref.invalidate(_newArrivalsSettingsProvider);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم حفظ إعدادات المتجر.')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تعذر حفظ الإعدادات.')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
