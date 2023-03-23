import 'package:bloc/bloc.dart';
import 'package:flutter_community/models/comment/comment_model.dart';
import 'package:flutter_community/models/custom_error.dart';
import 'package:flutter_community/models/user/user_model.dart';
import 'package:meta/meta.dart';

import '../../../repositories/comment_repository.dart';

part 'comment_add_state.dart';

class CommentAddCubit extends Cubit<CommentAddState> {
  final CommentRepository repository;
  CommentAddCubit({required this.repository})
      : super(CommentAddState.initial());

  Future<void> add({required UserModel user, required String paragraphId, required String message}) async {
    emit(state.copyWith(status: CommentAddStatus.uploading));
    try {
      final comment = await repository.addComment(
          user: user,
          paragraphId: paragraphId,
          message: message);

      emit(state.copyWith(
        status: CommentAddStatus.success,
        comment: comment
      ));
    } on CustomError catch (e) {
      emit(state.copyWith(status: CommentAddStatus.error, error: e));
    }
  }
}
