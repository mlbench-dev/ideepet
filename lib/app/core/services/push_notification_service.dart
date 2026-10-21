import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:idee_pet/app/app.dart';

/// Registers the device FCM token on the backend and handles taps on push
/// notifications (e.g. lost pet alerts from neighbors).
class PushNotificationService {
  PushNotificationService._();

  static const String vapidKey =
      'BMdPxILTJPJslo3AdnjurIUKovagwIw6pmDzYev95euFUCAWL56J2n6benARyCeJCh-u6T6LbUvuOnjlOkX0tHw';

  static StreamSubscription<String>? _tokenRefreshSub;
  static bool _listenersAttached = false;

  /// Call once the user is logged in. Asks for notification permission,
  /// sends the current token to the backend and keeps it in sync.
  static Future<String?> syncToken() async {
    if (Firebase.apps.isEmpty) {
      debugPrint('@@@ FCM: Firebase is not initialized, skipping syncToken');
      return null;
    }

    try {
      final messaging = FirebaseMessaging.instance;

      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('@@@ FCM: Notification permission denied');
        return null;
      }

      // Show notification banners while the open (iOS).
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      _attachListeners();

      // Listen first so a token that arrives later is still sent.
      _tokenRefreshSub ??= messaging.onTokenRefresh.listen(_sendToken);

      // On iOS the FCM token needs the APNs token, which can arrive a few
      // seconds after launch.
      if (GetPlatform.isIOS && !await _waitForApnsToken(messaging)) {
        debugPrint('@@@ FCM: APNs token not available yet');
        return null;
      }

      final token = await messaging.getToken(
        vapidKey: kIsWeb ? vapidKey : null,
      );
      if (token != null) await _sendToken(token);
      return token;
    } catch (e) {
      // Push setup must never break the app.
      debugPrint('@@@ FCM sync failed: $e');
      return null;
    }
  }

  /// Call on logout so this device stops receiving the previous user's alerts.
  static Future<void> clearToken() async {
    if (Firebase.apps.isEmpty) return;
    try {
      await _tokenRefreshSub?.cancel();
      _tokenRefreshSub = null;
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      debugPrint('@@@ FCM delete token failed: $e');
    }
  }

  static Future<bool> _waitForApnsToken(FirebaseMessaging messaging) async {
    for (var i = 0; i < 10; i++) {
      if (await messaging.getAPNSToken() != null) return true;
      await Future.delayed(const Duration(seconds: 1));
    }
    return false;
  }

  static Future<void> _sendToken(String token) async {
    if (kDebugMode) debugPrint('@@@ FCM token: $token');
    try {
      final userRepository = Get.isRegistered<UserRepository>()
          ? Get.find<UserRepository>()
          : Get.put(UserRepository());
      final res = await userRepository.updateFcmToken(token);
      if (kDebugMode) {
        debugPrint('@@@ FCM token synced to backend: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('@@@ Failed to send FCM token to backend: $e');
    }
  }

  static void _attachListeners() {
    if (_listenersAttached) return;
    _listenersAttached = true;

    // Android does not show a banner while the app is in the foreground.
    FirebaseMessaging.onMessage.listen((message) {
      if (GetPlatform.isIOS) return;
      final notification = message.notification;
      if (notification == null) return;
      Get.snackbar(
        notification.title ?? 'Notificação',
        notification.body ?? '',
        duration: const Duration(seconds: 6),
        onTap: (_) => _openNotification(message),
      );
    });

    // App in background and the user taps the notification.
    FirebaseMessaging.onMessageOpenedApp.listen(_openNotification);

    // App was closed and opened by tapping the notification.
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) _openNotification(message);
    });
  }

  static void _openNotification(RemoteMessage message) {
    if (message.data['type'] == 'lost_pet') {
      Get.toNamed(NotificationsRoutes.notifications);
    }
  }
}
