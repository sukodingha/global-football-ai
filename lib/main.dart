import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app.dart';
import 'core/router/navigator_key.dart';
import 'core/services/notification_service.dart';

/// Allows the background isolate to display alerts even when the Flutter
/// engine is not running. Required by flutter_local_notifications on Android.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Best-effort: no UI work is safe here. The payload is logged for
  // debugging; foreground FCM messages are handled by the NotificationService.
  debugPrint('FCM background message: ${message.messageId}');
}

/// Initializes FCM background handling and local notifications before the
/// app starts.
Future<void> _initNotifications() async {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

// Initialize local notifications (channel + tap handler) up front so
  // foreground alerts can be displayed immediately.
  final notificationService = NotificationService();
  await notificationService.initLocalNotifications(
    onTap: (payload) {
      _handleNotificationTap(payload);
    },
  );

  // Handle cold-start notification taps (terminated state).
  await notificationService.handleBackgroundTap();
}

/// Routes a tapped notification to the appropriate screen using the global
/// navigator key. Match alerts deep-link to the match detail page.
void _handleNotificationTap(Map<String, dynamic> payload) {
  final matchIdStr = payload['matchId'] as String?;
  if (matchIdStr == null || matchIdStr.isEmpty) {
    final context = appNavigatorKey.currentContext;
    if (context != null) GoRouter.of(context).pushNamed('notifications');
    return;
  }

  final matchId = int.tryParse(matchIdStr);
  if (matchId != null && matchId > 0) {
    final context = appNavigatorKey.currentContext;
    if (context != null) {
      GoRouter.of(context).pushNamed(
        'match-detail',
        pathParameters: {'matchId': '$matchId'},
      );
    }
    return;
  }

  final context = appNavigatorKey.currentContext;
  if (context != null) GoRouter.of(context).pushNamed('notifications');
}

/// Application entry point.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    const apiKey = String.fromEnvironment('FIREBASE_WEB_API_KEY');
    const appId = String.fromEnvironment('FIREBASE_WEB_APP_ID');
    const messagingSenderId =
        String.fromEnvironment('FIREBASE_WEB_MESSAGING_SENDER_ID');
    const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');

    if (apiKey.isEmpty ||
        appId.isEmpty ||
        messagingSenderId.isEmpty ||
        projectId.isEmpty) {
      throw StateError(
        'Firebase web configuration is missing. Run with '
        '--dart-define=FIREBASE_WEB_API_KEY=... '
        '--dart-define=FIREBASE_WEB_APP_ID=... '
        '--dart-define=FIREBASE_WEB_MESSAGING_SENDER_ID=... '
        '--dart-define=FIREBASE_PROJECT_ID=...',
      );
    }

    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: apiKey,
        appId: appId,
        messagingSenderId: messagingSenderId,
        projectId: projectId,
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  await _initNotifications();

  runApp(
    const ProviderScope(
      child: GlobalFootballAIApp(),
    ),
  );
}
