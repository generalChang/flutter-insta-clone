import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_community/consts/firebase_const.dart';
import 'package:flutter_community/models/user/user_model.dart';

import '../models/comment/comment_model.dart';
import '../models/community/paragraph_model.dart';
import '../models/like_model.dart';

class ParagraphApiServices {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  ParagraphApiServices({
    required this.firestore,
    required this.storage,
  });

  Future<ParagraphModel> writeParagraph(
      {required UserModel user, required String content}) async {
    try {
      final tempParagraph = ParagraphModel.initial();
      final paragraph = tempParagraph.copyWith(
        user: user,
        content: content,
      );

      final result = await paragraphsRef.add(paragraph.toJson());
      return paragraph.copyWith(id: result.id);
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<ParagraphModel> writeImages(
      {required ParagraphModel paragraph, required List<File> images}) async {
    try {
      List<Future<String>> futures = [];
      List<String> downloadUrls = [];
      if (images != null) {
        for (final image in images) {
          final refImage = storage
              .ref()
              .child("picked_image")
              .child("${uuid.v4()}" + ".png");
          await refImage.putFile(image);
          futures.add(refImage.getDownloadURL());
        }

        downloadUrls = await Future.wait(futures);
      }

      final newParagraph =
          paragraph.copyWith(imagesUrl: List<String>.from(downloadUrls));

      await paragraphsRef.doc(paragraph.id).set(newParagraph.toJson());

      return newParagraph;
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }


  Future<ParagraphModel> updateParagraph(
      {required ParagraphModel paragraph}) async {
    try {
      final result =
          await paragraphsRef.doc(paragraph.id).set(paragraph.toJson());
      return paragraph;
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<ParagraphModel> getParagraphById({required String id}) async {
    try {
      final documentSnapshot = await paragraphsRef.doc(id).get();
      ParagraphModel paragraph = ParagraphModel.fromDoc(doc: documentSnapshot);
      paragraph = await getCommentsForParagraph(paragraph: paragraph);
      paragraph = await getLikesForParagraph(paragraph: paragraph);
      return paragraph;
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<ParagraphModel> updateImages(
      {required ParagraphModel paragraph, required List<File> images}) async {
    try {
      List<Future<String>> futures = [];
      List<String> downloadUrls = [];
      if (images != null) {
        for (final image in images) {
          final refImage = storage
              .ref()
              .child("picked_image")
              .child("${uuid.v4()}" + ".png");
          await refImage.putFile(image);
          futures.add(refImage.getDownloadURL());
        }

        downloadUrls = await Future.wait(futures);
      }

      final newParagraph =
          paragraph.copyWith(imagesUrl: List<String>.from(downloadUrls));

      await paragraphsRef.doc(paragraph.id).set(newParagraph.toJson());

      return newParagraph;
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<ParagraphModel> getCommentsForParagraph(
      {required ParagraphModel paragraph}) async {
    //like정보 추가해서 comments반환.
    try {
      final query = commentsRef.where("paragraphId", isEqualTo: paragraph.id);
      final querySnapshot = await query.get();

      List<CommentModel> comments = [];
      for (final commentDoc in querySnapshot.docs) {
        comments.add(CommentModel.fromDoc(doc: commentDoc));
      }

      return paragraph.copyWith(comments: comments);
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e, stack) {
      rethrow;
    }
  }

  Future<ParagraphModel> getLikesForParagraph(
      {required ParagraphModel paragraph}) async {
    //like정보 추가해서 comments반환.
    try {
      final query = likesRef.where("targetId", isEqualTo: paragraph.id);
      final querySnapshot = await query.get();

      List<LikeModel> likes = [];
      for (final likeDoc in querySnapshot.docs) {
        likes.add(LikeModel.fromDoc(doc: likeDoc));
      }

      return paragraph.copyWith(likes: likes);
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e, stack) {
      rethrow;
    }
  }
}
