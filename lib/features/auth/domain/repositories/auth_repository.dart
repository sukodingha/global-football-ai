import 'dart:async';

import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

/// Abstract contract for the authentication repository.
///
/// All data-layer implementations must satisfy this interface.
abstract class AuthRepository {
  /// Streams authentication state changes.
  Stream<UserEntity?> get authStateChanges;

  /// Returns the currently signed-in user, or null.
  Future<UserEntity?> getCurrentUser();

  /// Whether a user is currently authenticated.
  Future<bool> isAuthenticated();

  /// Signs in with email and password.
  Future<UserEntity> loginWithEmail({
    required String email,
    required String password,
  });

  /// Registers a new user with email and password.
  Future<UserEntity> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  /// Signs in with Google.
  Future<UserEntity> signInWithGoogle();

  /// Signs in with Apple.
  Future<UserEntity> signInWithApple();

  /// Sends a phone verification code.
  Future<void> sendPhoneVerificationCode({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
  });

  /// Verifies an OTP code and completes phone sign-in.
  Future<UserEntity> verifyPhoneOtp({
    required String verificationId,
    required String otpCode,
  });

  /// Sends a password reset email.
  Future<void> sendPasswordResetEmail(String email);

  /// Authenticates using biometrics and the stored session.
  Future<UserEntity> loginWithBiometrics();

  /// Signs out the current user.
  Future<void> signOut();

  /// Enables or disables biometric login.
  Future<void> setBiometricEnabled(bool enabled);
}

/// Extension that maps repository failures to domain failures.
typedef AuthResult<T> = Future<Result<T>>;

/// Simple result wrapper for use cases.
class Result<T> {
  const Result._(this.value, this.failure);
  const Result.success(T value) : this._(value, null);
  const Result.failure(Failure failure) : this._(null, failure);

  final T? value;
  final Failure? failure;

  bool get isSuccess => failure == null;
  bool get isFailure => failure != null;

  /// Returns the value or throws if a failure occurred.
  T get getOrThrow {
    if (isFailure) throw failure!;
    return value!;
  }
}
