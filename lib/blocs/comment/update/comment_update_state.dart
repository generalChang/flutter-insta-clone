part of 'comment_update_cubit.dart';

enum CommentUpdateStatus{
  initial, uploading, success, error
}

class CommentUpdateState{
  final CommentUpdateStatus status;
  final CommentModel comment;
  final CustomError error;

  CommentUpdateState({
    required this.status,
    required this.comment,
    required this.error,
  });

  factory CommentUpdateState.initial(){
    return CommentUpdateState(
        status: CommentUpdateStatus.initial,
        comment: CommentModel.initial(),
        error: CustomError());
  }

  CommentUpdateState copyWith({
    CommentUpdateStatus? status,
    CommentModel? comment,
    CustomError? error,
  }) {
    return CommentUpdateState(
      status: status ?? this.status,
      comment: comment ?? this.comment,
      error: error ?? this.error,
    );
  }
}