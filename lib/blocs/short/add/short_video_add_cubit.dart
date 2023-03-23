import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter_community/models/short_video/short_video_model.dart';
import 'package:meta/meta.dart';

import '../../../models/custom_error.dart';
import '../../../repositories/short_video_repository.dart';

part 'short_video_add_state.dart';

class ShortVideoAddCubit extends Cubit<ShortVideoAddState> {
  final ShortVideoRepository repository;

  ShortVideoAddCubit({required this.repository}) : super(ShortVideoAddState.initial());

  Future<void> add(
      {required ShortVideoModel short,
        required File video,
      }) async {
    emit(state.copyWith(status: ShortVideoAddStatus.uploading));

    try {
      final addShort = await repository.addShortVideo(
        user: short.user,
        content: short.content,
        video: video);
      emit(state.copyWith(
        status: ShortVideoAddStatus.success,
        shortVideo: addShort,
      ));
    } on CustomError catch (e) {
      emit(state.copyWith(status: ShortVideoAddStatus.error, error: e));
    }
  }
}
