import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_community/models/custom_error.dart';
import 'package:flutter_community/models/user/user_model.dart';
import 'package:flutter_community/repositories/auth_repository.dart';
import 'package:meta/meta.dart';

import '../../repositories/user_repository.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  late final StreamSubscription authSubscription;
  final AuthRepository authRepository;
  final UserRepository repository;
  ProfileCubit({required this.authRepository, required this.repository})
      : super(ProfileState.initial()) {
    authSubscription = authRepository.user.listen((User? user) {
      if (user != null) {
        print("프로필 얻어오기");
        getProfile(uid: user!.uid);
      }
    });
  }

  Future<void> getProfile({required String uid}) async {
    emit(state.copyWith(
      status: ProfileStatus.loading,
    ));
    try {
      final user = await repository.getProfile(uid: uid);
      emit(state.copyWith(
        status: ProfileStatus.success,
        user: user,
      ));
    } on CustomError catch (e) {
      emit(state.copyWith(status: ProfileStatus.error, error: e));
    }
  }

  Future<void> updateProfile(
      {required String uid,
      required String name,
      required File profileImage}) async {
    emit(state.copyWith(
      status: ProfileStatus.loading,
    ));
    try {
      await repository.updateProfile(uid: uid, name: name, profileImage: profileImage);
      final user = await repository.getProfile(uid: uid);
      emit(state.copyWith(
        status: ProfileStatus.success,
        user: user,
      ));
    } on CustomError catch (e) {
      emit(state.copyWith(status: ProfileStatus.error, error: e));
    }
  }

  @override
  Future<void> close() {
    // TODO: implement close
    authSubscription.cancel();
    return super.close();
  }
}
