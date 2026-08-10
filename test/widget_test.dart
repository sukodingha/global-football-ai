// Basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:global_football_ai/app.dart';

void main() {
  testWidgets('app builds and renders the root widget', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: GlobalFootballAIApp(),
      ),
    );
    await tester.pump();

    // The root app widget is present (no MyApp / missing-URI reference).
    expect(find.byType(GlobalFootballAIApp), findsOneWidget);
  });
}
