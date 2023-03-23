import 'package:bloc/bloc.dart';
import 'package:flutter_community/models/custom_error.dart';
import 'package:flutter_community/models/user/user_model.dart';
import 'package:meta/meta.dart';

import '../../repositories/user_repository.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepository repository;
  UserCubit({required this.repository}) : super(UserState.initial());

  Future<void> getUser({required String userId}) async {
    emit(state.copyWith(
      status: UserStatus.loading
    ));
    try{
      final user = await repository.getProfile(uid: userId);
      emit(state.copyWith(
        user: user,
        status: UserStatus.success
      ));
    }on CustomError catch(e){
      emit(state.copyWith(
        status: UserStatus.error,
        error: e
      ));
    }
  }
}
