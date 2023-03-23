import 'package:bloc/bloc.dart';
import 'package:flutter_community/models/custom_error.dart';
import 'package:meta/meta.dart';

import '../../repositories/auth_repository.dart';

part 'signin_state.dart';

class SigninCubit extends Cubit<SigninState> {
  final AuthRepository repository;
  SigninCubit({required this.repository}) : super(SigninState.initial());

  Future<void> signin({required String email, required String password}) async {
    emit(state.copyWith(
      status: SigninStatus.submitting
    ));

    try{
      await repository.signin(email: email, password: password);
      emit(state.copyWith(
        status: SigninStatus.success,
      ));
    }on CustomError catch(e){
      emit(state.copyWith(
        status: SigninStatus.error,
        error: e
      ));
    }
  }
}
