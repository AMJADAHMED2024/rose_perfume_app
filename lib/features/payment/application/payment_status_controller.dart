import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/payment_status_repository.dart';

class PaymentStatusState {
  const PaymentStatusState({
    this.isLoading = true,
    this.isRefreshing = false,
    this.session,
    this.errorMessage,
  });

  final bool isLoading;
  final bool isRefreshing;
  final PaymentSessionRecord? session;
  final String? errorMessage;

  PaymentStatusState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    PaymentSessionRecord? session,
    String? errorMessage,
  }) => PaymentStatusState(
    isLoading: isLoading ?? this.isLoading,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    session: session ?? this.session,
    errorMessage: errorMessage,
  );
}

final paymentStatusControllerProvider = StateNotifierProvider.autoDispose
    .family<PaymentStatusController, PaymentStatusState, String?>((
      ref,
      invoiceId,
    ) {
      return PaymentStatusController(
        ref.watch(paymentStatusRepositoryProvider),
        invoiceId,
      );
    });

class PaymentStatusController extends StateNotifier<PaymentStatusState> {
  PaymentStatusController(this._repository, this._invoiceId)
    : super(const PaymentStatusState()) {
    load();
  }

  final PaymentStatusRepository _repository;
  final String? _invoiceId;
  Timer? _poller;

  Future<void> load() async {
    _poller?.cancel();
    state = const PaymentStatusState();
    final invoiceId = _invoiceId;
    final session = invoiceId == null || invoiceId.isEmpty
        ? await _repository.latest()
        : await _repository.byInvoiceId(invoiceId);
    if (session == null) {
      state = const PaymentStatusState(
        isLoading: false,
        errorMessage: 'لا توجد عملية دفع محفوظة لمتابعتها.',
      );
      return;
    }
    state = PaymentStatusState(isLoading: false, session: session);
    await refresh();
  }

  Future<void> refresh() async {
    final session = state.session;
    if (session == null || state.isRefreshing) return;
    state = state.copyWith(isRefreshing: true, errorMessage: null);
    try {
      final updated = await _repository.refresh(session);
      state = PaymentStatusState(session: updated);
      if (!_isFinal(updated.invoiceStatus)) _startPolling();
    } on DioException {
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: 'تعذر تحديث حالة الدفع. تحقق من الاتصال ثم حاول مجددًا.',
      );
    } catch (_) {
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: 'تعذر قراءة حالة الدفع الآن.',
      );
    }
  }

  void _startPolling() {
    _poller ??= Timer.periodic(const Duration(seconds: 12), (_) => refresh());
  }

  bool _isFinal(String? status) {
    final value = status?.toLowerCase() ?? '';
    return value.contains('paid') ||
        value.contains('cancel') ||
        value.contains('fail') ||
        value.contains('expire');
  }

  @override
  void dispose() {
    _poller?.cancel();
    super.dispose();
  }
}
