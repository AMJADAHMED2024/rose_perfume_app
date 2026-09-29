import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../../../core/widgets/app_page_components.dart';
import '../../auth/application/auth_controller.dart';
import '../application/notifications_controller.dart';
import '../data/notifications_repository.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = AppCopy.of(context);
    if (!ref.watch(authControllerProvider).isSignedIn) {
      return Scaffold(
        appBar: AppBar(title: Text(copy.pair('الإشعارات', 'Notifications'))),
        body: Center(
          child: FilledButton(
            onPressed: () => context.go('/account'),
            child: Text(
              copy.pair(
                'سجّل الدخول لعرض الإشعارات',
                'Sign in to view notifications',
              ),
            ),
          ),
        ),
      );
    }
    final state = ref.watch(notificationsControllerProvider);
    final controller = ref.read(notificationsControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text(copy.pair('الإشعارات', 'Notifications'))),
      body: RefreshIndicator(
        onRefresh: controller.load,
        child: state.isLoading
            ? const SkeletonPage()
            : state.items.isEmpty && state.errorMessage != null
            ? _MessageState(
                message: state.errorMessage!,
                onRetry: controller.load,
              )
            : state.items.isEmpty
            ? const _EmptyState()
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(18),
                itemCount:
                    state.items.length +
                    1 +
                    (state.isShowingCachedData || state.errorMessage != null
                        ? 1
                        : 0),
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, index) {
                  if (index == 0) {
                    return AppPageHeader(
                      title: copy.pair('الإشعارات', 'Notifications'),
                      subtitle: copy.pair(
                        'كل جديد يخص طلباتك وحسابك.',
                        'Everything new about your orders and account.',
                      ),
                      icon: Icons.notifications_none_rounded,
                    );
                  }
                  final itemIndex = index - 1;
                  if (itemIndex == 0 &&
                      (state.isShowingCachedData ||
                          state.errorMessage != null)) {
                    return _CacheBanner(
                      text:
                          state.errorMessage ??
                          copy.pair(
                            'تعرض آخر نسخة محفوظة. اسحب للتحديث عند عودة الإنترنت.',
                            'Showing the latest saved version. Pull to refresh when you are back online.',
                          ),
                    );
                  }
                  final notificationIndex =
                      itemIndex -
                      (state.isShowingCachedData || state.errorMessage != null
                          ? 1
                          : 0);
                  return _NotificationCard(
                    item: state.items[notificationIndex],
                  );
                },
              ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});
  final StoreNotification item;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: const Icon(Icons.notifications_none),
      ),
      title: Text(
        item.title,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.description.isNotEmpty) Text(item.description),
            if (item.createdAt case final date?) ...[
              const SizedBox(height: 6),
              Text(
                '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);
    return AppEmptyState(
      icon: Icons.notifications_off_outlined,
      title: copy.pair('لا توجد إشعارات الآن', 'No notifications yet'),
      message: copy.pair(
        'سنضع هنا تحديثات الطلبات والعروض المهمة لك.',
        'Order updates and important offers will appear here.',
      ),
    );
  }
}

class _CacheBanner extends StatelessWidget {
  const _CacheBanner({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) =>
      AppFeedbackBanner(message: text, tone: AppBannerTone.warning);
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;
  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);
    return AppEmptyState(
      icon: Icons.cloud_off_outlined,
      title: copy.pair('تعذر تحميل الإشعارات', 'Could not load notifications'),
      message: message,
      actionLabel: copy.pair('إعادة المحاولة', 'Try again'),
      onAction: onRetry,
    );
  }
}
