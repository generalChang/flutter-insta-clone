import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../models/comment/comment_model.dart';
import '../../../models/custom_error.dart';
import '../../../repositories/comment_repository.dart';

part 'comment_update_state.dart';

class CommentUpdateCubit extends Cubit<CommentUpdateState> {
  final CommentRepository repository;
  CommentUpdateCubit({required this.repository}) : super(CommentUpdateState.initial());

  Future<void> update({required CommentModel comment}) async {
    emit(state.copyWith(status: CommentUpdateStatus.uploading));
    try {
      final updatedComment = await repository.updateComment(comment: comment);

      emit(state.copyWith(
          status: CommentUpdateStatus.success,
          comment: updatedComment
      ));
    } on CustomError catch (e) {
      emit(state.copyWith(status: CommentUpdateStatus.error, error: e));
    }
  }
}
