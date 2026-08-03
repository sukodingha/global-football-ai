import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dependency_injection.dart';
import 'home_notifier.dart';
import 'home_state.dart';

/// Provides the [HomeNotifier] wired to the repository.
final homeNotifierProvider =
    StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return HomeNotifier(repository: repository);
});

/// Provides the current theme mode.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
