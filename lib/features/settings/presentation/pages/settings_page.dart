import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../auth/application/auth_providers.dart';
import '../../application/settings_providers.dart';
import '../../application/settings_state.dart';
import '../../domain/entities/user_settings_entity.dart';

/// The user's settings page.
///
/// Lets the user update their display name, favorite teams, notification
/// preferences, and theme mode. Persists changes in real time via the
/// Settings feature (Firestore + local cache).
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _favoriteTeamsController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        ref.read(settingsNotifierProvider.notifier).load(user.id);
      }
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _favoriteTeamsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    ref.watch(settingsControllerProvider);
    final state = ref.watch(settingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : switch (state) {
              SettingsInitial() || SettingsLoading() =>
                const Center(child: CircularProgressIndicator()),
              SettingsError(:final message) =>
                _ErrorView(message: message, onRetry: () => null),
              SettingsLoaded() => _buildSettings(
                  context,
                  userId: user.id,
                  settings: state.settings,
                  saving: state.saving,
                ),
            },
    );
  }

  Widget _buildSettings(
    BuildContext context, {
    required String userId,
    required UserSettingsEntity settings,
    required bool saving,
  }) {
    final theme = Theme.of(context);

    // Sync controllers with the current settings whenever they change.
    final name = settings.displayName ?? '';
    if (_displayNameController.text != name) {
      _displayNameController.text = name;
    }
    final teams = settings.favoriteTeams.join(', ');
    if (_favoriteTeamsController.text != teams) {
      _favoriteTeamsController.text = teams;
    }

return ResponsiveContainer(
      child: ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Profile',
            style: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.person_outline),
          title: const Text('Display Name'),
          subtitle: TextField(
            controller: _displayNameController,
            decoration: const InputDecoration(hintText: 'e.g. John Doe'),
          ),
          onTap: null,
        ),
        ListTile(
          leading: const Icon(Icons.badge_outlined),
          title: const Text('Favorite Teams'),
          subtitle: TextField(
            controller: _favoriteTeamsController,
            decoration: const InputDecoration(
              hintText: 'e.g. Arsenal, Barcelona',
            ),
          ),
          onTap: null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: FilledButton.icon(
            onPressed: saving
                ? null
                : () => _saveProfile(userId, _displayNameController.text,
                    _favoriteTeamsController.text),
            icon: saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: const Text('Save Profile'),
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Notifications',
            style: theme.textTheme.titleMedium,
          ),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.notifications_active_outlined),
          title: const Text('Match Reminders'),
          value: settings.notificationPreferences.matchReminders,
          onChanged: (v) => _updateNotifications(
            userId,
            settings.notificationPreferences.copyWith(matchReminders: v),
          ),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.newspaper),
          title: const Text('Breaking News'),
          value: settings.notificationPreferences.breakingNews,
          onChanged: (v) => _updateNotifications(
            userId,
            settings.notificationPreferences.copyWith(breakingNews: v),
          ),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.forum_outlined),
          title: const Text('Community Replies'),
          value: settings.notificationPreferences.communityReplies,
          onChanged: (v) => _updateNotifications(
            userId,
            settings.notificationPreferences.copyWith(communityReplies: v),
          ),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.local_offer_outlined),
          title: const Text('Promotions'),
          value: settings.notificationPreferences.promotions,
          onChanged: (v) => _updateNotifications(
            userId,
            settings.notificationPreferences.copyWith(promotions: v),
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Appearance',
            style: theme.textTheme.titleMedium,
          ),
        ),
RadioGroup<String>(
          value: settings.themeMode,
          onChanged: saving ? null : (v) => _updateTheme(userId, v),
          options: const [
            ('system', 'System'),
            ('light', 'Light'),
            ('dark', 'Dark'),
          ],
        ),
      ],
      ),
    );
  }

  Future<void> _saveProfile(
    String userId,
    String displayName,
    String favoriteTeamsCsv,
  ) async {
    final notifier = ref.read(settingsNotifierProvider.notifier);
    await notifier.updateProfile(
      userId: userId,
      displayName: displayName.trim().isEmpty ? null : displayName.trim(),
    );
    final teams = favoriteTeamsCsv
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    if (teams.isNotEmpty) {
      await notifier.updateFavoriteTeams(userId: userId, favoriteTeams: teams);
    }
  }

  Future<void> _updateNotifications(
    String userId,
    NotificationPreferences preferences,
  ) async {
    await ref
        .read(settingsNotifierProvider.notifier)
        .updateNotificationPreferences(userId: userId, preferences: preferences);
  }

  Future<void> _updateTheme(String userId, String themeMode) async {
    await ref
        .read(settingsNotifierProvider.notifier)
        .updateThemeMode(userId: userId, themeMode: themeMode);
  }
}

/// A simple radio group for selecting a single value from list of options.
class RadioGroup<T> extends StatelessWidget {
  const RadioGroup({
    super.key,
    required this.value,
    required this.options,
    this.onChanged,
  });

  final T value;
  final List<(T, String)> options;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (v, label) in options)
          RadioListTile<T>(
            title: Text(label),
            value: v,
            groupValue: value,
            onChanged: onChanged == null ? null : (v) => onChanged!(v),
          ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ErrorStateView(
      message: message,
      onRetry: onRetry,
    );
  }
}

