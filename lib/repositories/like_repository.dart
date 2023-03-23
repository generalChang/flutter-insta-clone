

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_community/consts/firebase_const.dart';
import 'package:flutter_community/models/comment/comment_model.dart';
import 'package:flutter_community/models/like_model.dart';

import '../models/custom_error.dart';
import 'base_like_repository.dart';

class LikeRepository implements BaseLikeRepository{
  final FirebaseFirestore firestore;

  LikeRepository({
    required this.firestore,
  });

  Future<void> upLike(
      {
      required String userId,
      required String targetId}) async {
    try {
      // List<LikeModel> likes = await getLikes(targetId: targetId);
      // LikeModel likeModel = LikeModel.initial();
      // likes.add(likeModel.copyWith(userId: userId));
      // await commentsRef
      //     .doc(id)
      //     .update({"likes": likes.map((like) => like.toJson()).toList()});
      LikeModel likeModel = LikeModel.initial();
      final likeDoc = await likesRef.add(likeModel.copyWith(userId: userId, targetId: targetId).toJson());
      await likesRef.doc(likeDoc.id).update(likeModel.copyWith(userId: userId, targetId: targetId,id: likeDoc.id).toJson());
    } on FirebaseException catch (e) {
      throw CustomError(code: e.code, message: e.message!, plugin: e.plugin);
    } catch (e) {
      throw CustomError(
          code: "Error!",
          message: e.toString(),
          plugin: "flutter_error/server_error");
    }
  }

  Future<void> unLike(
      {required String userId, required String targetId}) async {
    try {
      // List<LikeModel> likes = await getLikes(id: id);
      // likes = likes.where((like) => like.userId != userId).toList();
      // await commentsRef
      //     .doc(id)
      //     .update({"likes": likes.map((like) => like.toJson()).toList()});
      final deleteItem = await likesRef.where("userId", isEqualTo: userId).where("targetId", isEqualTo: targetId);
      final deletes = await deleteItem.get();

      List<LikeModel> list = [];
      for(final deleteDoc in deletes.docs){
        list.add(LikeModel.fromDoc(doc: deleteDoc));
      }

      if(list.isNotEmpty){
        await likesRef.doc(list[0].id).delete();
      }
    } on FirebaseException catch (e) {
      throw CustomError(code: e.code, message: e.message!, plugin: e.plugin);
    } catch (e) {
      throw CustomError(
          code: "Error!",
          message: e.toString(),
          plugin: "flutter_error/server_error");
    }
  }

  Future<List<LikeModel>> getLikes({required String targetId}) async {
    try {
      final documentsQuery = await likesRef.where(targetId);
      final documents = await documentsQuery.get();

      List<LikeModel> list = [];
      for(final likeDoc in documents.docs){
        list.add(LikeModel.fromDoc(doc: likeDoc));
      }

      return list;
    } on FirebaseException catch (e) {
      throw CustomError(code: e.code, message: e.message!, plugin: e.plugin);
    } catch (e) {
      throw CustomError(
          code: "Error!",
          message: e.toString(),
          plugin: "flutter_error/server_error");
    }
  }
}
