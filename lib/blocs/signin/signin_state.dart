part of 'signin_cubit.dart';

enum SigninStatus{
  initial,
  submitting,
  success,
  error
}

class SigninState{
  final SigninStatus status;
  final CustomError error;

  SigninState({
    required this.status,
    required this.error,
  });

  factory SigninState.initial(){
    return SigninState(status: SigninStatus.initial, error: CustomError());
  }

  SigninState copyWith({
    SigninStatus? status,
    CustomError? error,
  }) {
    return SigninState(
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}