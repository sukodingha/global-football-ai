import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/livescore_notifier.dart';
import '../../application/livescore_providers.dart';
import '../../application/livescore_state.dart';
import '../widgets/fixtures_view.dart';
import '../widgets/heatmap_view.dart';
import '../widgets/lineups_view.dart';
import '../widgets/match_events_view.dart';
import '../widgets/match_statistics_view.dart';
import '../widgets/match_timeline_view.dart';
import '../widgets/standings_view.dart';

/// Match Detail page with tabs for Timeline, Lineups, Statistics,
/// Events, Heatmap, Standings, and Fixtures.
class MatchDetailPage extends ConsumerStatefulWidget {
  const MatchDetailPage({
    super.key,
    required this.matchId,
    this.competitionId,
  });

  final int matchId;
  final int? competitionId;

  @override
  ConsumerState<MatchDetailPage> createState() => _MatchDetailPageState();
}

class _MatchDetailPageState extends ConsumerState<MatchDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    final notifier = ref.read(livescoreNotifierProvider.notifier);
    Future.microtask(() {
      notifier.loadMatchDetail(widget.matchId);
      if (widget.competitionId != null) {
        notifier.loadStandings(widget.competitionId!);
        notifier.loadFixtures(widget.competitionId!);
      } else {
        notifier.loadStandings(2021); // Default: Premier League
        notifier.loadFixtures(2021);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(livescoreNotifierProvider);
    final detail = ref.watch(matchDetailProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Details'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Timeline'),
            Tab(text: 'Lineups'),
            Tab(text: 'Stats'),
            Tab(text: 'Events'),
            Tab(text: 'Heatmap'),
            Tab(text: 'Standings'),
            Tab(text: 'Fixtures'),
          ],
        ),
      ),
      body: switch (state) {
        LivescoreInitial() || LivescoreLoading() =>
          const Center(child: CircularProgressIndicator()),
        LivescoreError(:final message) => _ErrorView(message: message),
        LivescoreLoaded() => TabBarView(
            controller: _tabController,
            children: [
              MatchTimelineView(
                events: ref.watch(timelineProvider),
                homeTeamId: detail?.match.homeTeam.id,
                awayTeamId: detail?.match.awayTeam.id,
              ),
              LineupsView(
                lineups: ref.watch(lineupsProvider) ??
                    const MatchLineupEntity(
                      homeTeam: [],
                      awayTeam: [],
                      formation: '4-3-3',
                    ),
                homeName: detail?.match.homeTeam.name ?? 'Home',
                awayName: detail?.match.awayTeam.name ?? 'Away',
              ),
              MatchStatisticsView(
                statistics: ref.watch(statisticsProvider),
                homeName: detail?.match.homeTeam.name ?? 'Home',
                awayName: detail?.match.awayTeam.name ?? 'Away',
              ),
              MatchEventsView(
                events: ref.watch(timelineProvider),
                homeTeamId: detail?.match.homeTeam.id,
                awayTeamId: detail?.match.awayTeam.id,
              ),
              HeatmapView(
                points: ref.watch(homeHeatmapProvider),
                homeName: detail?.match.homeTeam.name ?? 'Home',
                awayName: detail?.match.awayTeam.name ?? 'Away',
              ),
              StandingsView(
                rows: ref.watch(standingsProvider),
                competitionName: 'Competition Standings',
              ),
              FixturesView(
                fixtures: ref.watch(fixturesProvider),
              ),
            ],
          ),
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
