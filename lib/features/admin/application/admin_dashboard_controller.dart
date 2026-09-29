import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/admin_analytics_repository.dart';

class AdminDashboardState {
  const AdminDashboardState({
    this.rangeDays = 30,
    this.isLoading = true,
    this.dashboard,
    this.errorMessage,
  });

  final int rangeDays;
  final bool isLoading;
  final AdminDashboard? dashboard;
  final String? errorMessage;

  AdminDashboardState copyWith({
    int? rangeDays,
    bool? isLoading,
    AdminDashboard? dashboard,
    String? errorMessage,
  }) => AdminDashboardState(
    rangeDays: rangeDays ?? this.rangeDays,
    isLoading: isLoading ?? this.isLoading,
    dashboard: dashboard ?? this.dashboard,
    errorMessage: errorMessage,
  );
}

final adminDashboardControllerProvider =
    StateNotifierProvider.autoDispose<
      AdminDashboardController,
      AdminDashboardState
    >(
      (ref) =>
          AdminDashboardController(ref.watch(adminAnalyticsRepositoryProvider)),
    );

class AdminDashboardController extends StateNotifier<AdminDashboardState> {
  AdminDashboardController(this._repository)
    : super(const AdminDashboardState()) {
    load();
  }

  final AdminAnalyticsRepository _repository;

  Future<void> selectRange(int rangeDays) async {
    if (rangeDays == state.rangeDays && state.dashboard != null) return;
    state = AdminDashboardState(
      rangeDays: rangeDays,
      isLoading: true,
      dashboard: state.dashboard,
    );
    await load();
  }

  Future<void> load() async {
    state = AdminDashboardState(
      rangeDays: state.rangeDays,
      isLoading: true,
      dashboard: state.dashboard,
    );
    try {
      final dashboard = await _repository.fetchDashboard(
        rangeDays: state.rangeDays,
      );
      state = AdminDashboardState(
        rangeDays: state.rangeDays,
        isLoading: false,
        dashboard: dashboard,
      );
    } on DioException catch (error) {
      state = AdminDashboardState(
        rangeDays: state.rangeDays,
        isLoading: false,
        dashboard: state.dashboard,
        errorMessage: error.response?.statusCode == 403
            ? 'لا تملك صلاحية الوصول إلى لوحة التحكم.'
            : 'تعذر تحميل مؤشرات الإدارة. تحقق من الاتصال ثم أعد المحاولة.',
      );
    } catch (_) {
      state = AdminDashboardState(
        rangeDays: state.rangeDays,
        isLoading: false,
        dashboard: state.dashboard,
        errorMessage: 'تعذر تحميل مؤشرات الإدارة الآن.',
      );
    }
  }
}
