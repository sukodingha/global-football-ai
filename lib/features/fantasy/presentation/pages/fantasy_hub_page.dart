import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../application/fantasy_providers.dart';
import '../../application/fantasy_state.dart';
import '../../domain/entities/fantasy_league_entity.dart';
import '../widgets/create_league_dialog.dart';
import '../widgets/join_league_dialog.dart';
import '../widgets/league_card.dart';
import '../widgets/team_card.dart';
import 'league_detail_page.dart';
import 'player_stats_hub_page.dart';
import 'team_management_page.dart';

/// Main fantasy football hub.
///
/// Provides tabs for Leagues, My Team, Leaderboard and Player Stats, plus
/// actions to create/join leagues.
class FantasyHubPage extends ConsumerStatefulWidget {
  const FantasyHubPage({super.key});

  @override
  ConsumerState<FantasyHubPage> createState() => _FantasyHubPageState();
}

class _FantasyHubPageState extends ConsumerState<FantasyHubPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _createLeague(UserEntity user) async {
    final result = await showCreateLeagueDialog(context);
    if (result == null || !mounted) return;

    final leagueResult = await ref
        .read(fantasyNotifierProvider.notifier)
        .createLeague(
          name: result['name'] as String,
          visibility: result['visibility'] as LeagueVisibility,
          ownerId: user.id,
          description: result['description'] as String?,
          teamName: result['teamName'] as String,
          startBudget: result['startBudget'] as double,
        );

    if (!mounted) return;
    if (leagueResult.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('League created! Invite friends with the code.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create league: ${leagueResult.failure?.message}')),
      );
    }
  }

  Future<void> _joinLeague(UserEntity user) async {
    final result = await showJoinLeagueDialog(context);
    if (result == null || !mounted) return;

    final leagueResult = await ref
        .read(fantasyNotifierProvider.notifier)
        .joinLeague(
          code: result['code'] as String,
          userId: user.id,
          userName: user.displayName ?? 'User',
          teamName: result['teamName'] as String,
        );

    if (!mounted) return;
    if (leagueResult.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Joined league! Now build your team.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not join: ${leagueResult.failure?.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    ref.watch(fantasyDashboardControllerProvider);

    final state = ref.watch(fantasyNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fantasy Football'),
        actions: [
          IconButton(
            tooltip: 'Player Stats',
            icon: const Icon(Icons.assessment_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const PlayerStatsHubPage()),
            ),
          ),
        ],
      ),
      floatingActionButton: state is FantasyLoaded
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'join',
                  onPressed: user != null ? () => _joinLeague(user) : null,
                  tooltip: 'Join league',
                  child: const Icon(Icons.group_add_outlined),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'create',
                  onPressed: user != null ? () => _createLeague(user) : null,
                  tooltip: 'Create league',
                  child: const Icon(Icons.add),
                ),
              ],
            )
          : null,
      body: switch (state) {
        FantasyInitial() || FantasyLoading() =>
          const Center(child: CircularProgressIndicator()),
        FantasyError(:final message) => _ErrorView(message: message),
        FantasyLoaded() => _HubView(
            state: state,
            onLeagueTap: (league) => _openLeague(context, league),
            onTeamTap: (teamId) => _openTeam(context),
          ),
      },
    );
  }

  void _openLeague(BuildContext context, FantasyLeagueEntity league) {
    ref.read(fantasyNotifierProvider.notifier).selectLeague(league.id);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LeagueDetailPage(leagueId: league.id),
      ),
    );
  }

  void _openTeam(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const TeamManagementPage()),
    );
  }
}

class _HubView extends ConsumerWidget {
  const _HubView({
    required this.state,
    required this.onLeagueTap,
    required this.onTeamTap,
  });

  final FantasyLoaded state;
  final ValueChanged<FantasyLeagueEntity> onLeagueTap;
  final VoidCallback onTeamTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentTeam = state.currentTeam;
    final publicLeagues = state.publicLeagues;

    return ResponsiveContainer(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('My Leagues', style: theme.textTheme.titleMedium),
          ),
          if (state.leagues.isEmpty)
            const _EmptyLeagues()
          else
            for (final league in state.leagues)
              LeagueCard(
                league: league,
                isSelected: state.selectedLeague?.id == league.id,
                onTap: () => onLeagueTap(league),
              ),
          if (currentTeam != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('My Team', style: theme.textTheme.titleMedium),
            ),
            TeamCard(team: currentTeam, onTap: onTeamTap),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text('Discover Leagues', style: theme.textTheme.titleMedium),
          ),
          if (publicLeagues.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No public leagues available yet. Create one to start!'),
            )
          else
            for (final league in publicLeagues.take(5))
              LeagueCard(
                league: league,
                onTap: () => onLeagueTap(league),
              ),
        ],
      ),
    );
  }
}

class _EmptyLeagues extends StatelessWidget {
  const _EmptyLeagues();

  @override
  Widget build(BuildContext context) {
    return const EmptyStateView(
      icon: Icons.emoji_events_outlined,
      title: 'No leagues yet',
      message: 'Create a league or join one with a code to start playing.',
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return ErrorStateView(message: message);
  }
}
