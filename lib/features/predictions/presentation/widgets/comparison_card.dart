import 'package:flutter/material.dart';

import '../../domain/entities/post_match_comparison_entity.dart';

/// Displays the result of an AI prediction vs actual result comparison.
class ComparisonCard extends StatelessWidget {
  const ComparisonCard({super.key, required this.comparison});

  final PostMatchComparisonEntity comparison;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accuracyColor =
        comparison.overallAccuracy >= 50 ? const Color(0xFF2E7D32) : const Color(0xFFC62828);

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
                    '${comparison.homeTeam} vs ${comparison.awayTeam}',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accuracyColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${comparison.overallAccuracy.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: accuracyColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'FT: ${comparison.actualHomeScore}-${comparison.actualAwayScore}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 6),
            Text(
              comparison.summary,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _MarketChip(
                  label: 'Winner',
                  correct: comparison.matchWinnerCorrect,
                ),
                _MarketChip(
                  label: 'Double Chance',
                  correct: comparison.doubleChanceCorrect,
                ),
                _MarketChip(
                  label: 'BTTS',
                  correct: comparison.bttsCorrect,
                ),
                _MarketChip(
                  label: 'Correct Score',
                  correct: comparison.correctScoreCorrect,
                ),
                _MarketChip(
                  label: 'O/U Goals',
                  correct: comparison.overUnderCorrect,
                ),
                if (comparison.cornersCorrect != null)
                  _MarketChip(
                    label: 'Corners',
                    correct: comparison.cornersCorrect!,
                  ),
                if (comparison.cardsCorrect != null)
                  _MarketChip(
                    label: 'Cards',
                    correct: comparison.cardsCorrect!,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MarketChip extends StatelessWidget {
  const _MarketChip({required this.label, required this.correct});
  final String label;
  final bool correct;

  @override
  Widget build(BuildContext context) {
    final color = correct ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            correct ? Icons.check_circle_outline : Icons.cancel_outlined,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
