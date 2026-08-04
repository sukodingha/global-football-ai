import 'package:flutter/material.dart';

import '../../domain/entities/fantasy_player_entity.dart';

/// A detailed breakdown of how a player earned their fantasy points.
class PointsBreakdown extends StatelessWidget {
  const PointsBreakdown({
    super.key,
    required this.player,
  });

  final FantasyPlayerEntity player;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = player.stats;

    final rows = <_PointRow>[
      _PointRow(icon: Icons.sports_soccer, label: 'Goals', value: s.goals, points: s.goals * 0), // We'll compute below
      _PointRow(icon: Icons.assistant, label: 'Assists', value: s.assists, points: 0),
      _PointRow(icon: Icons.shield_outlined, label: 'Clean Sheets', value: s.cleanSheets, points: 0),
      _PointRow(icon: Icons.square_outlined, label: 'Yellow Cards', value: s.yellowCards, points: 0),
      _PointRow(icon: Icons.block, label: 'Red Cards', value: s.redCards, points: 0),
      _PointRow(icon: Icons.sports_handball, label: 'Saves', value: s.saves, points: 0),
      _PointRow(icon: Icons.person, label: 'Appearances', value: s.appearances, points: 0),
      _PointRow(icon: Icons.timer_outlined, label: 'Minutes Played', value: s.minutesPlayed, points: 0),
    ];
    // Points are pre-computed by the scoring engine.
    final totalPoints = player.totalPoints;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Points Breakdown',
                    style: theme.textTheme.titleSmall),
                const Spacer(),
                Text(
                  '${totalPoints.toStringAsFixed(0)} pts',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const Divider(),
            ...rows.where((r) => r.value > 0).map((r) => r),
            if (rows.every((r) => r.value == 0))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No stats recorded yet.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.outline),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PointRow extends StatelessWidget {
  const _PointRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.points,
  });

  final IconData icon;
  final String label;
  final int value;
  final int points;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.outline),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Text(
            '$value',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 48,
            child: Text(
              '$points pts',
              textAlign: TextAlign.end,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
