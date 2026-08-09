import 'package:flutter/material.dart';

import '../../domain/entities/prediction_entity.dart';
import 'confidence_gauge.dart';

/// Displays the full AI prediction breakdown for a match:
/// winner, double chance, BTTS, correct score, over/under goals,
/// corners, cards, and player props.
class PredictionBreakdownCard extends StatelessWidget {
  const PredictionBreakdownCard({super.key, required this.prediction});

  final MatchPredictionEntity prediction;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(prediction: prediction),
            const SizedBox(height: 8),
            Text(
              prediction.summary,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Divider(height: 24),
            if (prediction.matchWinner != null)
              _WinnerSection(winner: prediction.matchWinner!),
            if (prediction.doubleChance != null)
              _DoubleChanceSection(doubleChance: prediction.doubleChance!),
            if (prediction.btts != null)
              _BttsSection(btts: prediction.btts!),
            if (prediction.correctScore != null)
              _CorrectScoreSection(correctScore: prediction.correctScore!),
            if (prediction.overUnder != null)
              _OverUnderSection(overUnder: prediction.overUnder!),
            if (prediction.cornersPrediction != null)
              _CornersSection(corners: prediction.cornersPrediction!),
            if (prediction.cardsPrediction != null)
              _CardsSection(cards: prediction.cardsPrediction!),
            if (prediction.playerProps.isNotEmpty) ...[
              const SizedBox(height: 8),
              const _SectionLabel(icon: Icons.people_outline, label: 'Player Props'),
              const SizedBox(height: 8),
              ...prediction.playerProps
                  .map((p) => _PlayerPropTile(prop: p)),
            ],
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.prediction});
  final MatchPredictionEntity prediction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${prediction.homeTeam} vs ${prediction.awayTeam}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                prediction.matchDate != null
                    ? _formatDate(prediction.matchDate!)
                    : 'Match prediction',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        ConfidenceGauge(confidence: prediction.overallConfidence),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _WinnerSection extends StatelessWidget {
  const _WinnerSection({required this.winner});
  final MatchWinnerPrediction winner;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outcomeLabel = switch (winner.predictedOutcome) {
      'home' => 'Home Win',
      'away' => 'Away Win',
      _ => 'Draw',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(icon: Icons.emoji_events_outlined, label: 'Match Winner'),
        const SizedBox(height: 4),
        _OutcomeRow(
          label: outcomeLabel,
          value: '${winner.confidence.toStringAsFixed(0)}%',
          outcome: winner.predictedOutcome,
        ),
        _Explanation(text: winner.explanation),
        if (winner.odds != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Odds 1X2: ${winner.odds!.home.toStringAsFixed(2)} / '
              '${winner.odds!.draw.toStringAsFixed(2)} / '
              '${winner.odds!.away.toStringAsFixed(2)}',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _DoubleChanceSection extends StatelessWidget {
  const _DoubleChanceSection({required this.doubleChance});
  final DoubleChancePrediction doubleChance;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(icon: Icons.swap_horiz, label: 'Double Chance'),
        const SizedBox(height: 4),
        _ProbBar(label: '1X (Home or Draw)', value: doubleChance.homeOrDraw),
        _ProbBar(label: '12 (Either Side)', value: doubleChance.homeOrAway),
        _ProbBar(label: 'X2 (Draw or Away)', value: doubleChance.drawOrAway),
        _Explanation(text: doubleChance.explanation),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _BttsSection extends StatelessWidget {
  const _BttsSection({required this.btts});
  final BttsPrediction btts;

  @override
  Widget build(BuildContext context) {
    final yes = btts.yesConfidence;
    final color =
        btts.prediction ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(
          icon: Icons.sports_soccer_outlined,
          label: 'Both Teams to Score',
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _Pill(
              label: btts.prediction ? 'YES' : 'NO',
              color: color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (yes / 100).clamp(0, 1).toDouble(),
                  minHeight: 8,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Yes ${yes.toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        _Explanation(text: btts.explanation),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _CorrectScoreSection extends StatelessWidget {
  const _CorrectScoreSection({required this.correctScore});
  final CorrectScorePrediction correctScore;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(icon: Icons.format_list_numbered, label: 'Correct Score'),
        const SizedBox(height: 4),
        Text(
          'Most likely: ${correctScore.mostLikelyHome}-${correctScore.mostLikelyAway} '
          '(${correctScore.confidence.toStringAsFixed(1)}%)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Alternates: ${correctScore.alternateScores.join(', ')}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        _Explanation(text: correctScore.explanation),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _OverUnderSection extends StatelessWidget {
  const _OverUnderSection({required this.overUnder});
  final OverUnderPrediction overUnder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(icon: Icons.show_chart, label: 'Over / Under 2.5 Goals'),
        const SizedBox(height: 4),
        _Pill(
          label: overUnder.prediction ? 'Over 2.5' : 'Under 2.5',
          color: overUnder.prediction
              ? const Color(0xFF2E7D32)
              : const Color(0xFFC62828),
        ),
        const SizedBox(height: 4),
        Text(
          'Over ${overUnder.over2_5.toStringAsFixed(0)}%  •  Under ${overUnder.under2_5.toStringAsFixed(0)}%',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        _Explanation(text: overUnder.explanation),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _CornersSection extends StatelessWidget {
  const _CornersSection({required this.corners});
  final CornersPrediction corners;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(icon: Icons.flag_outlined, label: 'Corners Over/Under 9.5'),
        const SizedBox(height: 4),
        _Pill(
          label: corners.prediction ? 'Over 9.5' : 'Under 9.5',
          color: corners.prediction
              ? const Color(0xFF2E7D32)
              : const Color(0xFFC62828),
        ),
        const SizedBox(height: 4),
        Text(
          'Over ${corners.over9_5.toStringAsFixed(0)}%  •  Under ${corners.under9_5.toStringAsFixed(0)}%',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        _Explanation(text: corners.explanation),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _CardsSection extends StatelessWidget {
  const _CardsSection({required this.cards});
  final CardsPrediction cards;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(icon: Icons.style_outlined, label: 'Cards Over/Under 4.5'),
        const SizedBox(height: 4),
        _Pill(
          label: cards.prediction ? 'Over 4.5' : 'Under 4.5',
          color: cards.prediction
              ? const Color(0xFF2E7D32)
              : const Color(0xFFC62828),
        ),
        const SizedBox(height: 4),
        Text(
          'Over ${cards.over4_5.toStringAsFixed(0)}%  •  Under ${cards.under4_5.toStringAsFixed(0)}%',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        _Explanation(text: cards.explanation),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _PlayerPropTile extends StatelessWidget {
  const _PlayerPropTile({required this.prop});
  final PlayerProp prop;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.person_outline, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${prop.playerName} – ${prop.metric}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  'Predicted: ${prop.predictedValue.toStringAsFixed(1)} '
                  '(Conf. ${prop.confidence.toStringAsFixed(0)}%)',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                _Explanation(text: prop.explanation),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OutcomeRow extends StatelessWidget {
  const _OutcomeRow({
    required this.label,
    required this.value,
    required this.outcome,
  });
  final String label;
  final String value;
  final String outcome;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (outcome) {
      'home' => const Color(0xFF2E7D32),
      'away' => const Color(0xFF1565C0),
      _ => const Color(0xFF6A1B9A),
    };
    return Row(
      children: [
        Icon(Icons.circle, size: 12, color: color),
        const SizedBox(width: 8),
        Text(label, style: theme.textTheme.titleMedium),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _ProbBar extends StatelessWidget {
  const _ProbBar({required this.label, required this.value});
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 140, child: Text(label)),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (value / 100).clamp(0, 1).toDouble(),
                minHeight: 8,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 44,
            child: Text(
              '${value.toStringAsFixed(0)}%',
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.2),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _Explanation extends StatelessWidget {
  const _Explanation({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
      ),
    );
  }
}
