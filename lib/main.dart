import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/network/api_client.dart';
import 'core/notifications/firebase_web_options.dart';
import 'core/security/secure_session_store.dart';
import 'core/sync/sync_coordinator.dart';
import 'features/profile/data/profile_sync_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Android/iOS use their native Firebase config files. The browser uses the
  // Firebase Web App configuration registered for rose-perfume.firebaseapp.com.
  if (kIsWeb) {
    await Firebase.initializeApp(options: rosePerfumeWebFirebaseOptions);
  } else if ((defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS)) {
    try {
      await Firebase.initializeApp();
    } on FirebaseException {
      // Push is unavailable until the Firebase native config files are added.
    }
  }
  runApp(
    ProviderScope(
      overrides: [
        syncOperationHandlersProvider.overrideWith(
          (ref) => [
            ProfileUpdateSyncHandler(
              ref.watch(dioProvider),
              ref.watch(sessionStoreProvider),
            ),
          ],
        ),
      ],
      child: const RosePerfumeApp(),
    ),
  );
}
