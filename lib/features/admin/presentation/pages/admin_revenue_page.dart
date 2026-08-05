import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/admin_providers.dart';
import '../../domain/entities/admin_revenue_entity.dart';
import '../widgets/stat_card.dart';

/// Tab for viewing financials & revenue tracking.
class AdminRevenuePage extends ConsumerWidget {
  const AdminRevenuePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenue = ref.watch(adminRevenueProvider);
    if (revenue == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return _RevenueView(revenue: revenue);
  }
}

class _RevenueView extends StatelessWidget {
  const _RevenueView({required this.revenue});
  final AdminRevenueEntity revenue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Revenue Dashboard', style: theme.textTheme.titleLarge),
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
              label: 'Total Revenue (₦)',
              value: _formatNaira(revenue.totalRevenueNaira),
              icon: Icons.payments_outlined,
              color: Colors.green.shade700,
            ),
            AdminStatCard(
              label: 'Transactions',
              value: '${revenue.totalTransactions}',
              icon: Icons.receipt_long_outlined,
              color: theme.colorScheme.primary,
            ),
            AdminStatCard(
              label: 'Success Rate',
              value: '${revenue.successRate.toStringAsFixed(1)}%',
              icon: Icons.verified_outlined,
              color: Colors.teal,
            ),
            AdminStatCard(
              label: 'Avg. Transaction (₦)',
              value: _formatNaira(revenue.averageTransactionNaira),
              icon: Icons.analytics_outlined,
              color: Colors.orange,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Subscriptions', style: theme.textTheme.titleMedium),
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
              label: 'Active Subscriptions',
              value: '${revenue.activeSubscriptions}',
              icon: Icons.workspace_premium_outlined,
              color: Colors.amber.shade700,
            ),
            AdminStatCard(
              label: 'New This Month',
              value: '${revenue.newSubscriptionsThisMonth}',
              icon: Icons.person_add_alt_1_outlined,
              color: theme.colorScheme.tertiary,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Growth', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        _GrowthCard(revenue: revenue),
        const SizedBox(height: 16),
        Text('Revenue (14 days)', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        _RevenueSeriesCard(points: revenue.revenueSeries),
      ],
    );
  }

  String _formatNaira(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toStringAsFixed(0);
  }
}

class _GrowthCard extends StatelessWidget {
  const _GrowthCard({required this.revenue});
  final AdminRevenueEntity revenue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final growth = revenue.growthRate;
    final positive = growth != null && growth >= 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              growth == null
                  ? Icons.trending_flat
                  : (positive ? Icons.trending_up : Icons.trending_down),
              color: growth == null
                  ? theme.colorScheme.outline
                  : (positive ? Colors.green : Colors.red),
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Month-over-month growth',
                      style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    growth == null
                        ? 'Not enough data'
                        : '${growth.toStringAsFixed(1)}%',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: growth == null
                          ? theme.colorScheme.outline
                          : (positive ? Colors.green : Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevenueSeriesCard extends StatelessWidget {
  const _RevenueSeriesCard({required this.points});
  final List<RevenueDayPoint> points;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (points.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No revenue data for the last 14 days.'),
        ),
      );
    }
    final maxRevenue = points.fold<int>(
        1, (a, b) => b.revenueKobo > a ? b.revenueKobo : a);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                          value: (p.revenueKobo / maxRevenue).clamp(0, 1),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 56,
                      child: Text(
                        '₦${(p.revenueNaira / 1000).toStringAsFixed(1)}K',
                        textAlign: TextAlign.right,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
