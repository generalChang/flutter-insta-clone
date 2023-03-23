import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_community/consts/firebase_const.dart';
import 'package:flutter_community/models/community/paragraph_model.dart';
import 'package:flutter_community/models/custom_error.dart';
import 'package:flutter_community/models/follow/follow_model.dart';
import 'package:flutter_community/models/pagination/cursor_pagination.dart';

import 'package:flutter_community/models/pagination/model_with_id.dart';

import 'package:flutter_community/models/pagination/pagination_params.dart';
import 'package:flutter_community/models/user/user_model.dart';
import 'package:flutter_community/services/pagination_api_services.dart';

import 'base_pagination_repository.dart';

class FollowRepository implements BasePaginationRepository<UserModel>{
  final PaginationApiServices apiServices;
  final FirebaseFirestore firestore;

  FollowRepository({
    required this.firestore,
    required this.apiServices,
  });

  @override
  Future<CursorPagination<UserModel>> pagination({PaginationParams paginationParams = const PaginationParams(),
  String? userId, String? paragraphId}) async {
    try{
      CursorPagination<UserModel> cursorPagination = CursorPagination<UserModel>.initial();
      Meta meta = Meta();

      final followersWithFollowModel = await apiServices.getFollowers(userId: userId!, paginationParams: paginationParams);
      final followersWithUserModel = await apiServices.getUserFromFollow(follows: followersWithFollowModel);
      final hasNext = followersWithUserModel.isNotEmpty && await apiServices.hasNextFollow(last: followersWithFollowModel.last.id, userId: userId);

      meta = meta.copyWith(hasNext: hasNext);

      cursorPagination = cursorPagination.copyWith(
        meta: meta,
        data: followersWithUserModel
      );


      return cursorPagination;
    }on FirebaseException catch(e){
      throw CustomError(
        code: e.code,
        message: e.message!,
        plugin: e.plugin
      );
    }catch(e){
      throw CustomError(
          code: "Error!",
          message: e.toString(),
          plugin: "flutter_error/server_error");
    }
  }

  Future<List<UserModel>> getAllFollowers({
    required String userId}) async {
    try{
      final followersWithFollowModel = await apiServices.getAllFollowers(userId: userId!);
      final followersWithUserModel = await apiServices.getUserFromFollow(follows: followersWithFollowModel);
      return followersWithUserModel;
    }on FirebaseException catch(e){
      throw CustomError(
          code: e.code,
          message: e.message!,
          plugin: e.plugin
      );
    }catch(e){
      throw CustomError(
          code: "Error!",
          message: e.toString(),
          plugin: "flutter_error/server_error");
    }
  }

  Future<void> follow({required String userId, required String targetUserId}) async {
    try{
      FollowModel follow = FollowModel.initial();
      follow = follow.copyWith(userId: userId,targetUserId: targetUserId);

      final document = await followsRef.add(follow.toJson());
      await followsRef.doc(document.id).set(
        follow.copyWith(id: document.id).toJson()
      );
    }on FirebaseException catch(e){
      throw CustomError(
        code: e.code,
        message: e.message!,
        plugin: e.plugin
      );
    }catch(e){
      throw CustomError(
        code: "Error!",
        message: e.toString(),
        plugin: "flutter_error/server_error"
      );
    }
  }

  Future<bool> isFollowed({required String userId, required String targetUserId}) async {
    //이미 팔로우 되어 있는지 검사
    try{

      final followsQuery = followsRef.where("userId", isEqualTo: userId).where("targetUserId", isEqualTo: targetUserId);
      final follows = await followsQuery.get();
      List<FollowModel> meFollows  = [];
      for(final delete in follows.docs){
        meFollows.add(FollowModel.fromDoc(followDoc: delete));
      }

      return meFollows.isNotEmpty;
    }on FirebaseException catch(e){
      throw CustomError(
          code: e.code,
          message: e.message!,
          plugin: e.plugin
      );
    }catch(e){
      throw CustomError(
          code: "Error!",
          message: e.toString(),
          plugin: "flutter_error/server_error"
      );
    }
  }

  Future<void> unfollow({required String userId, required String targetUserId}) async {
    try{
      FollowModel follow = FollowModel.initial();
      follow = follow.copyWith(userId: userId,targetUserId: targetUserId);

      final deleteItem = followsRef.where("userId", isEqualTo: userId).where("targetUserId", isEqualTo: targetUserId);
      final deletes = await deleteItem.get();
      List<FollowModel> deleteFollows  = [];
      for(final delete in deletes.docs){
        deleteFollows.add(FollowModel.fromDoc(followDoc: delete));
      }

      if(deleteFollows.isNotEmpty){
        await followsRef.doc(deleteFollows[0].id).delete();
      }
    }on FirebaseException catch(e){
      throw CustomError(
          code: e.code,
          message: e.message!,
          plugin: e.plugin
      );
    }catch(e){
      throw CustomError(
          code: "Error!",
          message: e.toString(),
          plugin: "flutter_error/server_error"
      );
    }
  }

  @override
  Future<UserModel> getById({required String id}) {
    // TODO: implement getById
    throw UnimplementedError();
  }
}