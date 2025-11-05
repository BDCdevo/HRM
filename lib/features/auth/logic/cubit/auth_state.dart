import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';

/// Auth State
///
/// Represents different states of authentication process
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial State
///
/// Default state when app starts
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading State
///
/// Shown during API calls (login, register, logout)
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated State
///
/// User is successfully authenticated
class AuthAuthenticated extends AuthState {
  final UserModel user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Unauthenticated State
///
/// User is not logged in
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Error State
///
/// Error occurred during authentication
class AuthError extends AuthState {
  final String message;
  final String? firstError;

  const AuthError({
    required this.message,
    this.firstError,
  });

  /// Get display error message
  String get displayMessage => firstError ?? message;

  @override
  List<Object?> get props => [message, firstError];
}

/// Success State
///
/// Generic success state for operations like password reset
class AuthSuccess extends AuthState {
  final String message;

  const AuthSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
