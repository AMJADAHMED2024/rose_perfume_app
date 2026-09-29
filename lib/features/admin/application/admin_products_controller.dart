import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/admin_products_repository.dart';

class AdminProductsState {
  const AdminProductsState({
    this.isLoading = true,
    this.search = '',
    this.data,
    this.categories = const [],
    this.errorMessage,
  });
  final bool isLoading;
  final String search;
  final AdminProductsPageData? data;
  final List<AdminCategoryOption> categories;
  final String? errorMessage;
}

final adminProductsControllerProvider =
    StateNotifierProvider.autoDispose<
      AdminProductsController,
      AdminProductsState
    >(
      (ref) =>
          AdminProductsController(ref.watch(adminProductsRepositoryProvider)),
    );

class AdminProductsController extends StateNotifier<AdminProductsState> {
  AdminProductsController(this._repository)
    : super(const AdminProductsState()) {
    load();
  }
  final AdminProductsRepository _repository;

  Future<void> search(String value) =>
      _load(pageNumber: 1, search: value.trim());
  Future<void> goToPage(int pageNumber) =>
      _load(pageNumber: pageNumber, search: state.search);
  Future<void> load() =>
      _load(pageNumber: state.data?.pageNumber ?? 1, search: state.search);

  Future<void> save({
    AdminProduct? product,
    required AdminProductDraft draft,
  }) async {
    try {
      if (product == null) {
        await _repository.createProduct(draft);
      } else {
        await _repository.updateProduct(product.id, draft);
      }
      await load();
    } on DioException catch (error) {
      throw StateError(_apiMessage(error, fallback: 'تعذر حفظ المنتج.'));
    }
  }

  Future<void> delete(AdminProduct product) async {
    try {
      await _repository.deleteProduct(product.id);
      await load();
    } on DioException catch (error) {
      throw StateError(_apiMessage(error, fallback: 'تعذر حذف المنتج.'));
    }
  }

  Future<void> _load({required int pageNumber, required String search}) async {
    state = AdminProductsState(
      isLoading: true,
      search: search,
      data: state.data,
      categories: state.categories,
    );
    try {
      final result = await Future.wait<dynamic>([
        _repository.fetchProducts(pageNumber: pageNumber, search: search),
        state.categories.isEmpty
            ? _repository.fetchCategories()
            : Future<List<AdminCategoryOption>>.value(state.categories),
      ]);
      state = AdminProductsState(
        isLoading: false,
        search: search,
        data: result[0] as AdminProductsPageData,
        categories: result[1] as List<AdminCategoryOption>,
      );
    } on DioException catch (error) {
      state = AdminProductsState(
        isLoading: false,
        search: search,
        data: state.data,
        categories: state.categories,
        errorMessage: _apiMessage(error, fallback: 'تعذر تحميل المنتجات.'),
      );
    } catch (_) {
      state = AdminProductsState(
        isLoading: false,
        search: search,
        data: state.data,
        categories: state.categories,
        errorMessage: 'تعذر تحميل المنتجات الآن.',
      );
    }
  }
}

String _apiMessage(DioException error, {required String fallback}) {
  final body = error.response?.data;
  if (body is Map && body['message']?.toString().trim().isNotEmpty == true) {
    return body['message'].toString();
  }
  return error.response?.statusCode == 403
      ? 'لا تملك صلاحية إدارة المنتجات.'
      : fallback;
}
