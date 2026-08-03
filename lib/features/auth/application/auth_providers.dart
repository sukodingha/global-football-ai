import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/biometric_service.dart';
import '../data/dependency_injection.dart';
import '../domain/entities/user_entity.dart';
import 'auth_notifier.dart';
import 'auth_state.dart';

/// Provider exposing the [AuthNotifier] controller.
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginWithEmail: ref.watch(loginWithEmailUseCaseProvider),
    registerWithEmail: ref.watch(registerWithEmailUseCaseProvider),
    googleSignIn: ref.watch(googleSignInUseCaseProvider),
    appleSignIn: ref.watch(appleSignInUseCaseProvider),
    sendPhoneVerificationCode: ref.watch(sendPhoneVerificationCodeUseCaseProvider),
    verifyPhoneOtp: ref.watch(verifyPhoneOtpUseCaseProvider),
    forgotPassword: ref.watch(forgotPasswordUseCaseProvider),
    biometricLogin: ref.watch(biometricLoginUseCaseProvider),
    getCurrentUser: ref.watch(getCurrentUserUseCaseProvider),
    logout: ref.watch(logoutUseCaseProvider),
    watchAuthState: ref.watch(watchAuthStateUseCaseProvider),
    biometricService: ref.watch(biometricServiceProvider),
  );
});

/// Selector for the current authenticated user.
final currentUserProvider = Provider<UserEntity?>((ref) {
  final state = ref.watch(authNotifierProvider);
  if (state is AuthAuthenticated) {
    return state.user;
  }
  return null;
});

/// Selector for whether the user is authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

/// Selector for the current auth state.
final authStateProvider = Provider<AuthState>((ref) {
  return ref.watch(authNotifierProvider);
});

/// Provider for biometric availability.
final biometricAvailabilityProvider = FutureProvider<bool>((ref) async {
  final biometricService = ref.watch(biometricServiceProvider);
  return biometricService.isBiometricAvailable() &&
      await biometricService.hasEnrolledBiometrics();
});
