import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../home/application/home_providers.dart';
import '../../../home/application/home_state.dart';
import '../../../home/domain/entities/match_entity.dart';
import '../../application/prediction_providers.dart';
import '../../application/prediction_state.dart';
import '../../domain/entities/prediction_entity.dart';
import '../../domain/entities/prediction_history_entity.dart';
import '../widgets/comparison_card.dart';
import '../widgets/comparison_input_card.dart';
import '../widgets/confidence_gauge.dart';
import '../widgets/history_card.dart';
import '../widgets/prediction_breakdown_card.dart';
import '../widgets/vote_widget.dart';

/// Main Predictions & Analytics screen.
///
/// Contains a match selector, the generated AI prediction breakdown,
/// interactive voting, saved history, stored post-match comparisons,
/// and an overall accuracy summary.
class PredictionsPage extends ConsumerStatefulWidget {
  const PredictionsPage({super.key});

  @override
  ConsumerState<PredictionsPage> createState() => _PredictionsPageState();
}

class _PredictionsPageState extends ConsumerState<PredictionsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() {
      ref.read(predictionNotifierProvider.notifier).loadDashboard();
      _loadMatchesForPrediction();
    });
  }

  Future<void> _loadMatchesForPrediction() async {
    // Reuse upcoming/live matches from the Home dashboard module.
    final homeState = ref.read(homeNotifierProvider);
    if (homeState is HomeLoaded) {
      final matches = homeState.upcomingMatches.isEmpty
          ? homeState.liveMatches
          : homeState.upcomingMatches;
      ref.read(predictionNotifierProvider.notifier).loadUpcomingMatches(matches);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(predictionNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Predictions'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Predict'),
            Tab(text: 'History'),
            Tab(text: 'Accuracy'),
          ],
        ),
      ),
      body: switch (state) {
        PredictionInitial() || PredictionLoading() =>
          const Center(child: CircularProgressIndicator()),
        PredictionError(:final message) => _ErrorView(message: message),
        PredictionLoaded() => TabBarView(
            controller: _tabController,
            children: const [
              _PredictTab(),
              _HistoryTab(),
              _AccuracyTab(),
            ],
          ),
      },
    );
  }
}

class _PredictTab extends ConsumerWidget {
  const _PredictTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prediction = ref.watch(selectedPredictionProvider);
    final matches = ref.watch(upcomingPredictionMatchesProvider);

    if (prediction != null) {
      return _PredictionView(prediction: prediction);
    }

    if (matches.isEmpty) {
      return const _EmptyPredictView();
    }

    return _MatchPicker(matches: matches);
  }
}

class _PredictionView extends ConsumerWidget {
  const _PredictionView({required this.prediction});
  final MatchPredictionEntity prediction;

@override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(predictionNotifierProvider);
    final isSaving = state is PredictionLoaded && state.isSaving;
    return ResponsiveContainer(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          PredictionBreakdownCard(prediction: prediction),
          const SizedBox(height: 8),
          _ActionsCard(isSaving: isSaving),
          const SizedBox(height: 8),
          const ComparisonInputCard(),
        ],
      ),
    );
  }
}

class _ActionsCard extends ConsumerWidget {
  const _ActionsCard({required this.isSaving});
  final bool isSaving;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Community & Tracking'),
            const SizedBox(height: 8),
            const VoteWidget(),
            const SizedBox(height: 8),
            Text(
              'Save this prediction to your history to track AI accuracy '
              'against the actual result.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: isSaving
                        ? null
                        : () => _savePrediction(context, ref),
                    icon: isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.bookmark_add_outlined),
                    label: Text(isSaving ? 'Saving…' : 'Save to History'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePrediction(BuildContext context, WidgetRef ref) async {
    final message = await ref
        .read(predictionNotifierProvider.notifier)
        .savePredictionToHistory();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message ?? 'Prediction saved successfully')),
    );
  }
}

class _HistoryTab extends ConsumerWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(predictionHistoryProvider);
    final accuracy = ref.watch(accuracyStatsProvider);

    if (history.isEmpty) {
      return const _EmptyState(
        icon: Icons.history,
        title: 'No prediction history yet',
        message: 'Generate a prediction and save it to track accuracy.',
      );
    }

return ResponsiveContainer(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          if (accuracy != null)
            _AccuracySummaryCard(accuracy: accuracy),
          ...history.map((h) => HistoryCard(history: h)),
        ],
      ),
    );
  }
}

class _AccuracyTab extends ConsumerWidget {
  const _AccuracyTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comparisons = ref.watch(comparisonListProvider);
    final accuracy = ref.watch(accuracyStatsProvider);

    if (comparisons.isEmpty) {
      return const _EmptyState(
        icon: Icons.track_changes,
        title: 'No comparisons yet',
        message:
            'After a match finishes, run a post-match comparison to see '
            'how the AI performed.',
      );
    }

return ResponsiveContainer(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          if (accuracy != null)
            _AccuracySummaryCard(accuracy: accuracy),
          ...comparisons.map((c) => ComparisonCard(comparison: c)),
        ],
      ),
    );
  }
}

class _AccuracySummaryCard extends StatelessWidget {
  const _AccuracySummaryCard({required this.accuracy});
  final AccuracyStatsEntity accuracy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = accuracy.accuracyPercentage;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ConfidenceGauge(confidence: pct, size: 80),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Overall Accuracy', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    '${accuracy.correctPredictions} correct of '
                    '${accuracy.totalPredictions} predicted '
                    '(${accuracy.incorrectPredictions} incorrect)',
                    style: theme.textTheme.bodyMedium,
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

class _MatchPicker extends ConsumerWidget {
  const _MatchPicker({required this.matches});
  final List<MatchEntity> matches;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
return ResponsiveContainer(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Select a match to generate its AI prediction',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          ...matches.map(
            (m) => Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.sports_soccer_outlined),
                title: Text('${m.homeTeam.name} vs ${m.awayTeam.name}'),
                subtitle: Text(m.competitionName ?? 'Match'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => ref
                    .read(predictionNotifierProvider.notifier)
                    .loadPredictionForMatch(m.id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPredictView extends StatelessWidget {
  const _EmptyPredictView();

  @override
  Widget build(BuildContext context) {
    return const _EmptyState(
      icon: Icons.auto_awesome,
      title: 'No matches available',
      message:
          'Upcoming matches will appear here so you can generate AI '
          'predictions for them.',
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

@override
  Widget build(BuildContext context) {
    return EmptyStateView(
      icon: icon,
      title: title,
      message: message,
    );
  }
}

class _ErrorView extends ConsumerWidget {
  const _ErrorView({required this.message});
  final String message;

@override
  Widget build(BuildContext context, WidgetRef ref) {
    return ErrorStateView(
      message: message,
      onRetry: () =>
          ref.read(predictionNotifierProvider.notifier).loadDashboard(),
    );
  }
}
