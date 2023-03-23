import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter_community/models/community/paragraph_model.dart';
import 'package:flutter_community/models/custom_error.dart';
import 'package:meta/meta.dart';

import '../../../repositories/paragraph_repository.dart';

part 'paragraph_add_state.dart';

class ParagraphAddCubit extends Cubit<ParagraphAddState> {
  final ParagraphRepository repository;
  ParagraphAddCubit({required this.repository})
      : super(ParagraphAddState.initial());

  Future<void> add(
      {required ParagraphModel paragraph,
      required List<File> images,
      }) async {
    emit(state.copyWith(status: ParagraphAddStatus.uploading));

    try {
      final addParagraph = await repository.addPost(
          user: paragraph.user,
          content: paragraph.content,
          images: images,);
      emit(state.copyWith(
        status: ParagraphAddStatus.success,
        paragraph: addParagraph,
      ));
    } on CustomError catch (e) {
      emit(state.copyWith(status: ParagraphAddStatus.error, error: e));
    }
  }
}
