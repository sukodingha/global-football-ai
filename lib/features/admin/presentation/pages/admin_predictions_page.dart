import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/state_views.dart';
import '../../application/admin_providers.dart';
import '../../domain/entities/admin_prediction_entity.dart';
import '../widgets/prediction_audit_tile.dart';

/// Tab for managing predictions (override, verify, audit AI outcomes).
class AdminPredictionsPage extends ConsumerWidget {
  const AdminPredictionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final predictions = ref.watch(adminPredictionsProvider);

    if (predictions.isEmpty) {
      return const EmptyStateView(
        icon: Icons.auto_awesome_outlined,
        title: 'No predictions',
        message: 'Generated AI predictions will appear here for audit.',
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        for (final p in predictions)
          PredictionAuditTile(
            prediction: p,
            onVerify: () =>
                ref.read(adminNotifierProvider.notifier).verifyPrediction(
                      predictionId: p.id,
                    ),
            onOverride: () => _override(context, ref, p),
          ),
      ],
    );
  }

  void _override(BuildContext context, WidgetRef ref, AdminPredictionEntity p) {
    showDialog<void>(
      context: context,
      builder: (_) => _OverrideDialog(prediction: p),
    ).then((result) {
      if (result is Map<String, dynamic>) {
        ref.read(adminNotifierProvider.notifier).overridePrediction(
              predictionId: p.id,
              outcome: result['outcome'] as String,
              note: result['note'] as String,
            );
      }
    });
  }
}

class _OverrideDialog extends StatefulWidget {
  const _OverrideDialog({required this.prediction});
  final AdminPredictionEntity prediction;

  @override
  State<_OverrideDialog> createState() => _OverrideDialogState();
}

class _OverrideDialogState extends State<_OverrideDialog> {
  final _outcomeController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _outcomeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Override Prediction'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _outcomeController,
            decoration: const InputDecoration(
              labelText: 'Override outcome (e.g. Home Win)',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(labelText: 'Reason / note'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context, {
              'outcome': _outcomeController.text.trim(),
              'note': _noteController.text.trim(),
            });
          },
          child: const Text('Override'),
        ),
      ],
    );
  }
}
