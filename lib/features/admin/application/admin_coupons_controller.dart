import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/admin_coupons_repository.dart';

class AdminCouponsState {
  const AdminCouponsState({
    this.isLoading = true,
    this.search = '',
    this.data,
    this.errorMessage,
  });
  final bool isLoading;
  final String search;
  final AdminCouponsPageData? data;
  final String? errorMessage;
}

final adminCouponsControllerProvider =
    StateNotifierProvider.autoDispose<
      AdminCouponsController,
      AdminCouponsState
    >(
      (ref) =>
          AdminCouponsController(ref.watch(adminCouponsRepositoryProvider)),
    );

class AdminCouponsController extends StateNotifier<AdminCouponsState> {
  AdminCouponsController(this._repository) : super(const AdminCouponsState()) {
    load();
  }
  final AdminCouponsRepository _repository;

  Future<void> search(String value) =>
      _load(pageNumber: 1, search: value.trim());
  Future<void> goToPage(int pageNumber) =>
      _load(pageNumber: pageNumber, search: state.search);
  Future<void> load() =>
      _load(pageNumber: state.data?.pageNumber ?? 1, search: state.search);

  Future<void> save({
    AdminCoupon? coupon,
    required AdminCouponDraft draft,
  }) async {
    try {
      if (coupon == null) {
        await _repository.createCoupon(draft);
      } else {
        await _repository.updateCoupon(coupon.id, draft);
      }
      await load();
    } on DioException catch (error) {
      throw StateError(_message(error, 'تعذر حفظ الكوبون.'));
    }
  }

  Future<void> delete(AdminCoupon coupon) async {
    try {
      await _repository.deleteCoupon(coupon.id);
      await load();
    } on DioException catch (error) {
      throw StateError(_message(error, 'تعذر حذف الكوبون.'));
    }
  }

  Future<void> _load({required int pageNumber, required String search}) async {
    state = AdminCouponsState(
      isLoading: true,
      search: search,
      data: state.data,
    );
    try {
      final data = await _repository.fetchCoupons(
        pageNumber: pageNumber,
        search: search,
      );
      state = AdminCouponsState(isLoading: false, search: search, data: data);
    } on DioException catch (error) {
      state = AdminCouponsState(
        isLoading: false,
        search: search,
        data: state.data,
        errorMessage: _message(error, 'تعذر تحميل الكوبونات.'),
      );
    } catch (_) {
      state = AdminCouponsState(
        isLoading: false,
        search: search,
        data: state.data,
        errorMessage: 'تعذر تحميل الكوبونات الآن.',
      );
    }
  }
}

String _message(DioException error, String fallback) {
  if (error.response?.statusCode == 403) {
    return 'لا تملك صلاحية إدارة الكوبونات.';
  }
  final body = error.response?.data;
  return body is Map && body['message']?.toString().trim().isNotEmpty == true
      ? body['message'].toString()
      : fallback;
}
