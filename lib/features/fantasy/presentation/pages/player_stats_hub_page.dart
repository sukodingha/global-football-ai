import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/responsive_layout.dart';
import '../../application/fantasy_providers.dart';
import '../../application/fantasy_state.dart';
import '../../domain/entities/fantasy_player_entity.dart';
import '../widgets/player_pick_card.dart';
import '../widgets/points_breakdown.dart';

/// Player statistics hub.
///
/// Shows all players available for fantasy selection with their live prices,
/// total fantasy points, and detailed stats. Users can filter by position
/// and tap a player to see a full points breakdown.
class PlayerStatsHubPage extends ConsumerStatefulWidget {
  const PlayerStatsHubPage({super.key});

  @override
  ConsumerState<PlayerStatsHubPage> createState() => _PlayerStatsHubPageState();
}

class _PlayerStatsHubPageState extends ConsumerState<PlayerStatsHubPage> {
  final _searchController = TextEditingController();
  FantasyPosition? _positionFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fantasyNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Stats'),
        actions: [
          PopupMenuButton<FantasyPosition?>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter by position',
            initialValue: _positionFilter,
            onSelected: (p) => setState(() => _positionFilter = p),
            children: [
              const PopupMenuItem(value: null, child: Text('All')),
              ...FantasyPosition.values.map(
                (p) => PopupMenuItem(
                  value: p,
                  child: Text(p.displayName),
                ),
              ),
            ],
          ),
        ],
      ),
      body: switch (state) {
        FantasyInitial() || FantasyLoading() =>
          const Center(child: CircularProgressIndicator()),
        FantasyError() => const Center(
            child: Text('Could not load player stats.'),
          ),
        FantasyLoaded() => _PlayerStatsView(
            pool: state.playerPool,
            searchQuery: _searchController.text,
            positionFilter: _positionFilter,
          ),
      },
    );
  }
}

class _PlayerStatsView extends StatelessWidget {
  const _PlayerStatsView({
    required this.pool,
    required this.searchQuery,
    required this.positionFilter,
  });

  final List<FantasyPlayerEntity> pool;
  final String searchQuery;
  final FantasyPosition? positionFilter;

  @override
  Widget build(BuildContext context) {
    final filtered = _applyFilters();

    return ResponsiveContainer(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: null,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search players...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
              onChanged: (v) {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${filtered.length} players available',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text('No players match your filters.'),
            )
          else
            for (final player in filtered)
              _PlayerStatsCard(
                player: player,
                onTap: () => _showBreakdown(context, player),
              ),
        ],
      ),
    );
  }

  List<FantasyPlayerEntity> _applyFilters() {
    var result = pool;

    if (positionFilter != null) {
      result = result.where((p) => p.position == positionFilter).toList();
    }

    // Sort by total points descending, then by price descending.
    result = result.toList()
      ..sort((a, b) {
        final pointCmp = b.totalPoints.compareTo(a.totalPoints);
        if (pointCmp != 0) return pointCmp;
        return b.price.compareTo(a.price);
      });

    return result;
  }

  void _showBreakdown(
    BuildContext context,
    FantasyPlayerEntity player,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  player.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  '${player.team} · ${player.position.displayName} · £${player.price.toStringAsFixed(1)}M',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 16),
                PointsBreakdown(player: player),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayerStatsCard extends StatelessWidget {
  const _PlayerStatsCard({required this.player, required this.onTap});
  final FantasyPlayerEntity player;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final posColor = switch (player.position) {
      FantasyPosition.goalkeeper => Colors.yellow.shade700,
      FantasyPosition.defender => Colors.blue,
      FantasyPosition.midfielder => Colors.green,
      FantasyPosition.forward => Colors.red,
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: posColor.withOpacity(0.2),
          child: Text(
            player.position.displayName[0].toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: posColor,
            ),
          ),
        ),
        title: Text(player.name, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          '${player.team} · £${player.price.toStringAsFixed(1)}M',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              player.totalPoints.toStringAsFixed(0),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            Text('pts', style: theme.textTheme.bodySmall),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

/// Extension to display friendly names for positions.
extension FantasyPositionDisplay on FantasyPosition {
  String get displayName {
    switch (this) {
      case FantasyPosition.goalkeeper:
        return 'Goalkeeper';
      case FantasyPosition.defender:
        return 'Defender';
      case FantasyPosition.midfielder:
        return 'Midfielder';
      case FantasyPosition.forward:
        return 'Forward';
    }
  }
}
