import 'package:flutter/material.dart';

import '../../domain/entities/match_statistics_entity.dart';

/// Displays advanced match statistics (possession, shots, fouls, etc.)
/// as a series of comparison bars between home and away teams.
class MatchStatisticsView extends StatelessWidget {
  const MatchStatisticsView({
    super.key,
    required this.statistics,
    this.homeName = 'Home',
    this.awayName = 'Away',
  });

  final List<MatchStatisticEntity> statistics;
  final String homeName;
  final String awayName;

  @override
  Widget build(BuildContext context) {
    if (statistics.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text('No statistics available for this match yet.'),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  homeName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  awayName,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        ...statistics.map(
          (stat) => _StatRow(stat: stat),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.stat});
  final MatchStatisticEntity stat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homePct = stat.homePercentage ?? 0.5;
    final awayPct = stat.awayPercentage ?? (1.0 - homePct);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  stat.homeValue,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  stat.category,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  stat.awayValue,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 6,
              child: Row(
                children: [
                  Expanded(
                    flex: (homePct * 100).round(),
                    child: Container(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(
                    width: 2,
                    child: Container(color: theme.colorScheme.surfaceVariant),
                  ),
                  Expanded(
                    flex: (awayPct * 100).round(),
                    child: Container(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
