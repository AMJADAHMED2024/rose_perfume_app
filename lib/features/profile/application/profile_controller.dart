import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/security/secure_session_store.dart';
import '../../../core/security/session_identity.dart';
import '../../../core/sync/sync_queue.dart';
import '../data/profile_repository.dart';
import '../data/profile_sync_handler.dart';

class ProfileState {
  const ProfileState({
    this.isLoading = true,
    this.isSaving = false,
    this.profile,
    this.errorMessage,
  });
  final bool isLoading;
  final bool isSaving;
  final CustomerProfileData? profile;
  final String? errorMessage;

  ProfileState copyWith({
    bool? isLoading,
    bool? isSaving,
    CustomerProfileData? profile,
    String? errorMessage,
  }) => ProfileState(
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
    profile: profile ?? this.profile,
    errorMessage: errorMessage,
  );
}

final profileControllerProvider =
    StateNotifierProvider.autoDispose<ProfileController, ProfileState>(
      (ref) => ProfileController(
        ref.watch(profileRepositoryProvider),
        syncQueue: ref.watch(syncQueueProvider),
        sessionStore: ref.watch(sessionStoreProvider),
      ),
    );

class ProfileController extends StateNotifier<ProfileState> {
  ProfileController(this._repository, {this.syncQueue, this.sessionStore})
    : super(const ProfileState()) {
    load();
  }
  final ProfileRepository _repository;
  final SyncQueue? syncQueue;
  final SessionStore? sessionStore;
  bool lastSaveWasQueued = false;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      state = ProfileState(
        isLoading: false,
        profile: await _repository.fetch(),
      );
    } on DioException {
      state = const ProfileState(
        isLoading: false,
        errorMessage: 'تعذر تحميل بيانات الحساب. حاول مرة أخرى.',
      );
    }
  }

  Future<bool> save(CustomerProfileData profile) async {
    lastSaveWasQueued = false;
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      await _repository.update(profile);
      state = ProfileState(isSaving: false, profile: profile);
      return true;
    } on ProfileException catch (error) {
      state = state.copyWith(isSaving: false, errorMessage: error.message);
      return false;
    } on DioException {
      final activeSessionStore = sessionStore;
      final activeSyncQueue = syncQueue;
      final userId = activeSessionStore == null
          ? null
          : await SessionIdentity.userId(activeSessionStore);
      if (userId != null && activeSyncQueue != null) {
        await activeSyncQueue.enqueue(
          type: ProfileUpdateSyncHandler.operationType,
          payload: {'userId': userId, 'profile': profile.toJson()},
        );
        lastSaveWasQueued = true;
        state = ProfileState(isSaving: false, profile: profile);
        return true;
      }
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'تعذر حفظ التعديلات. تحقق من الاتصال.',
      );
      return false;
    }
  }
}
