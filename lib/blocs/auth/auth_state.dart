part of 'auth_bloc.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
}

class AuthState {
  final AuthStatus status;
  final User? user;

  AuthState({
    required this.status,
    this.user,
  });

  factory AuthState.initial() {
    return AuthState(status: AuthStatus.initial);
  }

  AuthState copyWith({
    AuthStatus? status,
    User? user,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
    );
  }
}
