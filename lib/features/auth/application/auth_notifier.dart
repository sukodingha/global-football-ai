import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/biometric_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/apple_sign_in.dart';
import '../../domain/usecases/biometric_login.dart';
import '../../domain/usecases/forgot_password.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/google_sign_in.dart';
import '../../domain/usecases/login_with_email.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/register_with_email.dart';
import '../../domain/usecases/send_phone_verification_code.dart';
import '../../domain/usecases/usecase.dart';
import '../../domain/usecases/verify_phone_otp.dart';
import '../../domain/usecases/watch_auth_state.dart';
import 'auth_state.dart';

/// Riverpod controller managing the authentication state and all
/// authentication flows.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({
    required LoginWithEmail loginWithEmail,
    required RegisterWithEmail registerWithEmail,
    required GoogleSignIn googleSignIn,
    required AppleSignIn appleSignIn,
    required SendPhoneVerificationCode sendPhoneVerificationCode,
    required VerifyPhoneOtp verifyPhoneOtp,
    required ForgotPassword forgotPassword,
    required BiometricLogin biometricLogin,
    required GetCurrentUser getCurrentUser,
    required Logout logout,
    required WatchAuthState watchAuthState,
    required BiometricService biometricService,
  })  : _loginWithEmail = loginWithEmail,
        _registerWithEmail = registerWithEmail,
        _googleSignIn = googleSignIn,
        _appleSignIn = appleSignIn,
        _sendPhoneVerificationCode = sendPhoneVerificationCode,
        _verifyPhoneOtp = verifyPhoneOtp,
        _forgotPassword = forgotPassword,
        _biometricLogin = biometricLogin,
        _getCurrentUser = getCurrentUser,
        _logout = logout,
        _watchAuthState = watchAuthState,
        _biometricService = biometricService,
        super(const AuthInitial()) {
    _listenToAuthState();
  }

  final LoginWithEmail _loginWithEmail;
  final RegisterWithEmail _registerWithEmail;
  final GoogleSignIn _googleSignIn;
  final AppleSignIn _appleSignIn;
  final SendPhoneVerificationCode _sendPhoneVerificationCode;
  final VerifyPhoneOtp _verifyPhoneOtp;
  final ForgotPassword _forgotPassword;
  final BiometricLogin _biometricLogin;
  final GetCurrentUser _getCurrentUser;
  final Logout _logout;
  final WatchAuthState _watchAuthState;
  final BiometricService _biometricService;

  StreamSubscription<UserEntity?>? _authSubscription;

  /// The current authenticated user, if any.
  UserEntity? get currentUser {
    final state = this.state;
    if (state is AuthAuthenticated) {
      return state.user;
    }
    return null;
  }

  /// Streams Firebase auth state changes and updates the UI state.
  void _listenToAuthState() {
    _authSubscription?.cancel();
    _authSubscription = _watchAuthState(const NoParams()).listen(
      (user) {
        if (user != null) {
          state = AuthAuthenticated(user: user);
        } else {
          state = const AuthUnauthenticated();
        }
      },
      onError: (Object error) {
        final message = error is Failure
            ? error.message
            : 'Authentication error occurred.';
        state = AuthError(message: message);
      },
    );
  }

  /// Restores the session on app startup.
  Future<void> restoreSession() async {
    try {
      final user = await _getCurrentUser(const NoParams());
      if (user != null) {
        state = AuthAuthenticated(user: user);
      } else {
        state = const AuthUnauthenticated();
      }
    } on Failure catch (f) {
      state = AuthError(message: f.message);
    } catch (_) {
      state = const AuthUnauthenticated();
    }
  }

  /// Checks whether biometric login is available.
  Future<bool> isBiometricAvailable() async {
    try {
      return await _biometricService.isBiometricAvailable() &&
          await _biometricService.hasEnrolledBiometrics();
    } catch (_) {
      return false;
    }
  }

  /// Signs in with email and password.
  Future<String?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      final user = await _loginWithEmail(
        LoginParams(email: email, password: password),
      );
      state = AuthAuthenticated(user: user);
      return null;
    } on Failure catch (f) {
      state = AuthError(message: f.message);
      return f.message;
    } catch (_) {
      final msg = 'Unable to sign in. Please try again.';
      state = AuthError(message: msg);
      return msg;
    }
  }

  /// Registers a new user with email and password.
  Future<String?> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AuthLoading();
    try {
      final user = await _registerWithEmail(
        RegisterParams(
          email: email,
          password: password,
          displayName: displayName,
        ),
      );
      state = AuthAuthenticated(user: user);
      return null;
    } on Failure catch (f) {
      state = AuthError(message: f.message);
      return f.message;
    } catch (_) {
      final msg = 'Unable to register. Please try again.';
      state = AuthError(message: msg);
      return msg;
    }
  }

  /// Signs in with Google.
  Future<String?> signInWithGoogle() async {
    state = const AuthLoading();
    try {
      final user = await _googleSignIn(const NoParams());
      state = AuthAuthenticated(user: user);
      return null;
    } on Failure catch (f) {
      state = AuthError(message: f.message);
      return f.message;
    } catch (_) {
      final msg = 'Google sign-in failed. Please try again.';
      state = AuthError(message: msg);
      return msg;
    }
  }

  /// Signs in with Apple.
  Future<String?> signInWithApple() async {
    state = const AuthLoading();
    try {
      final user = await _appleSignIn(const NoParams());
      state = AuthAuthenticated(user: user);
      return null;
    } on Failure catch (f) {
      state = AuthError(message: f.message);
      return f.message;
    } catch (_) {
      final msg = 'Apple sign-in failed. Please try again.';
      state = AuthError(message: msg);
      return msg;
    }
  }

  /// Sends a phone verification code.
  Future<String?> sendPhoneVerificationCode({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
  }) async {
    state = const AuthLoading();
    try {
      await _sendPhoneVerificationCode(
        PhoneCodeParams(phoneNumber: phoneNumber, onCodeSent: onCodeSent),
      );
      return null;
    } on Failure catch (f) {
      state = AuthError(message: f.message);
      return f.message;
    } catch (_) {
      final msg = 'Unable to send verification code. Please try again.';
      state = AuthError(message: msg);
      return msg;
    }
  }

  /// Verifies an OTP code and completes phone sign-in.
  Future<String?> verifyPhoneOtp({
    required String verificationId,
    required String otpCode,
  }) async {
    state = const AuthLoading();
    try {
      final user = await _verifyPhoneOtp(
        OtpVerificationParams(verificationId: verificationId, otpCode: otpCode),
      );
      state = AuthAuthenticated(user: user);
      return null;
    } on Failure catch (f) {
      state = AuthError(message: f.message);
      return f.message;
    } catch (_) {
      final msg = 'Unable to verify code. Please try again.';
      state = AuthError(message: msg);
      return msg;
    }
  }

  /// Sends a password reset email.
  Future<String?> forgotPassword(String email) async {
    state = const AuthLoading();
    try {
      await _forgotPassword(email);
      state = const AuthUnauthenticated();
      return null;
    } on Failure catch (f) {
      state = AuthError(message: f.message);
      return f.message;
    } catch (_) {
      final msg = 'Unable to send password reset. Please try again.';
      state = AuthError(message: msg);
      return msg;
    }
  }

  /// Signs in with biometrics.
  Future<String?> loginWithBiometrics() async {
    state = const AuthLoading();
    try {
      final user = await _biometricLogin(const NoParams());
      state = AuthAuthenticated(user: user);
      return null;
    } on Failure catch (f) {
      state = AuthError(message: f.message);
      return f.message;
    } catch (_) {
      final msg = 'Biometric login failed. Please try again.';
      state = AuthError(message: msg);
      return msg;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      await _logout(const NoParams());
      state = const AuthUnauthenticated();
    } on Failure catch (f) {
      state = AuthError(message: f.message);
    }
  }

  /// Clears any error state.
  void clearError() {
    if (state is AuthError) {
      state = const AuthUnauthenticated();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
