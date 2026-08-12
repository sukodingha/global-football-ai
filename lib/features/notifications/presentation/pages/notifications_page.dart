import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../auth/application/auth_providers.dart';
import '../../application/notification_providers.dart';
import '../../application/notification_state.dart';
import '../../domain/entities/notification_alert_entity.dart';
import '../../domain/entities/notification_preferences_entity.dart';

/// The notifications center.
///
/// Shows the user's alert feed (in-app, from the live alert engine) and
/// granular notification preferences (goals, kickoff, full-time, news,
/// predictions, and personalized teams/competitions).
class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    ref.watch(notificationControllerProvider);
    final state = ref.watch(notificationNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.notifications_outlined), text: 'Alerts'),
            Tab(icon: Icon(Icons.tune), text: 'Preferences'),
          ],
        ),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : switch (state) {
              NotificationInitial() || NotificationLoading() =>
                const Center(child: CircularProgressIndicator()),
              NotificationError(:final message) =>
                _ErrorView(message: message),
              NotificationLoaded() => TabBarView(
                  controller: _tabController,
                  children: [
                    _AlertsTab(),
                    _PreferencesTab(userId: user.id),
                  ],
                ),
            },
    );
  }
}

class _AlertsTab extends ConsumerWidget {
  const _AlertsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(recentNotificationsProvider);
    final theme = Theme.of(context);

    if (alerts.isEmpty) {
      return const EmptyStateView(
        icon: Icons.notifications_none,
        title: 'No alerts yet',
        message:
            'Live match alerts (goals, kickoff, results) and breaking news '
            'will appear here in real time.',
      );
    }

    return ResponsiveContainer(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text('Recent alerts', style: theme.textTheme.titleMedium),
                ),
                TextButton(
                  onPressed: () => ref
                      .read(notificationNotifierProvider.notifier)
                      .markAllRead(),
                  child: const Text('Mark all read'),
                ),
              ],
            ),
          ),
          for (final alert in alerts) _AlertTile(alert: alert),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert});
  final NotificationAlertEntity alert;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color) = _visualFor(alert.type);
    final time = DateFormat('HH:mm').format(alert.createdAt.toLocal());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(alert.title),
        subtitle: Text(alert.body),
        trailing: Text(
          time,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
        ),
      ),
    );
  }

  (IconData, Color) _visualFor(NotificationAlertType type) {
    switch (type) {
      case NotificationAlertType.goal:
        return (Icons.sports_soccer, Colors.green);
      case NotificationAlertType.kickoff:
        return (Icons.play_circle_outline, Colors.blue);
      case NotificationAlertType.halfTime:
        return (Icons.pause_circle_outline, Colors.orange);
      case NotificationAlertType.fullTime:
        return (Icons.stop_circle_outlined, Colors.redAccent);
      case NotificationAlertType.result:
        return (Icons.emoji_events_outlined, Colors.amber);
      case NotificationAlertType.prediction:
        return (Icons.insights, Colors.purple);
      case NotificationAlertType.breakingNews:
        return (Icons.newspaper, Colors.teal);
      case NotificationAlertType.transferNews:
        return (Icons.swap_horiz, Colors.indigo);
    }
  }
}

class _PreferencesTab extends ConsumerWidget {
  const _PreferencesTab({required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationPreferencesProvider);
    final state = ref.watch(notificationNotifierProvider);
    final saving = state is NotificationLoaded && state.saving;
    final theme = Theme.of(context);

    return ResponsiveContainer(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Match & Event Alerts', style: theme.textTheme.titleMedium),
          ),
          _SwitchTile(
            icon: Icons.sports_soccer,
            title: 'Goal Alerts',
            subtitle: 'Notify when your favorite matches have a goal.',
            value: prefs.goalAlerts,
            onChanged: (v) => _save(ref, userId, prefs.copyWith(goalAlerts: v)),
          ),
          _SwitchTile(
            icon: Icons.play_circle_outline,
            title: 'Kickoff',
            subtitle: 'Notify when a match kicks off.',
            value: prefs.kickoffAlerts,
            onChanged: (v) => _save(ref, userId, prefs.copyWith(kickoffAlerts: v)),
          ),
          _SwitchTile(
            icon: Icons.pause_circle_outline,
            title: 'Half Time',
            subtitle: 'Notify at the half-time whistle.',
            value: prefs.halfTimeAlerts,
            onChanged: (v) => _save(ref, userId, prefs.copyWith(halfTimeAlerts: v)),
          ),
          _SwitchTile(
            icon: Icons.stop_circle_outlined,
            title: 'Full Time',
            subtitle: 'Notify when a match ends.',
            value: prefs.fullTimeAlerts,
            onChanged: (v) => _save(ref, userId, prefs.copyWith(fullTimeAlerts: v)),
          ),
          _SwitchTile(
            icon: Icons.emoji_events_outlined,
            title: 'Prediction Results',
            subtitle: 'Notify when a prediction result is locked.',
            value: prefs.predictionAlerts,
            onChanged: (v) =>
                _save(ref, userId, prefs.copyWith(predictionAlerts: v)),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('News', style: theme.textTheme.titleMedium),
          ),
          _SwitchTile(
            icon: Icons.newspaper,
            title: 'Breaking News',
            subtitle: 'Big football stories as they break.',
            value: prefs.breakingNews,
            onChanged: (v) => _save(ref, userId, prefs.copyWith(breakingNews: v)),
          ),
          _SwitchTile(
            icon: Icons.swap_horiz,
            title: 'Transfer News',
            subtitle: 'Rumours and confirmed transfers.',
            value: prefs.transferNews,
            onChanged: (v) => _save(ref, userId, prefs.copyWith(transferNews: v)),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Community', style: theme.textTheme.titleMedium),
          ),
          _SwitchTile(
            icon: Icons.forum_outlined,
            title: 'Community Replies',
            subtitle: 'Notify when someone replies to your posts.',
            value: prefs.communityReplies,
            onChanged: (v) =>
                _save(ref, userId, prefs.copyWith(communityReplies: v)),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Promotions', style: theme.textTheme.titleMedium),
          ),
          _SwitchTile(
            icon: Icons.local_offer_outlined,
            title: 'Promotions',
            subtitle: 'Offers and premium deals.',
            value: prefs.promotions,
            onChanged: (v) => _save(ref, userId, prefs.copyWith(promotions: v)),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              saving ? 'Saving…' : 'Changes are saved automatically.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save(
    WidgetRef ref,
    String userId,
    AppNotificationPreferences prefs,
  ) async {
    await ref
        .read(notificationNotifierProvider.notifier)
        .savePreferences(userId: userId, preferences: prefs);
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return ErrorStateView(message: message);
  }
}
