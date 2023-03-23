part of 'comment_add_cubit.dart';


enum CommentAddStatus{
  initial, uploading, success, error
}

class CommentAddState{
  final CommentAddStatus status;
  final CommentModel comment;
  final CustomError error;

  CommentAddState({
    required this.status,
    required this.comment,
    required this.error,
  });

  factory CommentAddState.initial(){
    return CommentAddState(
        status: CommentAddStatus.initial,
        comment: CommentModel.initial(),
        error: CustomError());
  }

  CommentAddState copyWith({
    CommentAddStatus? status,
    CommentModel? comment,
    CustomError? error,
  }) {
    return CommentAddState(
      status: status ?? this.status,
      comment: comment ?? this.comment,
      error: error ?? this.error,
    );
  }
}