import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/notifications_repository.dart';

class NotificationsState {
  const NotificationsState({
    this.isLoading = true,
    this.isShowingCachedData = false,
    this.items = const [],
    this.errorMessage,
  });
  final bool isLoading;
  final bool isShowingCachedData;
  final List<StoreNotification> items;
  final String? errorMessage;
}

final notificationsControllerProvider =
    StateNotifierProvider.autoDispose<
      NotificationsController,
      NotificationsState
    >(
      (ref) =>
          NotificationsController(ref.watch(notificationsRepositoryProvider)),
    );

class NotificationsController extends StateNotifier<NotificationsState> {
  NotificationsController(this._repository)
    : super(const NotificationsState()) {
    load();
  }
  final NotificationsRepository _repository;

  Future<void> load() async {
    state = const NotificationsState();
    final cached = await _repository.readCached();
    if (cached != null) {
      state = NotificationsState(
        isLoading: false,
        isShowingCachedData: true,
        items: cached,
      );
    }
    try {
      state = NotificationsState(
        isLoading: false,
        isShowingCachedData: false,
        items: await _repository.fetchMine(),
      );
    } on DioException catch (error) {
      state = NotificationsState(
        isLoading: false,
        isShowingCachedData: cached != null,
        items: cached ?? const [],
        errorMessage: error.response?.statusCode == 401
            ? 'انتهت الجلسة. سجّل الدخول مرة أخرى.'
            : 'تعذر تحميل الإشعارات. تحقق من الاتصال ثم أعد المحاولة.',
      );
    } catch (_) {
      state = NotificationsState(
        isLoading: false,
        isShowingCachedData: cached != null,
        items: cached ?? const [],
        errorMessage: 'تعذر تحميل الإشعارات الآن.',
      );
    }
  }
}
