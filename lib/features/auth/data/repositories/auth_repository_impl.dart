import 'dart:async';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/biometric_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

/// Implementation of [AuthRepository] combining remote and local data sources.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required BiometricService biometricService,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _biometricService = biometricService;

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final BiometricService _biometricService;

  @override
  Stream<UserEntity?> get authStateChanges {
    return _remoteDataSource.authStateChanges.map((userModel) {
      return userModel?.toEntity();
    });
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final currentUser = await _remoteDataSource.getCurrentUser();
      return currentUser?.toEntity();
    } on AuthenticationException {
      // Fall back to cached user if remote retrieval fails.
      final cachedUser = await _localDataSource.getCachedUser();
      return cachedUser?.toEntity();
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final currentUser = await getCurrentUser();
    return currentUser != null;
  }

  @override
  Future<UserEntity> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await _remoteDataSource.loginWithEmail(
        email: email,
        password: password,
      );
      await _localDataSource.cacheUser(userModel);
      return userModel.toEntity();
    } on AuthenticationException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<UserEntity> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userModel = await _remoteDataSource.registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      await _localDataSource.cacheUser(userModel);
      return userModel.toEntity();
    } on AuthenticationException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      final userModel = await _remoteDataSource.signInWithGoogle();
      await _localDataSource.cacheUser(userModel);
      return userModel.toEntity();
    } on AuthenticationException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<UserEntity> signInWithApple() async {
    try {
      final userModel = await _remoteDataSource.signInWithApple();
      await _localDataSource.cacheUser(userModel);
      return userModel.toEntity();
    } on AuthenticationException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<void> sendPhoneVerificationCode({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
  }) async {
    try {
      await _remoteDataSource.sendPhoneVerificationCode(
        phoneNumber: phoneNumber,
        onCodeSent: onCodeSent,
      );
    } on AuthenticationException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<UserEntity> verifyPhoneOtp({
    required String verificationId,
    required String otpCode,
  }) async {
    try {
      final userModel = await _remoteDataSource.verifyPhoneOtp(
        verificationId: verificationId,
        otpCode: otpCode,
      );
      await _localDataSource.cacheUser(userModel);
      return userModel.toEntity();
    } on AuthenticationException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _remoteDataSource.sendPasswordResetEmail(email);
    } on AuthenticationException catch (e) {
      throw _mapException(e);
    }
  }

@override
  Future<UserEntity> loginWithBiometrics() async {
    try {
      final authenticated = await _biometricService.authenticate();
      if (!authenticated) {
        throw const BiometricAuthenticationFailedFailure();
      }

      final cachedUser = await _localDataSource.getCachedUser();
      if (cachedUser == null) {
        throw const UnknownFailure('No cached session found. Please sign in.');
      }
      return cachedUser.toEntity();
    } on BiometricException catch (e) {
      throw BiometricAuthenticationFailedFailure(e.message);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _remoteDataSource.signOut();
      await _localDataSource.clearCache();
    } on AuthenticationException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    await _localDataSource.setBiometricEnabled(enabled);
  }

/// Maps a data-layer exception to a domain failure.
  Failure _mapException(AuthenticationException e) {
    final message = e.message;
    if (message.contains('invalid email', caseSensitive: false) ||
        message.contains('email address is not valid')) {
      return InvalidEmailFailure(message);
    }
    if (message.contains('user not found', caseSensitive: false) ||
        message.contains('no user found', caseSensitive: false)) {
      return UserNotFoundFailure(message);
    }
    if (message.contains('already exists', caseSensitive: false) ||
        message.contains('already in use', caseSensitive: false)) {
      return EmailAlreadyInUseFailure(message);
    }
    if (message.contains('weak password', caseSensitive: false) ||
        message.contains('too weak', caseSensitive: false)) {
      return WeakPasswordFailure(message);
    }
    if (message.contains('incorrect password', caseSensitive: false) ||
        message.contains('wrong password', caseSensitive: false)) {
      return InvalidCredentialsFailure(message);
    }
    if (message.contains('too many attempts', caseSensitive: false) ||
        message.contains('too many requests', caseSensitive: false)) {
      return TooManyRequestsFailure(message);
    }
    if (message.contains('verification code', caseSensitive: false)) {
      return InvalidOtpFailure(message);
    }
    if (message.contains('network', caseSensitive: false)) {
      return NetworkFailure(message);
    }
    return ServerFailure(message);
  }
}
