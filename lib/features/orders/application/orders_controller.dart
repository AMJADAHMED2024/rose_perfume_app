import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/orders_repository.dart';

class OrdersState {
  const OrdersState({
    this.isLoading = true,
    this.isShowingCachedData = false,
    this.orders = const [],
    this.errorMessage,
  });
  final bool isLoading;
  final bool isShowingCachedData;
  final List<CustomerOrder> orders;
  final String? errorMessage;

  OrdersState copyWith({
    bool? isLoading,
    bool? isShowingCachedData,
    List<CustomerOrder>? orders,
    String? errorMessage,
  }) => OrdersState(
    isLoading: isLoading ?? this.isLoading,
    isShowingCachedData: isShowingCachedData ?? this.isShowingCachedData,
    orders: orders ?? this.orders,
    errorMessage: errorMessage,
  );
}

final ordersControllerProvider =
    StateNotifierProvider.autoDispose<OrdersController, OrdersState>(
      (ref) => OrdersController(ref.watch(ordersRepositoryProvider)),
    );

class OrdersController extends StateNotifier<OrdersState> {
  OrdersController(this._repository) : super(const OrdersState()) {
    load();
  }
  final OrdersRepository _repository;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final cached = await _repository.readCached();
    if (cached != null) {
      state = OrdersState(
        isLoading: false,
        isShowingCachedData: true,
        orders: cached,
      );
    }
    try {
      state = OrdersState(
        isLoading: false,
        isShowingCachedData: false,
        orders: await _repository.fetchMyOrders(),
      );
    } on DioException catch (error) {
      state = OrdersState(
        isLoading: false,
        isShowingCachedData: cached != null,
        orders: cached ?? const [],
        errorMessage: error.response?.statusCode == 401
            ? 'انتهت الجلسة. سجّل الدخول مرة أخرى.'
            : 'تعذر تحميل طلباتك. تحقق من الاتصال ثم أعد المحاولة.',
      );
    } catch (_) {
      state = OrdersState(
        isLoading: false,
        isShowingCachedData: cached != null,
        orders: cached ?? const [],
        errorMessage: 'تعذر تحميل طلباتك الآن.',
      );
    }
  }
}
