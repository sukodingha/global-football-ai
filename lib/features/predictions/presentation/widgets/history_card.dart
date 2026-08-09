import 'package:flutter/material.dart';

import '../../domain/entities/prediction_history_entity.dart';

/// A card displaying a single prediction history entry with its result.
class HistoryCard extends StatelessWidget {
  const HistoryCard({super.key, required this.history});

  final PredictionHistoryEntity history;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isResolved = history.status != PredictionStatus.pending;
    final statusColor = switch (history.status) {
      PredictionStatus.won => const Color(0xFF2E7D32),
      PredictionStatus.lost => const Color(0xFFC62828),
      PredictionStatus.voided => const Color(0xFF6A1B9A),
      PredictionStatus.pending => theme.colorScheme.outline,
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${history.homeTeam} vs ${history.awayTeam}',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                _StatusBadge(status: history.status, color: statusColor),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Predicted winner: ${_outcomeLabel(history.prediction.matchWinner?.predictedOutcome)}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              _scoreText(history),
              style: theme.textTheme.bodyMedium,
            ),
            if (isResolved) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    history.isCorrect == true
                        ? Icons.check_circle
                        : Icons.cancel,
                    size: 18,
                    color: statusColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    history.isCorrect == true
                        ? 'Prediction correct'
                        : 'Prediction incorrect',
                    style: theme.textTheme.bodyMedium?.copyWith(color: statusColor),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _outcomeLabel(String? outcome) {
    return switch (outcome) {
      'home' => 'Home',
      'away' => 'Away',
      'draw' => 'Draw',
      _ => '—',
    };
  }

  String _scoreText(PredictionHistoryEntity history) {
    final home = history.actualHomeScore;
    final away = history.actualAwayScore;
    if (home == null || away == null) {
      return 'Match not yet played';
    }
    return 'FT: $home-$away';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.color});
  final PredictionStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      PredictionStatus.pending => 'PENDING',
      PredictionStatus.won => 'WON',
      PredictionStatus.lost => 'LOST',
      PredictionStatus.voided => 'VOIDED',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
