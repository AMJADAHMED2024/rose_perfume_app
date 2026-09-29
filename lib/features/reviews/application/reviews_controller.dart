import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/reviews_repository.dart';

class ReviewsState {
  const ReviewsState({
    this.isLoading = true,
    this.isSubmitting = false,
    this.items = const [],
    this.errorMessage,
  });
  final bool isLoading;
  final bool isSubmitting;
  final List<ProductReview> items;
  final String? errorMessage;

  ReviewsState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    List<ProductReview>? items,
    String? errorMessage,
  }) => ReviewsState(
    isLoading: isLoading ?? this.isLoading,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    items: items ?? this.items,
    errorMessage: errorMessage,
  );
}

final reviewsControllerProvider = StateNotifierProvider.autoDispose
    .family<ReviewsController, ReviewsState, int>(
      (ref, productId) =>
          ReviewsController(ref.watch(reviewsRepositoryProvider), productId),
    );

class ReviewsController extends StateNotifier<ReviewsState> {
  ReviewsController(this._repository, this._productId)
    : super(const ReviewsState()) {
    load();
  }
  final ReviewsRepository _repository;
  final int _productId;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      state = ReviewsState(
        isLoading: false,
        items: await _repository.fetch(_productId),
      );
    } on DioException {
      state = const ReviewsState(
        isLoading: false,
        errorMessage: 'تعذر تحميل التقييمات الآن.',
      );
    }
  }

  Future<bool> submit(int rating, String comment) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await _repository.create(
        productId: _productId,
        rating: rating,
        comment: comment,
      );
      await load();
      return true;
    } on ReviewException catch (error) {
      state = state.copyWith(isSubmitting: false, errorMessage: error.message);
      return false;
    } on DioException {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'تعذر إرسال التقييم. تحقق من الاتصال ثم حاول مجددًا.',
      );
      return false;
    }
  }
}
