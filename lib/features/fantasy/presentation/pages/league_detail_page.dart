import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/state_views.dart';
import '../../application/fantasy_providers.dart';
import '../../application/fantasy_state.dart';
import '../../domain/entities/fantasy_league_entity.dart';
import '../../domain/entities/leaderboard_entry_entity.dart';
import '../widgets/leaderboard_table.dart';

/// Displays a single league's details, its join code and its leaderboard.
class LeagueDetailPage extends ConsumerWidget {
  const LeagueDetailPage({super.key, required this.leagueId});

  final String leagueId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fantasyNotifierProvider);
    final league = state is FantasyLoaded
        ? state.selectedLeague
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('League Details')),
      body: switch (state) {
        FantasyInitial() || FantasyLoading() =>
          const Center(child: CircularProgressIndicator()),
        FantasyError(:final message) => ErrorStateView(message: message),
        FantasyLoaded() => _LeagueDetail(
            league: league,
            leaderboard: state.leagueLeaderboard,
            currentTeamId: state.currentTeam?.id,
          ),
      },
    );
  }
}

class _LeagueDetail extends StatelessWidget {
  const _LeagueDetail({
    required this.league,
    required this.leaderboard,
    required this.currentTeamId,
  });

  final FantasyLeagueEntity? league;
  final List<LeaderboardEntryEntity> leaderboard;
  final String? currentTeamId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (league == null) {
      return const EmptyStateView(
        icon: Icons.emoji_events_outlined,
        title: 'No league selected',
        message: 'Select a league from the hub to view its details.',
      );
    }

    final l = league!;
    return ResponsiveContainer(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        l.isPublic ? Icons.public : Icons.lock_outline,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l.name,
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join Code: ${l.code}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${l.memberCount} members · Budget £${l.startBudget.toStringAsFixed(0)}M',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.outline),
                  ),
                  if (l.description != null) ...[
                    const SizedBox(height: 8),
                    Text(l.description!, style: theme.textTheme.bodyMedium),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text('League Standings', style: theme.textTheme.titleMedium),
          ),
          if (leaderboard.isEmpty)
            const EmptyStateView(
              icon: Icons.leaderboard_outlined,
              title: 'No entries yet',
              message: 'Standings will appear as teams join and score points.',
            )
          else
            LeaderboardTable(
              entries: leaderboard,
              highlightTeamId: currentTeamId,
            ),
        ],
      ),
    );
  }
}
