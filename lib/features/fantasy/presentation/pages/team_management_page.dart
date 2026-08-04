import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/state_views.dart';
import '../../application/fantasy_providers.dart';
import '../../application/fantasy_state.dart';
import '../../domain/entities/fantasy_player_entity.dart';
import '../../domain/entities/fantasy_team_entity.dart';
import '../widgets/captain_badge.dart';
import '../widgets/player_pick_card.dart';

/// Team management screen: view squad, make transfers, assign captain and
/// vice captain, and monitor budget.
class TeamManagementPage extends ConsumerWidget {
  const TeamManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fantasyNotifierProvider);
    final busy = ref.watch(fantasyBusyProvider);
    final error = ref.watch(fantasyErrorProvider);
    final pool = ref.watch(playerPoolProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Team')),
      body: switch (state) {
        FantasyInitial() || FantasyLoading() =>
          const Center(child: CircularProgressIndicator()),
        FantasyError(:final message) => ErrorStateView(message: message),
        FantasyLoaded() => _TeamView(
            team: state.currentTeam,
            pool: pool,
            busy: busy,
            error: error,
          ),
      },
    );
  }
}

class _TeamView extends ConsumerWidget {
  const _TeamView({
    required this.team,
    required this.pool,
    required this.busy,
    required this.error,
  });

  final FantasyTeamEntity? team;
  final List<FantasyPlayerEntity> pool;
  final bool busy;
  final String? error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    if (team == null) {
      return const EmptyStateView(
        icon: Icons.shield_outlined,
        title: 'No team yet',
        message: 'Create or join a league from the hub to start building.',
      );
    }

    final squad = team!.players;
    final captainId = team!.captainId;
    final viceCaptainId = team!.viceCaptainId;

    return ResponsiveContainer(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _BudgetHeader(team: team!, busy: busy),
          if (error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                error!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'Your Squad (${squad.length}/11)',
              style: theme.textTheme.titleMedium,
            ),
          ),
          if (squad.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Your squad is empty. Add players from the market below.',
              ),
            )
          else
            for (final player in squad)
              PlayerPickCard(
                player: player,
                isInSquad: true,
                isCaptain: player.id.toString() == captainId,
                isViceCaptain: player.id.toString() == viceCaptainId,
                canRemove: true,
                onRemove: () => _remove(ref, player.id),
                onSetCaptain: () => _setCaptain(ref, player.id),
                onSetViceCaptain: () => _setViceCaptain(ref, player.id),
              ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text('Captain & Vice Captain', style: theme.textTheme.titleMedium),
          ),
          const _LeadershipHint(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text('Transfer Market', style: theme.textTheme.titleMedium),
          ),
          ..._availablePool(pool, squad).map(
            (p) => PlayerPickCard(
              player: p,
              isInSquad: false,
              onAdd: () => _add(ref, p),
            ),
          ),
        ],
      ),
    );
  }

  List<FantasyPlayerEntity> _availablePool(
    List<FantasyPlayerEntity> pool,
    List<FantasyPlayerEntity> squad,
  ) {
    final squadIds = squad.map((p) => p.id).toSet();
    // Only show players the user can afford (or is nearly afforable).
    final budget = team?.budgetRemaining ?? 0;
    return pool.where((p) => !squadIds.contains(p.id)).toList()
      ..sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
  }

  Future<void> _add(WidgetRef ref, FantasyPlayerEntity player) async {
    final message = await ref.read(fantasyNotifierProvider.notifier).addPlayer(player);
    if (message != null) _showSnack(ref.context, message);
  }

  Future<void> _remove(WidgetRef ref, int playerId) async {
    final message =
        await ref.read(fantasyNotifierProvider.notifier).removePlayer(playerId);
    if (message != null) _showSnack(ref.context, message);
  }

  Future<void> _setCaptain(WidgetRef ref, int playerId) async {
    final message =
        await ref.read(fantasyNotifierProvider.notifier).setCaptain(playerId);
    if (message != null) _showSnack(ref.context, message);
  }

  Future<void> _setViceCaptain(WidgetRef ref, int playerId) async {
    final message =
        await ref.read(fantasyNotifierProvider.notifier).setViceCaptain(playerId);
    if (message != null) _showSnack(ref.context, message);
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _BudgetHeader extends StatelessWidget {
  const _BudgetHeader({required this.team, required this.busy});
  final FantasyTeamEntity team;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.savings_outlined, color: scheme.primary),
                const SizedBox(width: 8),
                Text('Team Value & Budget', style: theme.textTheme.titleSmall),
                const Spacer(),
                if (busy)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _Stat(
                  label: 'Value',
                  value: '£${team.playersValue.toStringAsFixed(1)}M',
                ),
                _Stat(
                  label: 'Budget Left',
                  value: '£${team.budgetRemaining.toStringAsFixed(1)}M',
                ),
                _Stat(
                  label: 'Points',
                  value: team.totalPoints.toStringAsFixed(0),
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
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _LeadershipHint extends StatelessWidget {
  const _LeadershipHint();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          const CaptainBadge(role: 'C'),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Captain earns 2x points. Vice Captain earns 1.5x if the captain does not play.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
          ),
        ],
      ),
    );
  }
}
