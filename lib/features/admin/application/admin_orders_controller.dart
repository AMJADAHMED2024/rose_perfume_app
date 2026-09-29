import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/admin_orders_repository.dart';

class AdminOrdersState {
  const AdminOrdersState({
    this.isLoading = true,
    this.search = '',
    this.data,
    this.errorMessage,
  });

  final bool isLoading;
  final String search;
  final AdminOrdersPageData? data;
  final String? errorMessage;
}

final adminOrdersControllerProvider =
    StateNotifierProvider.autoDispose<AdminOrdersController, AdminOrdersState>(
      (ref) => AdminOrdersController(ref.watch(adminOrdersRepositoryProvider)),
    );

class AdminOrdersController extends StateNotifier<AdminOrdersState> {
  AdminOrdersController(this._repository) : super(const AdminOrdersState()) {
    load();
  }

  final AdminOrdersRepository _repository;

  Future<void> search(String value) =>
      _load(pageNumber: 1, search: value.trim());

  Future<void> goToPage(int pageNumber) =>
      _load(pageNumber: pageNumber, search: state.search);

  Future<void> load() =>
      _load(pageNumber: state.data?.pageNumber ?? 1, search: state.search);

  Future<void> _load({required int pageNumber, required String search}) async {
    state = AdminOrdersState(isLoading: true, search: search, data: state.data);
    try {
      final data = await _repository.fetchOrders(
        pageNumber: pageNumber,
        search: search,
      );
      state = AdminOrdersState(isLoading: false, search: search, data: data);
    } on DioException catch (error) {
      state = AdminOrdersState(
        isLoading: false,
        search: search,
        data: state.data,
        errorMessage: error.response?.statusCode == 403
            ? 'لا تملك صلاحية إدارة الطلبات.'
            : 'تعذر تحميل الطلبات. تحقق من الاتصال ثم أعد المحاولة.',
      );
    } catch (_) {
      state = AdminOrdersState(
        isLoading: false,
        search: search,
        data: state.data,
        errorMessage: 'تعذر تحميل الطلبات الآن.',
      );
    }
  }
}
