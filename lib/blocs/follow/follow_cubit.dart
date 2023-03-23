import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_community/models/custom_error.dart';
import 'package:meta/meta.dart';

import '../../models/user/user_model.dart';
import '../../repositories/follow_repository.dart';
import '../../repositories/like_repository.dart';
import '../pagination/pagination_cubit.dart';
import '../profile/profile_cubit.dart';

part 'follow_state.dart';

class FollowCubit extends Cubit<FollowState> {
  late final StreamSubscription profileStreamSubscription;
  late final StreamSubscription followPaginationStreamSubscription;
  final FollowRepository repository;
  final ProfileCubit profileCubit;
  final PaginationCubit<UserModel, FollowRepository> followPaginationCubit;
  FollowCubit({required this.repository, required this.profileCubit, required this.followPaginationCubit}) : super(FollowState.initial()){
    profileStreamSubscription = profileCubit.stream.listen((ProfileState profileState) {
      if(profileState.status == ProfileStatus.success){
        setAllFollowers(userId: profileState.user!.id);
      }
    });

    followPaginationStreamSubscription = followPaginationCubit.stream.listen((PaginationState<UserModel> paginationState) {
      if(profileCubit.state.status == ProfileStatus.success){
        setAllFollowers(userId: profileCubit.state.user!.id);
      }
    });
  }

  Future<void> setAllFollowers({required String userId}) async {

    emit(state.copyWith(
      status: FollowStatus.loading
    ));

    try{
      final allFollowers = await repository.getAllFollowers(userId: userId);
      emit(state.copyWith(
        status: FollowStatus.success,
        followers: allFollowers
      ));
    }on CustomError catch(e){
      emit(state.copyWith(
        status: FollowStatus.error,
        error: e
      ));
    }
  }

  @override
  Future<void> close() {
    // TODO: implement close
    profileStreamSubscription.cancel();
    followPaginationStreamSubscription.cancel();
    return super.close();
  }
}
