import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/router/navigator_key.dart';
import 'core/services/dependency_injection.dart';
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
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyDEFAULT_KEY',
        appId: '1:000000000000:web:0000000000000000',
        messagingSenderId: '000000000000',
        projectId: 'global-ai-prediction',
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
