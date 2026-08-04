import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../auth/application/auth_providers.dart';
import '../../application/notification_providers.dart';
import '../../application/notification_state.dart';
import '../../domain/entities/notification_preferences_entity.dart';
import '../widgets/preference_section.dart';
import '../widgets/preference_toggle_tile.dart';

/// A focused page for editing granular notification preferences.
///
/// Groups toggles into Match & Event Alerts, News, Community, and Promotions
/// sections. Changes are persisted in real time via the
/// [NotificationNotifier] (Firestore-backed).
class NotificationPreferencesPage extends ConsumerWidget {
  const NotificationPreferencesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    ref.watch(notificationControllerProvider);
    final state = ref.watch(notificationNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Preferences')),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : switch (state) {
              NotificationInitial() || NotificationLoading() =>
                const Center(child: CircularProgressIndicator()),
              NotificationError(:final message) =>
                ErrorStateView(message: message),
              NotificationLoaded() =>
                _PreferencesBody(userId: user.id, prefs: state.preferences),
            },
    );
  }
}

class _PreferencesBody extends ConsumerWidget {
  const _PreferencesBody({required this.userId, required this.prefs});

  final String userId;
  final AppNotificationPreferences prefs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    Future<void> save(AppNotificationPreferences updated) async {
      await ref
          .read(notificationNotifierProvider.notifier)
          .savePreferences(userId: userId, preferences: updated);
    }

    return ResponsiveContainer(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          PreferenceSection(
            title: 'Match & Event Alerts',
            icon: Icons.sports_soccer,
            children: [
              PreferenceToggleTile(
                icon: Icons.sports_soccer,
                title: 'Goal Alerts',
                subtitle: 'Notify when a goal is scored in your matches.',
                value: prefs.goalAlerts,
                onChanged: (v) => save(prefs.copyWith(goalAlerts: v)),
              ),
              PreferenceToggleTile(
                icon: Icons.play_circle_outline,
                title: 'Kickoff',
                subtitle: 'Notify when a match kicks off.',
                value: prefs.kickoffAlerts,
                onChanged: (v) => save(prefs.copyWith(kickoffAlerts: v)),
              ),
              PreferenceToggleTile(
                icon: Icons.pause_circle_outline,
                title: 'Half Time',
                subtitle: 'Notify at the half-time whistle.',
                value: prefs.halfTimeAlerts,
                onChanged: (v) => save(prefs.copyWith(halfTimeAlerts: v)),
              ),
              PreferenceToggleTile(
                icon: Icons.stop_circle_outlined,
                title: 'Full Time',
                subtitle: 'Notify when a match ends.',
                value: prefs.fullTimeAlerts,
                onChanged: (v) => save(prefs.copyWith(fullTimeAlerts: v)),
              ),
              PreferenceToggleTile(
                icon: Icons.emoji_events_outlined,
                title: 'Prediction Results',
                subtitle: 'Notify when an AI prediction result locks in.',
                value: prefs.predictionAlerts,
                onChanged: (v) => save(prefs.copyWith(predictionAlerts: v)),
              ),
            ],
          ),
          PreferenceSection(
            title: 'News',
            icon: Icons.newspaper,
            children: [
              PreferenceToggleTile(
                icon: Icons.newspaper,
                title: 'Breaking News',
                subtitle: 'Big football stories as they break.',
                value: prefs.breakingNews,
                onChanged: (v) => save(prefs.copyWith(breakingNews: v)),
              ),
              PreferenceToggleTile(
                icon: Icons.swap_horiz,
                title: 'Transfer News',
                subtitle: 'Rumours and confirmed transfers.',
                value: prefs.transferNews,
                onChanged: (v) => save(prefs.copyWith(transferNews: v)),
              ),
            ],
          ),
          PreferenceSection(
            title: 'Community',
            icon: Icons.forum_outlined,
            children: [
              PreferenceToggleTile(
                icon: Icons.forum_outlined,
                title: 'Community Replies',
                subtitle: 'Notify when someone replies to your posts.',
                value: prefs.communityReplies,
                onChanged: (v) => save(prefs.copyWith(communityReplies: v)),
              ),
            ],
          ),
          PreferenceSection(
            title: 'Promotions',
            icon: Icons.local_offer_outlined,
            children: [
              PreferenceToggleTile(
                icon: Icons.local_offer_outlined,
                title: 'Promotions',
                subtitle: 'Offers and premium deals.',
                value: prefs.promotions,
                onChanged: (v) => save(prefs.copyWith(promotions: v)),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Changes are saved automatically.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
