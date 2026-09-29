import 'package:dio/dio.dart';

import '../../../core/security/secure_session_store.dart';
import '../../../core/security/session_identity.dart';
import '../../../core/sync/sync_coordinator.dart';
import 'profile_repository.dart';

/// Profile updates replace the same fields and can therefore safely retry.
class ProfileUpdateSyncHandler implements SyncOperationHandler {
  const ProfileUpdateSyncHandler(this._dio, this._sessionStore);

  static const operationType = 'profile.update';

  final Dio _dio;
  final SessionStore _sessionStore;

  @override
  String get type => operationType;

  @override
  Future<void> send(Map<String, dynamic> payload) async {
    final expectedUserId = _asInt(payload['userId']);
    final currentUserId = await SessionIdentity.userId(_sessionStore);
    if (expectedUserId == null || currentUserId != expectedUserId) {
      throw StateError('The saved profile update belongs to another session.');
    }

    final profile = payload['profile'];
    if (profile is! Map) {
      throw const ProfileException('بيانات الحساب المحفوظة غير صالحة.');
    }
    await ProfileRepository(
      _dio,
    ).updatePayload(Map<String, dynamic>.from(profile));
  }
}

int? _asInt(dynamic value) => value is int ? value : int.tryParse('$value');
