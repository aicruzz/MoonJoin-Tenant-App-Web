import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/widgets/custom_snackbar.dart';
import 'package:moonjoin_cloud/features/notifications/controllers/notifications_controller.dart';
import 'package:moonjoin_cloud/features/notifications/domain/repositories/fcm_token_repository_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moonjoin_cloud/util/app_constants.dart';

/// Thin wrapper around `firebase_messaging` that:
/// - requests permission + fetches the current token,
/// - registers the token with the Laravel backend (`POST /fcm-token`),
/// - re-registers on `onTokenRefresh`,
/// - refreshes the in-app notifications list on `onMessage`,
/// - unregisters the last-known token on logout.
///
/// Every operation is guarded by `Firebase.apps.isNotEmpty` and try/catch so
/// it's a complete no-op when Firebase configs aren't deployed yet. Web is
/// also a no-op unless `firebase_messaging_web` has been initialized with a
/// VAPID key — that's a Phase H deploy concern.
class PushService extends GetxService {
  final FcmTokenRepositoryInterface fcmTokenRepo;
  final SharedPreferences prefs;
  PushService({required this.fcmTokenRepo, required this.prefs});

  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _messageSub;
  bool _initialized = false;

  /// Returns true if Firebase + messaging look usable in this runtime.
  bool get _firebaseReady => Firebase.apps.isNotEmpty;

  /// Called by `AuthController.login*` after a successful sign-in.
  /// Idempotent: safe to call multiple times.
  Future<void> register() async {
    if (_initialized) return;
    if (!_firebaseReady) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('PushService.register skipped — Firebase not initialized.');
      }
      return;
    }
    try {
      final messaging = FirebaseMessaging.instance;
      // Permission is benign on Android; iOS / web actually surface a prompt.
      await messaging.requestPermission(alert: true, badge: true, sound: true);
      final token = await messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await _sendToBackend(token);
      }

      _tokenRefreshSub ??= messaging.onTokenRefresh.listen((newToken) {
        // ignore: discarded_futures
        _sendToBackend(newToken);
      });

      _messageSub ??= FirebaseMessaging.onMessage.listen(_onForegroundMessage);

      _initialized = true;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('PushService.register failed: $e');
      }
    }
  }

  /// Called by `AuthController.logout()`.
  Future<void> unregister() async {
    final lastToken = prefs.getString(AppConstants.fcmToken);
    if (lastToken != null && lastToken.isNotEmpty) {
      try {
        await fcmTokenRepo.unregister(lastToken);
      } catch (_) {
        // Logout shouldn't fail the user flow on push cleanup errors.
      }
      await prefs.remove(AppConstants.fcmToken);
    }
    await _tokenRefreshSub?.cancel();
    await _messageSub?.cancel();
    _tokenRefreshSub = null;
    _messageSub = null;
    _initialized = false;
  }

  Future<void> _sendToBackend(String token) async {
    final platform = _detectPlatform();
    try {
      final response = await fcmTokenRepo.register(
        token: token,
        platform: platform,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await prefs.setString(AppConstants.fcmToken, token);
      } else if (kDebugMode) {
        // ignore: avoid_print
        print('PushService: backend rejected token (${response.statusCode}).');
      }
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('PushService: token register failed: $e');
      }
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    // Re-pull the merchant's notifications list so the new row is visible
    // even before the merchant opens the screen — keeps the bell badge fresh.
    if (Get.isRegistered<NotificationsController>()) {
      Get.find<NotificationsController>().onPushReceived();
    }
    final notification = message.notification;
    if (notification != null && notification.title != null) {
      showCustomSnackBar(
        notification.title,
        isError: false,
      );
    }
  }

  String? _detectPlatform() {
    if (kIsWeb) return 'web';
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'ios';
    if (defaultTargetPlatform == TargetPlatform.android) return 'android';
    return null;
  }
}
