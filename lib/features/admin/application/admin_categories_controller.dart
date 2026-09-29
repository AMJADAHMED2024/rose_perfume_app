import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/admin_categories_repository.dart';

class AdminCategoriesState {
  const AdminCategoriesState({
    this.isLoading = true,
    this.search = '',
    this.items = const [],
    this.errorMessage,
  });
  final bool isLoading;
  final String search;
  final List<AdminCategory> items;
  final String? errorMessage;
}

final adminCategoriesControllerProvider =
    StateNotifierProvider.autoDispose<
      AdminCategoriesController,
      AdminCategoriesState
    >(
      (ref) => AdminCategoriesController(
        ref.watch(adminCategoriesRepositoryProvider),
      ),
    );

class AdminCategoriesController extends StateNotifier<AdminCategoriesState> {
  AdminCategoriesController(this._repository)
    : super(const AdminCategoriesState()) {
    load();
  }
  final AdminCategoriesRepository _repository;

  Future<void> load() => _load(state.search);
  Future<void> search(String value) => _load(value.trim());

  Future<void> save({
    AdminCategory? category,
    required AdminCategoryDraft draft,
  }) async {
    try {
      if (category == null) {
        await _repository.create(draft);
      } else {
        await _repository.update(category.id, draft);
      }
      await load();
    } on DioException catch (error) {
      throw StateError(_error(error, 'تعذر حفظ القسم.'));
    }
  }

  Future<void> delete(AdminCategory category) async {
    try {
      await _repository.delete(category.id);
      await load();
    } on DioException catch (error) {
      throw StateError(_error(error, 'تعذر حذف القسم.'));
    }
  }

  Future<void> _load(String search) async {
    state = AdminCategoriesState(
      isLoading: true,
      search: search,
      items: state.items,
    );
    try {
      state = AdminCategoriesState(
        isLoading: false,
        search: search,
        items: await _repository.fetch(search: search),
      );
    } on DioException catch (error) {
      state = AdminCategoriesState(
        isLoading: false,
        search: search,
        items: state.items,
        errorMessage: _error(error, 'تعذر تحميل الأقسام.'),
      );
    } catch (_) {
      state = AdminCategoriesState(
        isLoading: false,
        search: search,
        items: state.items,
        errorMessage: 'تعذر تحميل الأقسام الآن.',
      );
    }
  }
}

String _error(DioException error, String fallback) {
  if (error.response?.statusCode == 403) return 'لا تملك صلاحية إدارة الأقسام.';
  final body = error.response?.data;
  return body is Map && body['message']?.toString().trim().isNotEmpty == true
      ? body['message'].toString()
      : fallback;
}
