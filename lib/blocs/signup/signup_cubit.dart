import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../models/custom_error.dart';
import '../../repositories/auth_repository.dart';

part 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  final AuthRepository repository;
  SignupCubit({required this.repository}) : super(SignupState.initial());

  Future<void> signup({required String name, required String email, required String password}) async {
    emit(state.copyWith(
        status: SignupStatus.submitting
    ));

    try{
      await repository.signup(name: name, email: email, password: password);
      emit(state.copyWith(
        status: SignupStatus.success,
      ));
    }on CustomError catch(e){
      emit(state.copyWith(
          status: SignupStatus.error,
          error: e
      ));
    }
  }
}
