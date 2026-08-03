import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/prediction_providers.dart';
import '../../domain/entities/post_match_comparison_entity.dart';
import 'comparison_card.dart';

/// Lets the user enter the actual final result of a match and runs a
/// post-match comparison against the AI prediction to track accuracy.
///
/// Accepts the finished scoreline, plus optional corner and card totals so
/// those markets are evaluated too. The resulting comparison is persisted
/// and displayed inline.
class ComparisonInputCard extends ConsumerStatefulWidget {
  const ComparisonInputCard({super.key});

  @override
  ConsumerState<ComparisonInputCard> createState() =>
      _ComparisonInputCardState();
}

class _ComparisonInputCardState extends ConsumerState<ComparisonInputCard> {
  final _homeScoreController = TextEditingController();
  final _awayScoreController = TextEditingController();
  final _cornersController = TextEditingController();
  final _cardsController = TextEditingController();

  bool _submitting = false;
  PostMatchComparisonEntity? _lastComparison;

  @override
  void dispose() {
    _homeScoreController.dispose();
    _awayScoreController.dispose();
    _cornersController.dispose();
    _cardsController.dispose();
    super.dispose();
  }

  Future<void> _runComparison() async {
    final home = int.tryParse(_homeScoreController.text.trim());
    final away = int.tryParse(_awayScoreController.text.trim());
    if (home == null || away == null || home < 0 || away < 0) {
      _showMessage('Enter both team final scores first.');
      return;
    }

    int? corners;
    int? cards;
    final cornersText = _cornersController.text.trim();
    final cardsText = _cardsController.text.trim();
    if (cornersText.isNotEmpty) {
      corners = int.tryParse(cornersText);
      if (corners == null || corners < 0) {
        _showMessage('Corners must be a valid number.');
        return;
      }
    }
    if (cardsText.isNotEmpty) {
      cards = int.tryParse(cardsText);
      if (cards == null || cards < 0) {
        _showMessage('Cards must be a valid number.');
        return;
      }
    }

    setState(() => _submitting = true);
    final comparison = await ref
        .read(predictionNotifierProvider.notifier)
        .compareWithResult(
          actualHomeScore: home,
          actualAwayScore: away,
          actualCorners: corners,
          actualCards: cards,
        );
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _lastComparison = comparison;
    });

    if (comparison == null) {
      _showMessage('Unable to run comparison. Please try again.');
      return;
    }
    _showMessage(
        'Comparison saved — ${comparison.correctPredictions} of '
        '${comparison.totalPredictions} markets correct '
        '(${comparison.overallAccuracy.toStringAsFixed(1)}%).');
  }

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final comparison = _lastComparison;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.compare_arrows,
                    size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  'Post-Match Comparison',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Enter the full-time result to see how the AI prediction '
              'matched the actual outcome.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ScoreField(
                    controller: _homeScoreController,
                    label: 'Home',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '–',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                Expanded(
                  child: _ScoreField(
                    controller: _awayScoreController,
                    label: 'Away',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ScoreField(
                    controller: _cornersController,
                    label: 'Corners (opt)',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ScoreField(
                    controller: _cardsController,
                    label: 'Cards (opt)',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _submitting ? null : _runComparison,
                icon: _submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.rule),
                label: Text(_submitting ? 'Comparing…' : 'Compare vs Result'),
              ),
            ),
            if (comparison != null) ...[
              const SizedBox(height: 12),
              const Divider(height: 24),
              ComparisonCard(comparison: comparison),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScoreField extends StatelessWidget {
  const _ScoreField({required this.controller, required this.label});
  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        // Accept only digits.
        _DigitsOnlyFormatter(),
      ],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _DigitsOnlyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    if (RegExp(r'^\d+$').hasMatch(newValue.text)) return newValue;
    return oldValue;
  }
}

