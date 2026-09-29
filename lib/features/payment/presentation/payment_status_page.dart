import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../../../core/widgets/app_page_components.dart';
import '../application/payment_status_controller.dart';
import '../data/payment_status_repository.dart';

class PaymentStatusPage extends ConsumerWidget {
  const PaymentStatusPage({super.key, this.invoiceId});
  final String? invoiceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = AppCopy.of(context);
    final state = ref.watch(paymentStatusControllerProvider(invoiceId));
    final controller = ref.read(
      paymentStatusControllerProvider(invoiceId).notifier,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(copy.pair('متابعة الدفع والشحنة', 'Payment & shipment')),
        actions: [
          IconButton(
            tooltip: copy.pair('تحديث الحالة', 'Refresh status'),
            onPressed: state.isRefreshing ? null : controller.refresh,
            icon: state.isRefreshing
                ? const SkeletonInline(size: 20)
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: state.isLoading
          ? const SkeletonPage(layout: SkeletonLayout.details)
          : _PaymentContent(
              session: state.session,
              errorMessage: state.errorMessage,
              onRefresh: controller.refresh,
            ),
    );
  }
}

class _PaymentContent extends StatelessWidget {
  const _PaymentContent({
    required this.session,
    required this.errorMessage,
    required this.onRefresh,
  });
  final PaymentSessionRecord? session;
  final String? errorMessage;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);
    if (session == null) {
      return AppEmptyState(
        icon: Icons.receipt_long_outlined,
        title: copy.pair('لا توجد عملية دفع للمتابعة', 'No payment to track'),
        message:
            errorMessage ??
            copy.pair(
              'ستظهر تفاصيل الدفع أو الشحنة هنا بعد إنشاء الطلب.',
              'Payment or shipment details will appear here after an order is created.',
            ),
        actionLabel: copy.pair('تحديث الآن', 'Refresh now'),
        onAction: onRefresh,
      );
    }
    final paid = _isPaid(session!.invoiceStatus);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppPageHeader(
                title: paid
                    ? copy.pair('تم تأكيد الدفع', 'Payment confirmed')
                    : copy.pair('متابعة الدفع', 'Track payment'),
                subtitle: paid
                    ? copy.pair(
                        'يتم الآن تجهيز طلبك للشحن.',
                        'Your order is being prepared for shipment.',
                      )
                    : copy.pair(
                        'راجع الحالة وأكمل الدفع عند الحاجة.',
                        'Review the status and complete payment if needed.',
                      ),
                icon: paid ? Icons.verified_outlined : Icons.pending_outlined,
              ),
              const SizedBox(height: 22),
              AppSectionCard(
                title: copy.pair('تفاصيل العملية', 'Payment details'),
                icon: Icons.receipt_long_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      paid
                          ? Icons.check_circle_outline
                          : Icons.pending_outlined,
                      size: 62,
                      color: paid
                          ? Colors.green.shade700
                          : Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      paid
                          ? copy.pair('تم تأكيد الدفع', 'Payment confirmed')
                          : copy.pair(
                              'بانتظار تأكيد الدفع',
                              'Awaiting payment confirmation',
                            ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      paid
                          ? copy.pair(
                              'سنبدأ تجهيز الشحنة، ويمكنك مراجعة بياناتها هنا.',
                              'We will begin preparing your shipment; you can review its details here.',
                            )
                          : copy.pair(
                              'أكمل الدفع في البوابة ثم عد لهذه الشاشة. يتم التحديث تلقائيًا أثناء فتحها.',
                              'Complete payment in the gateway, then return here. The page refreshes automatically while open.',
                            ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 22),
                    _InfoRow(
                      label: copy.pair('رقم الطلب', 'Order number'),
                      value: '#${session!.orderId}',
                    ),
                    _InfoRow(
                      label: copy.pair('رقم الفاتورة', 'Invoice number'),
                      value: session!.invoiceId,
                    ),
                    _InfoRow(
                      label: copy.pair('حالة الدفع', 'Payment status'),
                      value: session!.invoiceStatus?.isNotEmpty == true
                          ? session!.invoiceStatus!
                          : copy.pair('قيد التحقق', 'Verifying'),
                    ),
                    if (session!.shipmentId?.isNotEmpty == true)
                      _InfoRow(
                        label: copy.pair('رقم الشحنة', 'Shipment number'),
                        value: session!.shipmentId!,
                      ),
                    if (errorMessage case final message?) ...[
                      const SizedBox(height: 14),
                      AppFeedbackBanner(
                        message: message,
                        tone: AppBannerTone.error,
                      ),
                    ],
                    const SizedBox(height: 22),
                    if (!paid && session!.invoiceUrl?.isNotEmpty == true)
                      FilledButton.icon(
                        onPressed: () =>
                            _openUrl(context, session!.invoiceUrl!),
                        icon: const Icon(Icons.open_in_new),
                        label: Text(
                          copy.pair('فتح بوابة الدفع', 'Open payment gateway'),
                        ),
                      ),
                    if (paid && session!.labelUrl?.isNotEmpty == true) ...[
                      FilledButton.icon(
                        onPressed: () => _openUrl(context, session!.labelUrl!),
                        icon: const Icon(Icons.local_shipping_outlined),
                        label: Text(
                          copy.pair(
                            'فتح تفاصيل الشحنة',
                            'Open shipment details',
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    OutlinedButton.icon(
                      onPressed: onRefresh,
                      icon: const Icon(Icons.refresh),
                      label: Text(copy.pair('تحديث الآن', 'Refresh now')),
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

  static bool _isPaid(String? status) =>
      (status ?? '').toLowerCase().contains('paid');

  Future<void> _openUrl(BuildContext context, String rawUrl) async {
    final copy = AppCopy.of(context);
    final opened = await launchUrl(
      Uri.parse(rawUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            copy.pair(
              'تعذر فتح الرابط على هذا الجهاز.',
              'Could not open this link on this device.',
            ),
          ),
        ),
      );
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const Spacer(),
        Flexible(child: Text(value, textAlign: TextAlign.end)),
      ],
    ),
  );
}
