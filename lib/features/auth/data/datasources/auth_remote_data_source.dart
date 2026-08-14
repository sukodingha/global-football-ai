import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

/// Remote data source backed by Firebase Authentication.
///
/// Handles all Firebase Auth API calls. Throws data-layer exceptions
/// which are caught and mapped by the repository implementation.
class AuthRemoteDataSource {
  AuthRemoteDataSource({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
  })  : _auth = firebaseAuth,
        _googleSignIn = googleSignIn;

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  /// Returns the currently signed-in Firebase user stream.
  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) {
        return null;
      }
      try {
        return UserModel.fromFirebaseUser(firebaseUser);
      } catch (_) {
        return null;
      }
    });
  }

  /// Returns the currently signed-in user model, or null.
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return null;
      }
      return UserModel.fromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(mapFirebaseAuthError(e));
    }
  }

  /// Signs in with email and password.
  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return UserModel.fromFirebaseUser(credential.user);
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(mapFirebaseAuthError(e));
    }
  }

  /// Registers a new user with email and password.
  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(displayName);
      await credential.user?.sendEmailVerification();
      return UserModel.fromFirebaseUser(credential.user);
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(mapFirebaseAuthError(e));
    }
  }

  /// Signs in with Google.
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser;
      if (kIsWeb) {
        googleUser = await _googleSignIn.signInSilently();
      } else {
        googleUser = await _googleSignIn.signIn();
      }
      if (googleUser == null) {
        throw const AuthenticationException('Google sign-in was cancelled.');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return UserModel.fromFirebaseUser(userCredential.user);
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(mapFirebaseAuthError(e));
    } on ArgumentError {
      throw const AuthenticationException('Google sign-in failed. Please try again.');
    }
  }

  /// Signs in with Apple.
  Future<UserModel> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final credential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return UserModel.fromFirebaseUser(userCredential.user);
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(mapFirebaseAuthError(e));
    } catch (_) {
      throw const AuthenticationException('Apple sign-in failed. Please try again.');
    }
  }

  /// Sends a verification code to the provided phone number.
  ///
  /// The [onCodeSent] callback is invoked with the verification ID
  /// used to complete sign-in.
  Future<void> sendPhoneVerificationCode({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential phoneCredential) async {
          try {
            await _auth.signInWithCredential(phoneCredential);
          } catch (_) {}
        },
        verificationFailed: (FirebaseAuthException e) {
          throw AuthenticationException(mapFirebaseAuthError(e));
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(mapFirebaseAuthError(e));
    }
  }

  /// Completes phone sign-in with the provided OTP.
  Future<UserModel> verifyPhoneOtp({
    required String verificationId,
    required String otpCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode.trim(),
      );
      final userCredential = await _auth.signInWithCredential(credential);
      return UserModel.fromFirebaseUser(userCredential.user);
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(mapFirebaseAuthError(e));
    }
  }

  /// Sends a password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(mapFirebaseAuthError(e));
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (_) {
      throw const AuthenticationException('Unable to sign out. Please try again.');
    }
  }
}
