import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/state_views.dart';
import '../../../auth/application/auth_providers.dart';
import '../../application/admin_providers.dart';
import '../../application/admin_state.dart';
import 'admin_analytics_page.dart';
import 'admin_competitions_page.dart';
import 'admin_moderation_logs_page.dart';
import 'admin_moderation_page.dart';
import 'admin_predictions_page.dart';
import 'admin_reports_page.dart';
import 'admin_revenue_page.dart';
import 'admin_subscriptions_page.dart';
import 'admin_users_page.dart';

/// Main protected admin dashboard hub.
///
/// Presents a tabbed interface for managing users, subscriptions,
/// competitions, predictions, moderation, analytics, revenue, and reports.
/// Only reachable by users with an admin role (enforced by routing +
/// Firestore rules).
class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
    Future.microtask(() {
      final user = ref.read(currentUserProvider);
      ref
          .read(adminNotifierProvider.notifier)
          .setAdmin(adminId: user?.id ?? '', adminName: user?.displayName ?? 'Admin');
      ref.read(adminNotifierProvider.notifier).loadDashboard();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(adminNotifierProvider.notifier).loadDashboard(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
tabs: const [
            Tab(text: 'Analytics'),
            Tab(text: 'Revenue'),
            Tab(text: 'Reports'),
            Tab(text: 'Users'),
            Tab(text: 'Subscriptions'),
            Tab(text: 'Competitions'),
            Tab(text: 'Predictions'),
            Tab(text: 'Moderation'),
            Tab(text: 'Mod Logs'),
          ],
        ),
      ),
      body: switch (state) {
        AdminInitial() || AdminLoading() =>
          const Center(child: CircularProgressIndicator()),
        AdminError(:final message) => _ErrorView(message: message),
        AdminLoaded() => TabBarView(
            controller: _tabController,
            children: const [
              AdminAnalyticsPage(),
              AdminRevenuePage(),
              AdminReportsPage(),
              AdminUsersPage(),
              AdminSubscriptionsPage(),
              AdminCompetitionsPage(),
              AdminPredictionsPage(),
              AdminModerationPage(),
              AdminModerationLogsPage(),
            ],
          ),
      },
    );
  }
}

class _ErrorView extends ConsumerWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ErrorStateView(
      message: message,
      onRetry: () =>
          ref.read(adminNotifierProvider.notifier).loadDashboard(),
    );
  }
}
