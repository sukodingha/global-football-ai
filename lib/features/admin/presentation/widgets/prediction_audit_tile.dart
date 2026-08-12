import 'package:flutter/material.dart';

import '../../domain/entities/admin_prediction_entity.dart';

/// A single AI prediction row for audit/override.
class PredictionAuditTile extends StatelessWidget {
  const PredictionAuditTile({
    super.key,
    required this.prediction,
    this.onVerify,
    this.onOverride,
  });

  final AdminPredictionEntity prediction;
  final VoidCallback? onVerify;
  final VoidCallback? onOverride;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = switch (prediction.status) {
      PredictionAuditStatus.pending => Colors.orange,
      PredictionAuditStatus.verified => Colors.green,
      PredictionAuditStatus.overridden => Colors.red,
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${prediction.homeTeam} vs ${prediction.awayTeam}',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    prediction.status.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Confidence ${prediction.overallConfidence.toStringAsFixed(0)}% · '
              '${prediction.predictedOutcome ?? 'Outcome pending'}',
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              prediction.summary,
              style: theme.textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (prediction.overrideOutcome != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Override: ${prediction.overrideOutcome}',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (prediction.status != PredictionAuditStatus.verified)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onVerify,
                      icon: const Icon(Icons.verified_outlined, size: 18),
                      label: const Text('Verify'),
                    ),
                  ),
                if (prediction.status == PredictionAuditStatus.verified)
                  const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: onOverride,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Override'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
