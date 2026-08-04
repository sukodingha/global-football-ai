import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../errors/exceptions.dart';

/// FCM topic names used across the app.
///
/// These map to the notification preference toggles in Settings.
class NotificationTopics {
  NotificationTopics._();

  static const String matchReminders = 'match_reminders';
  static const String breakingNews = 'breaking_news';
  static const String communityReplies = 'community_replies';
  static const String promotions = 'promotions';
  static const String goals = 'match_goals';
  static const String kickoff = 'match_kickoff';
  static const String halftime = 'match_halftime';
  static const String fulltime = 'match_fulltime';
  static const String predictions = 'match_predictions';
  static const String transferNews = 'transfer_news';
}

/// Push notification service wrapping Firebase Cloud Messaging.
///
/// Handles FCM initialization, permission requests, token retrieval, token
/// sync to Firestore, topic subscription for notification preferences,
/// foreground message handling, and local notification display so alerts are
/// shown even while the app is in the foreground.
class NotificationService {
  NotificationService({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _localNotifications = localNotifications ??
            FlutterLocalNotificationsPlugin();

  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;

  StreamSubscription<RemoteMessage>? _foregroundSub;
  bool _localInitialized = false;

  /// Callback invoked when a notification is tapped and the app is opened
  /// from a terminated/background state, used for deep-link navigation.
  void Function(Map<String, dynamic> payload)? onNotificationTap;

  /// Initializes the local notifications plugin with the platform channels.
  ///
  /// Must be called once during app startup (before any local notification is
  /// shown). Also registers a callback for when a user taps a displayed
  /// notification.
  Future<void> initLocalNotifications({
    void Function(Map<String, dynamic> payload)? onTap,
  }) async {
    if (_localInitialized) return;
    _localInitialized = true;
    onNotificationTap = onTap;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
    );

    try {
      await _localNotifications.initialize(
        settings,
        onDidReceiveNotificationResponse: (response) {
          final payload = _decodePayload(response.payload);
          if (payload != null) onTap?.call(payload);
        },
      );
    } catch (_) {
      // Local notification init is best-effort; FCM still works.
    }
  }

  Map<String, dynamic>? _decodePayload(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      // Payloads are stored as "key=value&key2=value2" for simple parsing.
      final map = <String, dynamic>{};
      for (final pair in raw.split('&')) {
        final parts = pair.split('=');
        if (parts.length == 2) {
          map[parts[0]] = parts[1];
        }
      }
      return map;
    } catch (_) {
      return null;
    }
  }

  /// Requests notification permission (with a fallback for iOS).
  Future<bool> requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      return settings.authorizationStatus ==
              AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (_) {
      return false;
    }
  }

  /// Returns the current FCM token, or null if unavailable.
  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (_) {
      return null;
    }
  }

  /// Re-fetches the token (e.g. after app upgrade or token rotation).
  Future<String?> refreshToken() async {
    try {
      return await _messaging.getToken();
    } catch (_) {
      return null;
    }
  }

  /// Syncs the FCM token to the user's Firestore document.
  ///
  /// Stores tokens under `users/{uid}/fcmTokens` as a set so users can
  /// receive pushes on multiple devices.
  Future<void> syncTokenToFirestore(String userId) async {
    final token = await getToken();
    if (token == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set(
        {
          'fcmTokens': FieldValue.arrayUnion([token]),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      throw CacheException('Unable to sync notification token: $e');
    }
  }

  /// Subscribes the device to a list of FCM topics.
  Future<void> subscribeToTopics(List<String> topics) async {
    for (final topic in topics) {
      try {
        await _messaging.subscribeToTopic(topic);
      } catch (_) {
        // Best-effort; ignore individual topic failures.
      }
    }
  }

  /// Unsubscribes the device from a list of FCM topics.
  Future<void> unsubscribeFromTopics(List<String> topics) async {
    for (final topic in topics) {
      try {
        await _messaging.unsubscribeFromTopic(topic);
      } catch (_) {
        // Best-effort; ignore individual topic failures.
      }
    }
  }

  /// Starts listening to foreground messages and invokes [onMessage].
  void startForegroundListener(
    void Function(RemoteMessage message) onMessage,
  ) {
    _foregroundSub?.cancel();
    _foregroundSub =
        FirebaseMessaging.onMessage.listen(onMessage, onError: (_) {});
  }

  /// Displays a local notification (used for foreground alerts).
  ///
  /// A deterministic [id] lets the engine avoid duplicate alerts for the same
  /// event. [payload] is a simple "key=value&key2=value2" string used for
  /// deep-link routing when the notification is tapped.
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_localInitialized) {
      await initLocalNotifications();
    }
    try {
      await _localNotifications.show(
        id,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'match_alerts',
            'Match & News Alerts',
            channelDescription:
                'Real-time alerts for goals, kickoff, results and news.',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: payload,
      );
    } catch (_) {
      // Foreground display is best-effort.
    }
  }

  /// Called when the app is opened from a terminated state via a notification
  /// tap. Invokes the registered [onNotificationTap] callback with the payload.
  Future<void> handleBackgroundTap() async {
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      final payload = initial.data;
      if (payload.isNotEmpty) {
        onNotificationTap?.call(payload);
      }
    }
  }

  /// Disposes of the foreground listener.
  void dispose() {
    _foregroundSub?.cancel();
  }
}
