part of 'profile_cubit.dart';

enum ProfileStatus{
  initial,
  loading,
  success,
  error
}

class ProfileState{
  final ProfileStatus status;
  final UserModel? user;
  final CustomError error;

   ProfileState({
    required this.status,
    this.user,
    required this.error,
  });

   factory ProfileState.initial(){
     return ProfileState(status: ProfileStatus.initial, user: UserModel.initial(),
         error: CustomError());
   }

  ProfileState copyWith({
    ProfileStatus? status,
    UserModel? user,
    CustomError? error,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}