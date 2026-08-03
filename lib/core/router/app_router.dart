import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';
import '../../features/auth/application/auth_providers.dart';
import '../../features/auth/application/auth_state.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/auth/presentation/pages/phone_login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/livescore/presentation/pages/live_scores_page.dart';
import '../../features/livescore/presentation/pages/match_detail_page.dart';
import '../../home_shell.dart';
import 'splash_screen.dart';

/// A [ChangeNotifier] that notifies when the auth state changes,
/// allowing the router to re-evaluate redirects.
class AuthRefreshNotifier extends ChangeNotifier {
  AuthRefreshNotifier(this._ref) {
    _ref.listen(authNotifierProvider, (_, __) {
      notifyListeners();
    });
  }

  final Ref _ref;
}

/// Router provider that reacts to authentication state.
final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = AuthRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  final router = GoRouter(
      initialLocation: AppConstants.routeSplash,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final isLoggingIn = authState is AuthLoading || authState is AuthInitial;

      // While loading, keep on splash.
      if (isLoggingIn) {
        return AppConstants.routeSplash;
      }

      final isAuthenticated = authState is AuthAuthenticated;
      final isAuthRoute = state.matchedLocation == AppConstants.routeLogin ||
          state.matchedLocation == AppConstants.routeRegister ||
          state.matchedLocation == AppConstants.routeForgotPassword ||
          state.matchedLocation == AppConstants.routePhoneLogin ||
          state.matchedLocation == AppConstants.routeOtpVerification;

      if (!isAuthenticated && !isAuthRoute) {
        // Redirect to login if not authenticated and not on an auth page.
        return AppConstants.routeLogin;
      }

      if (isAuthenticated && isAuthRoute) {
        // Redirect authenticated users away from auth pages.
        return AppConstants.routeHome;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppConstants.routeSplash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppConstants.routeLogin,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppConstants.routeRegister,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppConstants.routeForgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppConstants.routePhoneLogin,
        name: 'phone-login',
        builder: (context, state) => const PhoneLoginPage(),
      ),
      GoRoute(
        path: AppConstants.routeOtpVerification,
        name: 'otp-verification',
        builder: (context, state) => OtpVerificationPage(
          verificationId: state.extra as String,
        ),
      ),
GoRoute(
        path: AppConstants.routeHome,
        name: 'home',
        builder: (context, state) => const HomeShell(),
      ),
      GoRoute(
        path: AppConstants.routeLiveScores,
        name: 'live-scores',
        builder: (context, state) => const LiveScoresPage(),
      ),
      GoRoute(
        path: '${AppConstants.routeMatchDetail}/:matchId',
        name: 'match-detail',
        builder: (context, state) {
          final matchId = int.tryParse(state.pathParameters['matchId'] ?? '');
          return MatchDetailPage(
            matchId: matchId ?? 0,
            competitionId: state.extra is int ? state.extra as int : null,
          );
        },
      ),
    ],
  );

  return router;
});
