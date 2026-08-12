import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:global_ai_prediction/features/home/presentation/pages/home_page.dart';
import 'package:global_ai_prediction/features/livescore/presentation/pages/sports_feed_page.dart';

import '../test_helpers/fake_repositories.dart';

/// Uses a tall logical viewport so the lazily-built Home dashboard renders
/// all of its sections (including those below the fold).
void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// A minimal shell mirroring the app's bottom navigation for the two main
/// screens (Home dashboard and Live Sports Feed). This verifies that the
/// screens work together under a shared [ProviderScope] and that tab
/// switching preserves each screen's state.
class _TestShell extends StatefulWidget {
  const _TestShell();

  @override
  State<_TestShell> createState() => _TestShellState();
}

class _TestShellState extends State<_TestShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [HomePage(), SportsFeedPage()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.sports_soccer),
            label: 'Matches',
          ),
        ],
      ),
    );
  }
}

void main() {
  testWidgets('switching tabs navigates between Home and Sports Feed',
      (tester) async {
    _useTallSurface(tester);
    final homeRepo = loadedHomeRepository();
    final sportRepo = loadedSportsRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...homeRepositoryOverrides(homeRepo),
          ...multiSportRepositoryOverrides(sportRepo),
        ],
        child: const MaterialApp(home: _TestShell()),
      ),
    );
    await tester.pumpAndSettle();

    // Home screen is shown first.
    expect(find.text('Global Football AI'), findsOneWidget);
    expect(find.text('Live Matches'), findsOneWidget);

// Navigate to the Matches tab (tap the navigation destination label).
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Matches'),
      ).first,
    );
    await tester.pumpAndSettle();

    // Sports feed is now visible.
    expect(find.text('Live Scores'), findsOneWidget);
    expect(find.text('Football'), findsOneWidget);
    expect(find.text('Team One'), findsWidgets);

    // Navigate back to Home.
    await tester.tap(find.byIcon(Icons.home));
    await tester.pumpAndSettle();

    // Home content is restored from the IndexedStack.
    expect(find.text('Global Football AI'), findsOneWidget);
    expect(find.text('Latest News'), findsOneWidget);
  });

testWidgets('both screens render their loaded data without errors',
      (tester) async {
    _useTallSurface(tester);
    final homeRepo = loadedHomeRepository();
    final sportRepo = loadedSportsRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...homeRepositoryOverrides(homeRepo),
          ...multiSportRepositoryOverrides(sportRepo),
        ],
        child: const MaterialApp(home: _TestShell()),
      ),
    );
    await tester.pumpAndSettle();

    // Assert no exceptions were thrown during the build.
    expect(tester.takeException(), isNull);

    // Home dashboard content present.
    expect(find.text('Big Transfer News'), findsOneWidget);
    expect(find.text('Star Player'), findsOneWidget);
  });
}
