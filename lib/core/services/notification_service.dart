import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
}

/// Push notification service wrapping Firebase Cloud Messaging.
///
/// Handles FCM initialization, permission requests, token retrieval, token
/// sync to Firestore, topic subscription for notification preferences, and
/// foreground message handling.
class NotificationService {
  NotificationService({FirebaseMessaging? messaging})
      : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  StreamSubscription<RemoteMessage>? _foregroundSub;

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

  /// Handles a message tapped when the app was in the background.
  Future<void> handleBackgroundTap() async {
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      // TODO: Navigate based on initial.data payload.
    }
  }

  /// Disposes of the foreground listener.
  void dispose() {
    _foregroundSub?.cancel();
  }
}
