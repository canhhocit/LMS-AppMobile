import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    debugPrint("🔥 [FCM Background] Title: ${message.notification?.title}, Body: ${message.notification?.body}");
  } catch (e) {
    debugPrint("⚠️ [FCM Background Error]: $e");
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  Future<void> initialize(BuildContext? context) async {
    try {
      // 1. Initialize Firebase Core safely
      await Firebase.initializeApp();
      debugPrint("✅ [Firebase Core] Initialized successfully!");

      // 2. Set background messaging handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 3. Request Notification Permissions
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint("🔔 [FCM Permission] Status: ${settings.authorizationStatus}");

      // 4. Get FCM Token for device
      _fcmToken = await messaging.getToken();
      debugPrint("🔑 [FCM Token]: $_fcmToken");

      // Token Refresh Listener
      messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint("🔄 [FCM Token Refreshed]: $newToken");
      });

      // 5. Handle Foreground Messages (App is open)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint("💬 [FCM Foreground] Received: ${message.notification?.title}");
        if (context != null && context.mounted) {
          _showInAppBanner(context, message);
        }
      });

      // 6. Handle Notification Tap (App opened from background)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint("👉 [FCM Notification Clicked]: ${message.data}");
      });

    } catch (e) {
      debugPrint("⚠️ [NotificationService Init Note]: Firebase config file (google-services.json) not detected or initialization deferred. Message: $e");
    }
  }

  void _showInAppBanner(BuildContext context, RemoteMessage message) {
    final title = message.notification?.title ?? 'Thông báo mới';
    final body = message.notification?.body ?? '';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF4F46E5), // Indigo 600
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.amberAccent, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                  ),
                  if (body.isNotEmpty)
                    Text(
                      body,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
