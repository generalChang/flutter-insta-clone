import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter_community/models/community/paragraph_model.dart';
import 'package:flutter_community/models/custom_error.dart';
import 'package:flutter_community/models/like_model.dart';
import 'package:flutter_community/models/model_with_id_and_like.dart';
import 'package:flutter_community/models/pagination/cursor_pagination.dart';
import 'package:flutter_community/models/pagination/model_with_id.dart';
import 'package:flutter_community/models/pagination/pagination_params.dart';
import 'package:flutter_community/repositories/base_like_repository.dart';
import 'package:flutter_community/repositories/base_pagination_repository.dart';
import 'package:flutter_community/repositories/paragraph_repository.dart';
import 'package:meta/meta.dart';

import '../../models/user/user_model.dart';
import '../../repositories/follow_repository.dart';
import '../../repositories/like_repository.dart';
import '../paragraph/add/paragraph_add_cubit.dart';

part 'pagination_state.dart';

class _LikeInfo {
  final String? mode;
  final String? userId;
  final String? targetId;

  _LikeInfo({
    this.mode,
    this.userId,
    this.targetId,
  });
}

class PaginationInfo{
  final int count;
  final bool fetchMore;
  final bool forceRefetch;
  final String? paragraphId;
  final String? userId;

  const PaginationInfo({
    this.count = 10,
    this.fetchMore = false,
    this.forceRefetch = false,
    this.paragraphId,
    this.userId,
  });

}

class PaginationCubit<
    T extends IPaginationBaseModel,
    U extends BasePaginationRepository<T>> extends Cubit<PaginationState<T>> {
  final U repository;
  final FollowRepository followRepository;
  // final updateLikeDebounce = Debouncer(Duration(seconds: 1),
  //     initialValue: _LikeInfo(), checkEquality: false);
  final paginationThrottle = Throttle(
      Duration(seconds: 1),
      initialValue: PaginationInfo());

  PaginationCubit({required this.repository, required this.followRepository})
      : super(PaginationState.initial()) {
    paginationThrottle.values.listen((PaginationInfo info) {
      _throttlePagination(info);
    });

    if (ParagraphModel == T && ParagraphRepository == U) {
      pagination();
    }
  }

  Future<void> _throttlePagination(PaginationInfo info) async {
    print("throttling pagination");
    if ((state.status == PaginationStatus.loaded ||
        state.status == PaginationStatus.fetchingMore ||
        state.status == PaginationStatus.refetching) &&
        !info.forceRefetch) {
      if (!state.cursorPagination.meta.hasNext) {
        return;
      }
    }

    final isLoading = state.status == PaginationStatus.loading;
    final isRefetching = state.status == PaginationStatus.refetching;
    final isFetchingMore = state.status == PaginationStatus.fetchingMore;

    if (info.fetchMore && (isLoading || isRefetching || isFetchingMore)) {
      return;
    }

    try {
      PaginationParams paginationParams = PaginationParams(count: info.count);

      if (info.fetchMore) {
        emit(state.copyWith(status: PaginationStatus.fetchingMore));

        paginationParams = paginationParams.copyWith(
            last: state.cursorPagination.data.last.id);
      } else {
        if ((state.status == PaginationStatus.loaded ||
            state.status == PaginationStatus.fetchingMore ||
            state.status == PaginationStatus.refetching) &&
            !info.forceRefetch) {
          //데이터가 있는 상태에서 forceRefetch한건 아니라면
          // final pState = state as CursorPagination<T>;
          // state = CursorPaginationRefetching<T>(
          //     data: pState.data, meta: pState.meta);
          emit(state.copyWith(status: PaginationStatus.refetching));
        } else {
          emit(state.copyWith(
            status: PaginationStatus.loading,
          ));
        }
      }

      final resp = await repository.pagination(
          paginationParams: paginationParams, paragraphId: info.paragraphId, userId: info.userId,
      );
      if (state.status == PaginationStatus.fetchingMore) {
        emit(state.copyWith(
            status: PaginationStatus.loaded,
            cursorPagination: state.cursorPagination.copyWith(
                meta: resp.meta,
                data: [...state.cursorPagination.data, ...resp.data])));
      } else {
        emit(state.copyWith(
            status: PaginationStatus.loaded, cursorPagination: resp));
      }

      reduceDuplication();
    } on CustomError catch (e) {
      emit(state.copyWith(status: PaginationStatus.error, error: e));
    }
  }

  void reduceDuplication(){
    List<T> list = [];
    for(final item in state.cursorPagination.data.reversed){
      if(list.where((e) => e.id == item.id).isEmpty){
        //리스트에 추가되지 않은 것에 대해서만 리스트에 추가.
        list.add(item);
      }
    }

    emit(state.copyWith(
      cursorPagination: state.cursorPagination.copyWith(
        data: list.reversed.toList()
      )
    ));
  }

  Future<void> pagination(
      {int count = 10,
      bool fetchMore = false,
      bool forceRefetch = false,
      String? paragraphId,
      String? userId,
      }) async {
    paginationThrottle.setValue(PaginationInfo(
      count: count,
      fetchMore: fetchMore,
      forceRefetch: forceRefetch,
      paragraphId: paragraphId,
      userId: userId,
    ));
  }

  Future<void> add({required T model}) async {
    emit(state.copyWith(
        cursorPagination: state.cursorPagination
            .copyWith(data: [model, ...state.cursorPagination.data])));
  }

  Future<void> update({required T model}) async {
    emit(state.copyWith(
        cursorPagination: state.cursorPagination.copyWith(
            data: state.cursorPagination.data
                .map((item) => item.id == model.id ? model : item)
                .toList())));
  }

  Future<void> delete({required T model}) async {
    emit(state.copyWith(
      cursorPagination: state.cursorPagination.copyWith(
        data: state.cursorPagination.data.where((item) => item.id != model.id).toList()
      )
    ));
  }

  Future<void> get({required String id}) async {
    if (!(state.status == PaginationStatus.loaded ||
        state.status == PaginationStatus.fetchingMore ||
        state.status == PaginationStatus.refetching)) {
      return ;
    }


    try{
      final newParagraph = await repository.getById(id: id);
      if(state.cursorPagination.data.where((item) => item.id == id).isNotEmpty){
        emit(state.copyWith(
          cursorPagination: state.cursorPagination.copyWith(
            data: state.cursorPagination.data.map((item) => item.id == id ? newParagraph : item).toList()
          )
        ));
      }else{
        emit(state.copyWith(
            cursorPagination: state.cursorPagination.copyWith(
                data: [newParagraph, ...state.cursorPagination.data]
            )
        ));
      }

    }on CustomError catch(e){
      emit(state.copyWith(
        error: e,
        status: PaginationStatus.error
      ));
    }
  }

  Future<void> deleteFollow({required String userId, required String targetUserId}) async {

    try{
      await followRepository.unfollow(userId: userId, targetUserId: targetUserId);
      emit(state.copyWith(
          cursorPagination: state.cursorPagination.copyWith(
              data: state.cursorPagination.data.where((item) => item.id != targetUserId).toList()
          )
      ));
    }on CustomError catch(e){
      emit(state.copyWith(
        status: PaginationStatus.error
      ));
    }
  }

  Future<void> addFollow({required String userId, required UserModel targetUser}) async {


    try{
      await followRepository.follow(userId: userId, targetUserId: targetUser.id);
      emit(state.copyWith(
          cursorPagination: state.cursorPagination
              .copyWith(data: [targetUser as T, ...state.cursorPagination.data])));
    }on CustomError catch(e){
      emit(state.copyWith(
          status: PaginationStatus.error
      ));
    }
  }

  void updateLike<Z extends IBaseModelWithIdAndLike, L extends BaseLikeRepository>({required String targetId, required String userId, required L likeRepository }) {
    final datas = state.cursorPagination.data as List<Z>;
    // 이렇게 케스팅 가능한 이유는 해당 메서드를 LikePaginationCubit이 호출할 예정이기때문.

    for (final data in datas) {
      if (targetId == data.id) {
        if (data.likes.isEmpty) {
          _addLike(targetId: data.id, userId: userId, likeRepository:  likeRepository);
          return;
        }
        for (final like in data.likes) {
          if (like.userId == userId) {
            //해당 글에 대해 이미 좋아요를 누른상태.
            _removeLike(targetId: targetId, userId: userId, likeRepository:  likeRepository);
            return;
          }
        }
        _addLike(targetId: targetId, userId: userId, likeRepository:  likeRepository);
        return;
      }
    }
  }


  //optimistic response 활용

  void _addLike<Z extends IBaseModelWithIdAndLike, L extends BaseLikeRepository>({required String targetId, required String userId,required L likeRepository }) {
    emit(state.copyWith(
        cursorPagination: state.cursorPagination.copyWith(
            data: state.cursorPagination.data.map((e) {
      if (e.id == targetId) {
        (e as Z).likes = [...e.likes, LikeModel(userId: userId, targetId: targetId)];
      }
      return e;
    }).toList())));

    //optimistic response

    // updateLikeDebounce.setValue(_LikeInfo(
    //   mode: "add",
    //   id: id,
    //   userId: userId
    // ));
    _patchLike(
        likeInfo: _LikeInfo(mode: "add", targetId: targetId, userId: userId), likeRepository: likeRepository);
  }

  void _removeLike<Z extends IBaseModelWithIdAndLike, L extends BaseLikeRepository>({required String targetId, required String userId, required L likeRepository }) {
    emit(state.copyWith(
        cursorPagination: state.cursorPagination.copyWith(
            data: state.cursorPagination.data.map((e) {
      if (e.id == targetId) {
        for (int a = 0; a < (e as Z).likes.length; a++) {
          if (e.likes[a].userId == userId) {
            e.likes.removeAt(a);
            return e;
          }
        }
      }
      return e;
    }).toList())));

    _patchLike(
        likeInfo:
            _LikeInfo(mode: "remove", targetId: targetId, userId: userId),
     likeRepository: likeRepository);
  }

  Future<void> _patchLike<Z extends IBaseModelWithIdAndLike, L extends BaseLikeRepository>({required _LikeInfo likeInfo, required L likeRepository }) async {
    if (likeInfo.mode! == "add") {
      await likeRepository.upLike(
          targetId: likeInfo.targetId!, userId: likeInfo.userId!);
    } else {
      await likeRepository.unLike(
          targetId: likeInfo.targetId!, userId: likeInfo.userId!);
    }
  }



}
