import '../../domain/entities/user_entity.dart';

/// Immutable authentication state for the UI.
sealed class AuthState {
  const AuthState();
}

/// Initial state while Firebase is initializing.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state during an authentication operation.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated with a user.
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.user});
  final UserEntity user;
}

/// Unauthenticated (signed out or not logged in).
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Error state with a status message.
class AuthError extends AuthState {
  const AuthError({required this.message});
  final String message;
}
