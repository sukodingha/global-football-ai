import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsi;

import '../../../core/services/biometric_service.dart';
import '../../../core/services/secure_storage_service.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/apple_sign_in.dart';
import '../domain/usecases/biometric_login.dart';
import '../domain/usecases/forgot_password.dart';
import '../domain/usecases/get_current_user.dart';
import '../domain/usecases/google_sign_in.dart';
import '../domain/usecases/login_with_email.dart';
import '../domain/usecases/logout.dart';
import '../domain/usecases/register_with_email.dart';
import '../domain/usecases/send_phone_verification_code.dart';
import '../domain/usecases/verify_phone_otp.dart';
import '../domain/usecases/watch_auth_state.dart';
import 'datasources/auth_local_data_source.dart';
import 'datasources/auth_remote_data_source.dart';
import 'repositories/auth_repository_impl.dart';

/// Core services.
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

/// Firebase services.
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final googleSignInProvider = Provider<gsi.GoogleSignIn>((ref) {
  if (kIsWeb) {
    return gsi.GoogleSignIn(clientId: 'global-ai-prediction.web.app');
  }
  return gsi.GoogleSignIn();
});

/// Data sources.
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    googleSignIn: ref.watch(googleSignInProvider),
  );
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSource(
    secureStorage: ref.watch(secureStorageServiceProvider),
  );
});

/// Repository.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
    biometricService: ref.watch(biometricServiceProvider),
  );
});

/// Use cases.
final loginWithEmailUseCaseProvider = Provider<LoginWithEmail>((ref) {
  return LoginWithEmail(ref.watch(authRepositoryProvider));
});

final registerWithEmailUseCaseProvider = Provider<RegisterWithEmail>((ref) {
  return RegisterWithEmail(ref.watch(authRepositoryProvider));
});

final googleSignInUseCaseProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn(ref.watch(authRepositoryProvider));
});

final appleSignInUseCaseProvider = Provider<AppleSignIn>((ref) {
  return AppleSignIn(ref.watch(authRepositoryProvider));
});

final sendPhoneVerificationCodeUseCaseProvider = Provider<SendPhoneVerificationCode>((ref) {
  return SendPhoneVerificationCode(ref.watch(authRepositoryProvider));
});

final verifyPhoneOtpUseCaseProvider = Provider<VerifyPhoneOtp>((ref) {
  return VerifyPhoneOtp(ref.watch(authRepositoryProvider));
});

final forgotPasswordUseCaseProvider = Provider<ForgotPassword>((ref) {
  return ForgotPassword(ref.watch(authRepositoryProvider));
});

final biometricLoginUseCaseProvider = Provider<BiometricLogin>((ref) {
  return BiometricLogin(ref.watch(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUser>((ref) {
  return GetCurrentUser(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<Logout>((ref) {
  return Logout(ref.watch(authRepositoryProvider));
});

final watchAuthStateUseCaseProvider = Provider<WatchAuthState>((ref) {
  return WatchAuthState(ref.watch(authRepositoryProvider));
});
