part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}


class ChangeAuthStateEvent extends AuthEvent{
  final User? user;
  final AuthStatus status;

  ChangeAuthStateEvent({
    this.user,
    required this.status,
  });
}

class SignoutEvent extends AuthEvent{}