part of 'user_cubit.dart';

enum UserStatus{
  initial,
  loading,
  success,
  error
}

class UserState{
  final UserStatus status;
  final UserModel user;
  final CustomError error;

  UserState({
    required this.status,
    required this.user,
    required this.error,
  });

  factory UserState.initial(){
    return UserState(status: UserStatus.initial, user: UserModel.initial(), error: CustomError());
  }

  UserState copyWith({
    UserStatus? status,
    UserModel? user,
    CustomError? error,
  }) {
    return UserState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}