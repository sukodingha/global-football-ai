import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/admin_providers.dart';
import '../../domain/entities/admin_analytics_entity.dart';
import '../widgets/stat_card.dart';

/// Tab for viewing platform analytics & insights.
class AdminAnalyticsPage extends ConsumerWidget {
  const AdminAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(adminAnalyticsProvider);
    if (analytics == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return _AnalyticsView(analytics: analytics, ref: ref);
  }
}

class _AnalyticsView extends StatelessWidget {
  const _AnalyticsView({required this.analytics, required this.ref});
  final AdminAnalyticsEntity analytics;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Platform Overview',
                style: theme.textTheme.titleLarge,
              ),
            ),
            IconButton(
              tooltip: 'Refresh',
              onPressed: () =>
                  ref.read(adminNotifierProvider.notifier).refreshInsights(),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            AdminStatCard(
              label: 'Total Users',
              value: '${analytics.totalUsers}',
              icon: Icons.people_outline,
              color: theme.colorScheme.primary,
            ),
            AdminStatCard(
              label: 'Daily Active',
              value: '${analytics.dailyActiveUsers}',
              icon: Icons.today_outlined,
              color: theme.colorScheme.tertiary,
            ),
            AdminStatCard(
              label: 'Monthly Active',
              value: '${analytics.monthlyActiveUsers}',
              icon: Icons.calendar_month_outlined,
              color: Colors.teal,
            ),
            AdminStatCard(
              label: 'Engagement / User',
              value: analytics.engagementPerUser.toStringAsFixed(1),
              icon: Icons.trending_up,
              color: Colors.orange,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Prediction Accuracy', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        _ProgressCard(
          label: 'Accuracy Rate',
          value: analytics.accuracyRate.toStringAsFixed(1),
          progress: analytics.accuracyRate / 100,
          trailing: '${analytics.correctPredictions}/${analytics.totalPredictions} correct',
        ),
        const SizedBox(height: 8),
        _AccuracyTrendCard(points: analytics.accuracyTrend),
        const SizedBox(height: 16),
        Text('Content', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            AdminStatCard(
              label: 'Posts',
              value: '${analytics.totalPosts}',
              icon: Icons.forum_outlined,
              color: theme.colorScheme.primary,
            ),
            AdminStatCard(
              label: 'Comments',
              value: '${analytics.totalComments}',
              icon: Icons.comment_outlined,
              color: theme.colorScheme.tertiary,
            ),
            AdminStatCard(
              label: 'Leagues',
              value: '${analytics.totalLeagues}',
              icon: Icons.emoji_events_outlined,
              color: Colors.amber,
            ),
            AdminStatCard(
              label: 'Teams',
              value: '${analytics.totalTeams}',
              icon: Icons.groups_outlined,
              color: Colors.indigo,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Top Competitions', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        if (analytics.topCompetitionEngagement.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No competition engagement data yet.'),
            ),
          )
        else
          for (final entry in analytics.topCompetitionEngagement.entries)
            _CompetitionRow(
              name: entry.key,
              count: entry.value,
              max: analytics.topCompetitionEngagement.values
                      .fold<int>(0, (a, b) => a > b ? a : b)
                  .toDouble(),
            ),
        const SizedBox(height: 16),
        Text('Engagement (14 days)', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        _EngagementSeriesCard(points: analytics.engagementSeries),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.label,
    required this.value,
    required this.progress,
    this.trailing,
  });
  final String label;
  final String value;
  final double progress;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: theme.textTheme.bodyMedium),
                Text(
                  '$value%',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1),
                minHeight: 8,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(height: 8),
              Text(
                trailing!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Renders the weekly prediction accuracy trend as simple bars.
class _AccuracyTrendCard extends StatelessWidget {
  const _AccuracyTrendCard({required this.points});
  final List<AccuracyTrendPoint> points;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (points.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No weekly accuracy data available yet.'),
        ),
      );
    }
    final trend = points.reversed.take(6).toList().reversed.toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly accuracy trend',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            for (final p in trend)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    SizedBox(
                      width: 78,
                      child: Text(
                        p.period,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: (p.accuracy / 100).clamp(0, 1),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 52,
                      child: Text(
                        '${p.accuracy.toStringAsFixed(0)}%',
                        textAlign: TextAlign.right,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 4),
            Text(
              '${points.length} week(s) tracked',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompetitionRow extends StatelessWidget {
  const _CompetitionRow({
    required this.name,
    required this.count,
    required this.max,
  });
  final String name;
  final int count;
  final double max;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(name, style: theme.textTheme.bodyMedium)),
                Text('$count', style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: max == 0 ? 0 : count / max,
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EngagementSeriesCard extends StatelessWidget {
  const _EngagementSeriesCard({required this.points});
  final List<EngagementPoint> points;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (points.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No engagement data for the last 14 days.'),
        ),
      );
    }
    final maxActions = points.fold<int>(1, (a, b) => b.actions > a ? b.actions : a);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Simple text-based bar summary (last 7 days).
            for (final p in points.reversed.take(7).toList().reversed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    SizedBox(
                      width: 44,
                      child: Text(
                        '${p.date.day}/${p.date.month}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: (p.actions / maxActions).clamp(0, 1),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${p.actions}', style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
