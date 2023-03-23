import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:flutter_community/models/custom_error.dart';
import 'package:meta/meta.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../models/short_video/short_video_and_thumbnail_model.dart';
import '../../../models/short_video/short_video_model.dart';
import '../../../repositories/short_video_of_user_repository.dart';
import '../../../repositories/short_video_repository.dart';
import '../../pagination/pagination_cubit.dart';

part 'short_thumbnail_state.dart';

class ShortThumbnailCubit extends Cubit<ShortThumbnailState> {
  late final StreamSubscription shortStreamSubscription;
  late final StreamSubscription shortOfUserSteramSubscription;
  final PaginationCubit<ShortVideoModel, ShortVideoRepository>? shortPaginationCubit;
  final PaginationCubit<ShortVideoModel, ShortVideoOfUserRepository>? shortOfUserPaginationCubit;


  ShortThumbnailCubit({
    this.shortPaginationCubit,
    this.shortOfUserPaginationCubit
}) : super(ShortThumbnailState.initial()){
    if(shortPaginationCubit != null){
      shortStreamSubscription = shortPaginationCubit!.stream.listen((PaginationState<ShortVideoModel> paginationState) {
        if(paginationState.status == PaginationStatus.loaded ||
            paginationState.status == PaginationStatus.refetching ||
            paginationState.status == PaginationStatus.fetchingMore){
          setThumbnails();
        }
      });
    }else{
      shortOfUserSteramSubscription = shortOfUserPaginationCubit!.stream.listen((PaginationState<ShortVideoModel> paginationState) {
        if(paginationState.status == PaginationStatus.loaded ||
            paginationState.status == PaginationStatus.refetching ||
            paginationState.status == PaginationStatus.fetchingMore){
          setThumbnails();
        }
      });
    }

  }

  Future<void> setThumbnails() async {
    emit(state.copyWith(
      status: ShortThumbnailStatus.loading,
    ));
    List<Future<Uint8List?>> futures = [];
    final shorts = shortPaginationCubit != null ? shortPaginationCubit!.state.cursorPagination.data : shortOfUserPaginationCubit!.state.cursorPagination.data;
    for(final short in shorts){
      futures.add(VideoThumbnail.thumbnailData(
          video: short.videoUrl,
          imageFormat: ImageFormat.JPEG,
          quality:
          100 // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      ));
    }
    List<Uint8List?> thumbs = await Future.wait(futures);
    List<ShortVideoThumbnailModel> shortAndThumbs = [];
    for(int a =0; a<thumbs.length; a++){
      shortAndThumbs.add(ShortVideoThumbnailModel(id: shorts[a].id, thumbnail: thumbs[a]));
    }
    emit(state.copyWith(
      status: ShortThumbnailStatus.success,
      thumbnails: shortAndThumbs
    ));

  }


}
