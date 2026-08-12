import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/application/auth_providers.dart';
import 'features/home/application/home_providers.dart';

/// Root application widget.
class GlobalFootballAIApp extends ConsumerWidget {
  const GlobalFootballAIApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ensure session restore kicks off once at startup.
    ref.read(authNotifierProvider.notifier).restoreSession();

    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Global Football AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
