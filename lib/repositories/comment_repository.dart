import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_community/consts/firebase_const.dart';
import 'package:flutter_community/models/comment/comment_model.dart';
import 'package:flutter_community/models/pagination/cursor_pagination.dart';
import 'package:flutter_community/models/pagination/model_with_id.dart';
import 'package:flutter_community/models/pagination/pagination_params.dart';
import 'package:flutter_community/repositories/base_pagination_repository.dart';

import '../models/community/paragraph_model.dart';
import '../models/custom_error.dart';
import '../models/user/user_model.dart';
import '../services/pagination_api_services.dart';

class CommentRepository implements BasePaginationRepository<CommentModel> {
  final FirebaseFirestore firestore;
  final PaginationApiServices<CommentModel,
      CollectionReference<Map<String, dynamic>>> paginationApiServices;

  CommentRepository({
    required this.paginationApiServices,
    required this.firestore,
  });

  Future<CommentModel> addComment(
      {required UserModel user,
      required String paragraphId,
      required String message}) async {
    try {
      CommentModel commentModel = CommentModel.initial();
      commentModel = commentModel.copyWith(
          user: user, message: message, paragraphId: paragraphId);

      final commentDocument = await commentsRef.add(commentModel.toJson());
      final comment = commentModel.copyWith(id: commentDocument.id);
      await commentsRef.doc(commentDocument.id).set(comment.toJson());
      return comment;
    } on FirebaseException catch (e) {
      throw CustomError(code: e.code, message: e.message!, plugin: e.plugin);
    } catch (e) {
      throw CustomError(
          code: "Error!",
          message: e.toString(),
          plugin: "flutter_error/server_error");
    }
  }

  Future<CommentModel> updateComment(
      {required CommentModel comment}) async {
    try {
      await commentsRef.doc(comment.id).set(comment.toJson());
      return comment;
    } on FirebaseException catch (e) {
      throw CustomError(code: e.code, message: e.message!, plugin: e.plugin);
    } catch (e) {
      throw CustomError(
          code: "Error!",
          message: e.toString(),
          plugin: "flutter_error/server_error");
    }
  }

  Future<void> patchCommentLike({required String commentId}) async {
    try {

    } on FirebaseException catch (e) {
      throw CustomError(code: e.code, message: e.message!, plugin: e.plugin);
    } catch (e) {
      throw CustomError(
          code: "Error!",
          message: e.toString(),
          plugin: "flutter_error/server_error");
    }
  }


  @override
  Future<CursorPagination<CommentModel>> pagination(
      {PaginationParams paginationParams = const PaginationParams(),
      String? paragraphId, String? userId}) async {
    try {
      // last 다음데이터부터 상위 count만큼의 데이터를 get한다. api호출이다.
      // 가져온 데이터의 마지막 데이터의 id값을 알아낸다.
      // 그 id값의 다음 데이터가 존재하는지 파악한다.(hasNext값 알아내기) api 호출이다.
      CursorPagination<CommentModel> cursorPagination =
          CursorPagination<CommentModel>.initial();
      Meta meta = Meta(count: paginationParams.count);

      final comments = await paginationApiServices.getComments(
          paginationParams: paginationParams, paragraphId: paragraphId!);
      final hasNext = comments.isNotEmpty &&
          await paginationApiServices.hasNextComment(last: comments.last.id, paragraphId: paragraphId!);

      meta = meta.copyWith(hasNext: hasNext);
      cursorPagination = cursorPagination.copyWith(
          meta: meta,
          data: comments.map((comment) => comment as CommentModel).toList());

      return cursorPagination;
    } on FirebaseException catch (e, stack) {
      throw CustomError(code: e.code, message: e.message!, plugin: e.plugin);
    } catch (e, stack) {
      throw CustomError(
          code: "Error!",
          message: e.toString(),
          plugin: "flutter_error/server_error");
    }
  }

  @override
  Future<CommentModel> getById({required String id}) {
    // TODO: implement getById
    throw UnimplementedError();
  }
}
