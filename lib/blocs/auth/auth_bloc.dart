import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

import '../../repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  late final StreamSubscription authSubscription;
  final AuthRepository repository;
  AuthBloc({required this.repository}) : super(AuthState.initial()) {
    authSubscription = repository.user.listen((User? user) {
      if (user != null) {
        add(ChangeAuthStateEvent(status: AuthStatus.authenticated, user: user));
      } else {
        add(ChangeAuthStateEvent(
            status: AuthStatus.unauthenticated, user: null));
      }
    });
    on<ChangeAuthStateEvent>((event, emit) {
      // TODO: implement event handler
      emit(state.copyWith(status: event.status, user: event.user));
    });

    on<SignoutEvent>((event, emit) {
      // TODO: implement event handler
      repository.signout();
    });
  }
}
