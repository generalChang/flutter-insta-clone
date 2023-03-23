part of 'follow_cubit.dart';

enum FollowStatus{
  initial,
  loading,
  success,
  error
}

class FollowState{
  final FollowStatus status;
  final List<UserModel> followers; //내가 팔로잉중인 사람들(전체)
  final CustomError error;

   FollowState({
    required this.status,
    required this.followers,
    required this.error,
  });

  factory FollowState.initial(){
    return FollowState(status: FollowStatus.initial, followers: [], error: CustomError());
  }

  FollowState copyWith({
    FollowStatus? status,
    List<UserModel>? followers,
    CustomError? error,
  }) {
    return FollowState(
      status: status ?? this.status,
      followers: followers ?? this.followers,
      error: error ?? this.error,
    );
  }
}