import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_community/consts/firebase_const.dart';
import 'package:flutter_community/models/short_video/short_video_model.dart';

import '../models/comment/comment_model.dart';
import '../models/community/paragraph_model.dart';
import '../models/like_model.dart';
import '../models/user/user_model.dart';

class ShortVideoApiServices {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  ShortVideoApiServices({
    required this.firestore,
    required this.storage,
  });

  Future<ShortVideoModel> writeShortVideoContent(
      {required UserModel user, required String content}) async {
    try {
      final tempshort = ShortVideoModel.initial();
      final short = tempshort.copyWith(
        user: user,
        content: content,
      );

      final result = await shortVideosRef.add(short.toJson());
      return short.copyWith(id: result.id);
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<ShortVideoModel> writeShortVideo(
      {required ShortVideoModel shortVideo, required File video}) async {
    try {
      final refImage =
          storage.ref().child("picked_video").child("${uuid.v4()}" + ".mp4");
      await refImage.putFile(video);
      String downloadUrl = await refImage.getDownloadURL();

      final newShortVideo = shortVideo.copyWith(videoUrl: downloadUrl);

      await shortVideosRef.doc(newShortVideo.id).set(newShortVideo.toJson());

      return newShortVideo;
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<ShortVideoModel> getShortVideoById({required String id}) async {
    try {
      final documentSnapshot = await shortVideosRef.doc(id).get();
      ShortVideoModel short = ShortVideoModel.fromDoc(doc: documentSnapshot);
      short = await getCommentsForShortVideo(short: short);
      short = await getLikesForShortVideo(short: short);
      return short;
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<ShortVideoModel> getCommentsForShortVideo(
      {required ShortVideoModel short}) async {
    //like정보 추가해서 comments반환.
    try {
      final query = commentsRef.where("paragraphId", isEqualTo: short.id);
      final querySnapshot = await query.get();

      List<CommentModel> comments = [];
      for (final commentDoc in querySnapshot.docs) {
        comments.add(CommentModel.fromDoc(doc: commentDoc));
      }

      return short.copyWith(comments: comments);
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e, stack) {
      rethrow;
    }
  }

  Future<ShortVideoModel> getLikesForShortVideo(
      {required ShortVideoModel short}) async {
    //like정보 추가해서 comments반환.
    try {
      final query = likesRef.where("targetId", isEqualTo: short.id);
      final querySnapshot = await query.get();

      List<LikeModel> likes = [];
      for (final likeDoc in querySnapshot.docs) {
        likes.add(LikeModel.fromDoc(doc: likeDoc));
      }

      return short.copyWith(likes: likes);
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e, stack) {
      rethrow;
    }
  }
}
