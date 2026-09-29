import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/admin_variants_repository.dart';

class AdminVariantsState {
  const AdminVariantsState({
    this.loading = true,
    this.products = const [],
    this.selectedProductId,
    this.variants = const [],
    this.error,
  });
  final bool loading;
  final List<AdminVariantProduct> products;
  final int? selectedProductId;
  final List<AdminProductVariant> variants;
  final String? error;
}

final adminVariantsControllerProvider =
    StateNotifierProvider.autoDispose<
      AdminVariantsController,
      AdminVariantsState
    >(
      (ref) =>
          AdminVariantsController(ref.watch(adminVariantsRepositoryProvider)),
    );

class AdminVariantsController extends StateNotifier<AdminVariantsState> {
  AdminVariantsController(this._repository)
    : super(const AdminVariantsState()) {
    loadProducts();
  }
  final AdminVariantsRepository _repository;

  Future<void> loadProducts() async {
    try {
      final products = await _repository.products();
      state = AdminVariantsState(
        loading: false,
        products: products,
        selectedProductId: products.isEmpty ? null : products.first.id,
      );
      if (state.selectedProductId != null) {
        await selectProduct(state.selectedProductId!);
      }
    } catch (_) {
      state = const AdminVariantsState(
        loading: false,
        error: 'تعذر تحميل المنتجات.',
      );
    }
  }

  Future<void> selectProduct(int productId) async {
    state = AdminVariantsState(
      loading: true,
      products: state.products,
      selectedProductId: productId,
      variants: state.variants,
    );
    try {
      state = AdminVariantsState(
        loading: false,
        products: state.products,
        selectedProductId: productId,
        variants: await _repository.variants(productId),
      );
    } catch (_) {
      state = AdminVariantsState(
        loading: false,
        products: state.products,
        selectedProductId: productId,
        error: 'تعذر تحميل المتغيرات.',
      );
    }
  }

  Future<void> save({
    AdminProductVariant? variant,
    required AdminVariantDraft draft,
  }) async {
    final productId = state.selectedProductId;
    if (productId == null) return;
    if (variant == null) {
      await _repository.create(productId, draft);
    } else {
      await _repository.update(variant, draft);
    }
    await selectProduct(productId);
  }

  Future<void> delete(AdminProductVariant variant) async {
    await _repository.delete(variant);
    await selectProduct(variant.productId);
  }
}
