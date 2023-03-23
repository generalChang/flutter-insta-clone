import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_community/consts/firebase_const.dart';
import 'package:flutter_community/models/comment/comment_model.dart';

class CommentApiServices{
  final FirebaseFirestore firestore;

  CommentApiServices({
    required this.firestore,
  });

  Future<CommentModel> getCommentById({required String commentId}) async {
    try {
      final commentDocument = await commentsRef.doc(commentId);
      final commentDoc = await commentDocument.get();
      final comment = CommentModel.fromDoc(doc: commentDoc);
      return comment;
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // Future<void> uplike(
  //     {required String commentId}) async {
  //   try {
  //     final comment = await getCommentById(commentId: commentId);
  //     await commentsRef.doc(commentId).set(
  //       comment.copyWith(like: comment.like+1).toJson()
  //     );
  //   } on FirebaseException catch (e) {
  //     rethrow;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }
  //
  // Future<void> unlike(
  //     {required String commentId}) async {
  //   try {
  //     final comment = await getCommentById(commentId: commentId);
  //     await commentsRef.doc(commentId).set(
  //         comment.copyWith(like: comment.like-1).toJson()
  //     );
  //   } on FirebaseException catch (e) {
  //     rethrow;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }
}