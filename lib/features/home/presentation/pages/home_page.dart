import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/state_views.dart';
import '../../application/home_providers.dart';
import '../../application/home_state.dart';
import '../../domain/entities/article_entity.dart';
import '../../domain/entities/competition_entity.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/entities/player_entity.dart';
import '../../domain/entities/prediction_entity.dart';
import '../widgets/competition_card.dart';
import '../widgets/live_match_card.dart';
import '../widgets/match_card.dart';
import '../widgets/news_card.dart';
import '../widgets/player_of_day_card.dart';
import '../widgets/prediction_summary_card.dart';

/// The main Home dashboard page.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeNotifierProvider.notifier).loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Football AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(homeNotifierProvider.notifier).refresh(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: switch (state) {
        HomeInitial() => const SizedBox.shrink(),
        HomeLoading() => const Center(child: CircularProgressIndicator()),
        HomeError(:final message) => _ErrorView(message: message),
        HomeLoaded() => _DashboardView(state: state),
      },
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
      onRetry: () => ref.read(homeNotifierProvider.notifier).refresh(),
    );
  }
}

class _DashboardView extends ConsumerWidget {
  const _DashboardView({required this.state});
  final HomeLoaded state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveMatches = state.liveMatches;
    final upcomingMatches = state.upcomingMatches;
    final trendingMatches = state.trendingMatches;
    final news = state.news;
    final competitions = state.competitions;
    final predictions = state.predictions;
    final playerOfTheDay = state.playerOfTheDay;

    return RefreshIndicator(
      onRefresh: () => ref.read(homeNotifierProvider.notifier).refresh(),
      child: ResponsiveContainer(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            PredictionSummaryCard(predictions: predictions),
            const SizedBox(height: 16),

            if (liveMatches.isNotEmpty) ...[
              const _SectionTitle('Live Matches'),
              const SizedBox(height: 8),
              ...liveMatches.map((m) => LiveMatchCard(match: m)),
              const SizedBox(height: 16),
            ],

            if (upcomingMatches.isNotEmpty) ...[
              const _SectionTitle('Upcoming Matches'),
              const SizedBox(height: 8),
              ...upcomingMatches.take(5).map((m) => MatchCard(match: m)),
              const SizedBox(height: 16),
            ],

            if (trendingMatches.isNotEmpty) ...[
              const _SectionTitle('Trending'),
              const SizedBox(height: 8),
              ...trendingMatches.take(5).map((m) => MatchCard(match: m)),
              const SizedBox(height: 16),
            ],

            if (competitions.isNotEmpty) ...[
              const _SectionTitle('Competitions'),
              const SizedBox(height: 8),
              _CompetitionCarousel(competitions: competitions),
              const SizedBox(height: 16),
            ],

            if (playerOfTheDay != null) ...[
              const _SectionTitle('Player of the Day'),
              const SizedBox(height: 8),
              PlayerOfDayCard(player: playerOfTheDay),
              const SizedBox(height: 16),
            ],

            if (news.isNotEmpty) ...[
              const _SectionTitle('Latest News'),
              const SizedBox(height: 8),
              ...news.take(5).map((n) => NewsCard(article: n)),
            ],
          ],
        ),
      ),
    );
  }
}

class _CompetitionCarousel extends StatelessWidget {
  const _CompetitionCarousel({required this.competitions});
  final List<CompetitionEntity> competitions;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: competitions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) =>
            CompetitionCard(competition: competitions[index]),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}
