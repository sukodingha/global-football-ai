import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/state_views.dart';
import '../../application/sports_feed_notifier.dart';
import '../../application/sports_feed_providers.dart';
import '../../application/sports_feed_state.dart';
import '../../domain/entities/sport_event_entity.dart';
import '../widgets/sport_event_card.dart';

/// Multi-sport real-time feed page with tabs for Football, Tennis, and
/// Basketball. Displays live events with automatic score/status updates.
class SportsFeedPage extends ConsumerStatefulWidget {
  const SportsFeedPage({super.key});

  @override
  ConsumerState<SportsFeedPage> createState() => _SportsFeedPageState();
}

class _SportsFeedPageState extends ConsumerState<SportsFeedPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: SportType.values.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    Future.microtask(() {
      ref.read(sportsFeedNotifierProvider.notifier).loadAll();
    });
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final sport = SportType.values[_tabController.index];
    ref.read(sportsFeedNotifierProvider.notifier).selectSport(sport);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sportsFeedNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Scores'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(sportsFeedNotifierProvider.notifier).refresh();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            for (final sport in SportType.values)
              Tab(text: sport.label),
          ],
        ),
      ),
      body: switch (state) {
        SportsFeedInitial() || SportsFeedLoading() =>
          const Center(child: CircularProgressIndicator()),
        SportsFeedError(:final message) => _ErrorView(
            message: message,
            onRetry: () {
              ref.read(sportsFeedNotifierProvider.notifier).loadAll();
            },
          ),
        SportsFeedLoaded() => _FeedBody(
            events: ref.watch(selectedSportEventsProvider),
            lastUpdated: state.lastUpdated,
            stale: state.stale,
          ),
      },
    );
  }
}

class _FeedBody extends ConsumerWidget {
  const _FeedBody({
    required this.events,
    required this.lastUpdated,
    required this.stale,
  });

  final List<SportEventEntity> events;
  final DateTime? lastUpdated;
  final bool stale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSport = ref.watch(selectedSportProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(sportsFeedNotifierProvider.notifier).refresh();
      },
      child: Column(
        children: [
          _UpdateBanner(lastUpdated: lastUpdated, stale: stale),
          Expanded(
            child: events.isEmpty
                ? _EmptyView(sport: selectedSport)
                : ResponsiveContainer(
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return SportEventCard(event: event);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _UpdateBanner extends StatelessWidget {
  const _UpdateBanner({required this.lastUpdated, required this.stale});
  final DateTime? lastUpdated;
  final bool stale;

  @override
  Widget build(BuildContext context) {
    final updated = lastUpdated == null
        ? ''
        : 'Updated ${DateFormat('HH:mm:ss').format(lastUpdated!.toLocal())}';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
color: stale
          ? Colors.orange.withOpacity(0.15)
          : Colors.transparent,
      child: Row(
        children: [
          Icon(
            stale ? Icons.cloud_off : Icons.cloud_done,
            size: 16,
            color: stale ? Colors.orange : Colors.green,
          ),
          const SizedBox(width: 6),
          Text(
            stale ? 'Live updates paused' : (updated.isEmpty ? 'Live' : updated),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ErrorStateView(
      message: message,
      onRetry: onRetry,
      icon: Icons.cloud_off,
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.sport});
  final SportType sport;

  @override
  Widget build(BuildContext context) {
    final icon = switch (sport) {
      SportType.football => Icons.sports_soccer,
      SportType.tennis => Icons.sports_tennis,
      SportType.basketball => Icons.sports_basketball,
    };
    return EmptyStateView(
      icon: icon,
      title: 'No live ${sport.label.toLowerCase()} events right now',
      message: 'Check back shortly — live events will appear here.',
    );
  }
}

