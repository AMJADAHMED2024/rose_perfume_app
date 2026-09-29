import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_skeleton.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_controller.dart';
import '../application/reviews_controller.dart';
import '../data/reviews_repository.dart';

class ProductReviewsSection extends ConsumerWidget {
  const ProductReviewsSection({super.key, required this.productId});
  final int productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reviewsControllerProvider(productId));
    final controller = ref.read(reviewsControllerProvider(productId).notifier);
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'تقييمات العملاء',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: AppSkeleton(child: SkeletonBox(height: 110, radius: 18)),
            )
          else if (state.errorMessage != null && state.items.isEmpty)
            _RetryCard(message: state.errorMessage!, onRetry: controller.load)
          else ...[
            if (state.items.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text('لا توجد تقييمات بعد. كن أول من يشارك تجربته.'),
                ),
              )
            else
              for (final review in state.items) ...[
                _ReviewCard(review: review),
                const SizedBox(height: 10),
              ],
            const SizedBox(height: 8),
            ref.watch(authControllerProvider).isSignedIn
                ? _ReviewForm(controller: controller, state: state)
                : OutlinedButton.icon(
                    onPressed: () => context.go('/account'),
                    icon: const Icon(Icons.login),
                    label: const Text('سجّل الدخول لإضافة تقييم'),
                  ),
          ],
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});
  final ProductReview review;

  @override
  Widget build(BuildContext context) {
    final name = review.userName.trim();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(
                    name.isEmpty ? '?' : name.substring(0, 1).toUpperCase(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    review.userName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                _Stars(value: review.rating),
              ],
            ),
            if (review.comment.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(review.comment),
            ],
            if (review.createdAt case final date?) ...[
              const SizedBox(height: 8),
              Text(
                '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReviewForm extends StatefulWidget {
  const _ReviewForm({required this.controller, required this.state});
  final ReviewsController controller;
  final ReviewsState state;

  @override
  State<_ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<_ReviewForm> {
  final _comment = TextEditingController();
  var _rating = 5;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'أضف تقييمك',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          _Stars(
            value: _rating,
            interactive: (value) => setState(() => _rating = value),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _comment,
            minLines: 2,
            maxLines: 4,
            maxLength: 500,
            decoration: const InputDecoration(
              labelText: 'اكتب تجربتك (اختياري)',
              alignLabelWithHint: true,
            ),
          ),
          if (widget.state.errorMessage case final message?)
            Text(
              message,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: widget.state.isSubmitting ? null : _submit,
            child: Text(
              widget.state.isSubmitting ? 'جارٍ الإرسال...' : 'إرسال التقييم',
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _submit() async {
    final success = await widget.controller.submit(
      _rating,
      _comment.text.trim(),
    );
    if (success && mounted) {
      _comment.clear();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('شكرًا لمشاركتك تقييمك.')));
    }
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.value, this.interactive});
  final int value;
  final ValueChanged<int>? interactive;

  @override
  Widget build(BuildContext context) => Wrap(
    children: [
      for (var star = 1; star <= 5; star++)
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          onPressed: interactive == null ? null : () => interactive!(star),
          icon: Icon(
            star <= value ? Icons.star_rounded : Icons.star_border_rounded,
            color: const Color(0xFFD49A28),
          ),
        ),
    ],
  );
}

class _RetryCard extends StatelessWidget {
  const _RetryCard({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center),
          TextButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
        ],
      ),
    ),
  );
}
