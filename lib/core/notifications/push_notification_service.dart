import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import 'web_notification_presenter.dart';

const _webVapidKey = String.fromEnvironment('FIREBASE_WEB_VAPID_KEY');

const _androidChannel = AndroidNotificationChannel(
  'rose_perfume_orders',
  'طلبات روز برفيوم',
  description: 'تنبيهات الطلبات والعروض من روز برفيوم',
  importance: Importance.high,
);

final pushNotificationServiceProvider = Provider<PushNotificationService>(
  (ref) => PushNotificationService(ref.watch(dioProvider)),
);

class PushNotificationService {
  PushNotificationService(this._dio);

  final Dio _dio;
  FirebaseMessaging? _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  bool _started = false;

  bool get _isSupportedMobilePlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  bool get _isSupportedPlatform => kIsWeb || _isSupportedMobilePlatform;

  Future<void> start() async {
    if (_started || !_isSupportedPlatform || Firebase.apps.isEmpty) {
      return;
    }
    _started = true;
    _messaging = FirebaseMessaging.instance;

    if (_isSupportedMobilePlatform) {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const settings = InitializationSettings(android: androidSettings);
      await _localNotifications.initialize(settings);
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.createNotificationChannel(_androidChannel);
    }

    _foregroundMessageSubscription = FirebaseMessaging.onMessage.listen(
      _showForegroundNotification,
    );
    _tokenRefreshSubscription = _messaging!.onTokenRefresh.listen((token) {
      unawaited(_registerToken(token));
    });
  }

  Future<void> requestPermissionAndRegister() async {
    if (!_isSupportedPlatform || Firebase.apps.isEmpty) return;
    await start();

    final settings = await _messaging!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    if (_isSupportedMobilePlatform) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await androidPlugin?.requestNotificationsPermission();
      if (granted == false) return;
    }

    if (kIsWeb && _webVapidKey.isEmpty) return;
    final token = kIsWeb
        ? await _messaging!.getToken(vapidKey: _webVapidKey)
        : await _messaging!.getToken();
    if (token != null) await _registerToken(token);
  }

  Future<void> _registerToken(String token) async {
    try {
      await _dio.put<void>(
        '/api/Notification/device-token',
        data: {'token': token, 'platform': _platformName},
      );
    } on DioException {
      // The next token refresh or signed-in app start retries registration.
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    if (kIsWeb) {
      await showWebNotification(
        notification.title ?? 'روز برفيوم',
        notification.body,
      );
      return;
    }

    await _localNotifications.show(
      message.hashCode,
      notification.title ?? 'روز برفيوم',
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'rose_perfume_orders',
          'طلبات روز برفيوم',
          channelDescription: 'تنبيهات الطلبات والعروض من روز برفيوم',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  void dispose() {
    _tokenRefreshSubscription?.cancel();
    _foregroundMessageSubscription?.cancel();
  }

  String get _platformName => kIsWeb
      ? 'web'
      : defaultTargetPlatform == TargetPlatform.iOS
      ? 'ios'
      : 'android';
}
