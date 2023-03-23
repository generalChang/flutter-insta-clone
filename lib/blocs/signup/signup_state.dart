part of 'signup_cubit.dart';

enum SignupStatus{
  initial,
  submitting,
  success,
  error
}

class SignupState{
  final SignupStatus status;
  final CustomError error;

  SignupState({
    required this.status,
    required this.error,
  });

  factory SignupState.initial(){
    return SignupState(status: SignupStatus.initial, error: CustomError());
  }

  SignupState copyWith({
    SignupStatus? status,
    CustomError? error,
  }) {
    return SignupState(
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}