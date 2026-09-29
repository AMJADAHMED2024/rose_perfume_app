import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/widgets/app_skeleton.dart';
import '../../../core/widgets/app_page_components.dart';
import '../../../core/widgets/adaptive_layout.dart';
import '../data/branches_repository.dart';

class BranchesPage extends ConsumerWidget {
  const BranchesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branches = ref.watch(branchesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('فروعنا')),
      body: branches.when(
        loading: () => const SkeletonPage(),
        error: (_, _) => AppEmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'تعذر تحميل الفروع',
          message: 'تحقق من اتصالك ثم حاول مرة أخرى.',
          actionLabel: 'إعادة المحاولة',
          onAction: () => ref.invalidate(branchesProvider),
        ),
        data: (items) => items.isEmpty
            ? const AppEmptyState(
                icon: Icons.storefront_outlined,
                title: 'لا توجد فروع معلنة',
                message: 'سيتم عرض مواقع فروعنا هنا قريباً.',
              )
            : AdaptivePage(
                maxWidth: 900,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  itemCount: items.length + 1,
                  separatorBuilder: (_, index) =>
                      SizedBox(height: index == 0 ? 20 : 12),
                  itemBuilder: (context, index) => index == 0
                      ? const AppPageHeader(
                          title: 'فروعنا',
                          subtitle: 'زرنا واكتشف عالم روز برفيوم عن قرب.',
                          icon: Icons.storefront_outlined,
                        )
                      : _BranchCard(branch: items[index - 1]),
                ),
              ),
      ),
    );
  }
}

class _BranchCard extends StatelessWidget {
  const _BranchCard({required this.branch});
  final StoreBranch branch;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: .09),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.storefront_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  branch.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (branch.description.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(branch.description, style: const TextStyle(height: 1.6)),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (branch.phone.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: () => _open('tel:${branch.phone}'),
                  icon: const Icon(Icons.phone_outlined),
                  label: const Text('اتصال'),
                ),
              if (branch.latitude != 0 || branch.longitude != 0)
                FilledButton.icon(
                  onPressed: () => _open(
                    'https://www.google.com/maps/search/?api=1&query=${branch.latitude},${branch.longitude}',
                  ),
                  icon: const Icon(Icons.directions_outlined),
                  label: const Text('الاتجاهات'),
                ),
            ],
          ),
        ],
      ),
    ),
  );

  Future<void> _open(String target) =>
      launchUrl(Uri.parse(target), mode: LaunchMode.externalApplication);
}
