import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/admin_analytics_repository.dart';

class AdminReportsState {
  const AdminReportsState({
    required this.from,
    required this.to,
    this.isLoading = true,
    this.dashboard,
    this.errorMessage,
  });

  final DateTime from;
  final DateTime to;
  final bool isLoading;
  final AdminDashboard? dashboard;
  final String? errorMessage;

  AdminReportsState copyWith({
    DateTime? from,
    DateTime? to,
    bool? isLoading,
    AdminDashboard? dashboard,
    String? errorMessage,
  }) => AdminReportsState(
    from: from ?? this.from,
    to: to ?? this.to,
    isLoading: isLoading ?? this.isLoading,
    dashboard: dashboard ?? this.dashboard,
    errorMessage: errorMessage,
  );
}

final adminReportsControllerProvider =
    StateNotifierProvider.autoDispose<
      AdminReportsController,
      AdminReportsState
    >(
      (ref) =>
          AdminReportsController(ref.watch(adminAnalyticsRepositoryProvider)),
    );

class AdminReportsController extends StateNotifier<AdminReportsState> {
  AdminReportsController(this._repository) : super(_initialState()) {
    load();
  }

  final AdminAnalyticsRepository _repository;

  static AdminReportsState _initialState() {
    final to = DateUtils.dateOnly(DateTime.now());
    return AdminReportsState(
      from: to.subtract(const Duration(days: 29)),
      to: to,
    );
  }

  Future<void> selectPreset(int days) async {
    final to = DateUtils.dateOnly(DateTime.now());
    final from = to.subtract(Duration(days: days - 1));
    state = AdminReportsState(
      from: from,
      to: to,
      isLoading: true,
      dashboard: state.dashboard,
    );
    await load();
  }

  Future<void> selectRange(DateTime from, DateTime to) async {
    if (to.isBefore(from)) return;
    state = AdminReportsState(
      from: DateUtils.dateOnly(from),
      to: DateUtils.dateOnly(to),
      isLoading: true,
      dashboard: state.dashboard,
    );
    await load();
  }

  Future<void> load() async {
    state = AdminReportsState(
      from: state.from,
      to: state.to,
      isLoading: true,
      dashboard: state.dashboard,
    );
    try {
      final dashboard = await _repository.fetchReport(
        from: state.from,
        to: state.to,
      );
      state = AdminReportsState(
        from: state.from,
        to: state.to,
        isLoading: false,
        dashboard: dashboard,
      );
    } on DioException catch (error) {
      state = AdminReportsState(
        from: state.from,
        to: state.to,
        isLoading: false,
        dashboard: state.dashboard,
        errorMessage: error.response?.statusCode == 403
            ? 'لا تملك صلاحية الوصول إلى التقارير.'
            : 'تعذر تحميل التقرير. تحقق من الاتصال ثم أعد المحاولة.',
      );
    } catch (_) {
      state = AdminReportsState(
        from: state.from,
        to: state.to,
        isLoading: false,
        dashboard: state.dashboard,
        errorMessage: 'تعذر تحميل التقرير الآن.',
      );
    }
  }
}
