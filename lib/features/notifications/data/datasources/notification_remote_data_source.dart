import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/notification_preferences_entity.dart';
import '../models/notification_preferences_model.dart';

/// Cloud Firestore-backed data source for notification preferences.
///
/// Stores granular preferences (match events, news feeds, personalized
/// teams/competitions) under `users/{uid}/notification_preferences`.
class NotificationRemoteDataSource {
  NotificationRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _prefsDoc(String userId) =>
      _firestore.collection('users').doc(userId);

  /// Watches the user's notification preferences in real time.
  Stream<AppNotificationPreferences> watchPreferences(String userId) {
    return _prefsDoc(userId).snapshots().map(
          (snap) => _prefsFromDoc(snap.data()),
        );
  }

  /// Reads the user's notification preferences once.
  Future<AppNotificationPreferences> getPreferences(String userId) async {
    try {
      final doc = await _prefsDoc(userId).get();
      return _prefsFromDoc(doc.data());
    } catch (e) {
      throw CacheException('Unable to load notification preferences: $e');
    }
  }

  /// Persists the user's notification preferences.
  ///
  /// The prefs are stored as a nested map so they don't collide with the
  /// settings feature's `notificationPreferences` sub-document.
  Future<void> savePreferences({
    required String userId,
    required AppNotificationPreferences preferences,
  }) async {
    try {
      await _prefsDoc(userId).set({
        'notification_preferences':
            AppNotificationPreferencesModel(
              matchReminders: preferences.matchReminders,
              breakingNews: preferences.breakingNews,
              transferNews: preferences.transferNews,
              goalAlerts: preferences.goalAlerts,
              kickoffAlerts: preferences.kickoffAlerts,
              halfTimeAlerts: preferences.halfTimeAlerts,
              fullTimeAlerts: preferences.fullTimeAlerts,
              predictionAlerts: preferences.predictionAlerts,
              communityReplies: preferences.communityReplies,
              promotions: preferences.promotions,
              favoriteTeams: preferences.favoriteTeams,
              favoriteCompetitions: preferences.favoriteCompetitions,
            ).toJson(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw CacheException('Unable to save notification preferences: $e');
    }
  }

  AppNotificationPreferences _prefsFromDoc(Map<String, dynamic>? data) {
    final nested = data?['notification_preferences'] as Map<String, dynamic>?;
    return AppNotificationPreferencesModel.fromJson(nested).toEntity();
  }
}
