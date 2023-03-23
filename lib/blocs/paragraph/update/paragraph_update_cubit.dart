

import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter_community/repositories/paragraph_repository.dart';
import 'package:meta/meta.dart';

import '../../../models/community/paragraph_model.dart';
import '../../../models/custom_error.dart';

part 'paragraph_update_state.dart';

class ParagraphUpdateCubit extends Cubit<ParagraphUpdateState> {
  final ParagraphRepository repository;

  ParagraphUpdateCubit({required this.repository}) : super(ParagraphUpdateState.initial());

  Future<void> update(
      {required ParagraphModel paragraph, required List<File> images}) async {
    emit(state.copyWith(status: ParagraphUpdateStatus.uploading));

    try {
      final updatedParagraph = await repository.updatePost(paragraph: paragraph, images: images);
      emit(state.copyWith(
        status: ParagraphUpdateStatus.success,
        paragraph: updatedParagraph,
      ));
    } on CustomError catch (e) {
      emit(state.copyWith(status: ParagraphUpdateStatus.error, error: e));
    }
  }
}
