import 'package:flutter/material.dart';

import '../../domain/entities/prediction_entity.dart';

/// Card summarizing today's AI predictions.
class PredictionSummaryCard extends StatelessWidget {
  const PredictionSummaryCard({super.key, required this.predictions});
  final PredictionSummaryEntity predictions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'AI Predictions',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat(
                  value: '${predictions.totalPredictions}',
                  label: 'Predictions',
                ),
                _Stat(
                  value: '${predictions.highConfidence}',
                  label: 'High Conf.',
                ),
                _Stat(
                  value: '${predictions.totalMatches}',
                  label: 'Matches',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
