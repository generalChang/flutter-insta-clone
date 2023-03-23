import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_community/consts/firebase_const.dart';
import 'package:flutter_community/models/comment/comment_model.dart';
import 'package:flutter_community/models/community/paragraph_model.dart';
import 'package:flutter_community/models/follow/follow_model.dart';
import 'package:flutter_community/models/like_model.dart';
import 'package:flutter_community/models/pagination/model_with_id.dart';
import 'package:flutter_community/models/user/user_model.dart';

import '../models/pagination/pagination_params.dart';
import '../models/short_video/short_video_model.dart';

enum PaginationType {
  comment,
  paragraph,
}

class PaginationApiServices<T extends IPaginationBaseModel,
    U extends CollectionReference<Map<String, dynamic>>> {
  final FirebaseFirestore firestore;
  final U collectionRef;
  final PaginationType paginationType;

  PaginationApiServices({
    required this.collectionRef,
    required this.firestore,
    required this.paginationType,
  });

  Future<DocumentSnapshot> getDocumentSnapshotByDocId(
      {required String documentId}) async {
    try {
      final documentSnapshot = await collectionRef.doc(documentId).get();
      return documentSnapshot;
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e, stack) {
      print(e);
      print(stack);
      rethrow;
    }
  }

  Future<List<ParagraphModel>> getParagraphs(
      {PaginationParams paginationParams = const PaginationParams()}) async {
    try {
      Query<Map<String, dynamic>> afterDataQuerySnapshot;
      if (paginationParams.last != null) {
        afterDataQuerySnapshot = await collectionRef
            .orderBy("timestamp", descending: true)
            .startAfterDocument(await getDocumentSnapshotByDocId(
                documentId: paginationParams.last!))
            .limit(paginationParams.count);
      } else {
        afterDataQuerySnapshot = await collectionRef
            .orderBy("timestamp", descending: true)
            .limit(paginationParams.count);
      }
      final datasQuerySnapshot = await afterDataQuerySnapshot.get();

      List<ParagraphModel> list = [];
      for (final doc in datasQuerySnapshot.docs) {
        list.add(ParagraphModel.fromDoc(doc: doc));
      }
      List<ParagraphModel> results =
          await getLikesForParagraph(paragraphs: list);
      List<ParagraphModel> resultsWithComments =
          await getCommentsForParagraph(paragraphs: results);
      return resultsWithComments;
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e, stack) {
      rethrow;
    }
  }

  Future<List<ParagraphModel>> getParagraphsOfUser(
      {PaginationParams paginationParams = const PaginationParams(),
      String? userId}) async {
    // db.collection('cities')
    //     .orderBy('population')
    //     .startAfter(last.data().population)
    //     .limit(3);
    try {
      Query<Map<String, dynamic>> afterDataQuerySnapshot;

      if (paginationParams.last != null) {
        afterDataQuerySnapshot = await collectionRef
            .orderBy("timestamp", descending: true)
            .where("user.id", isEqualTo: userId!)
            .startAfterDocument(await getDocumentSnapshotByDocId(
                documentId: paginationParams.last!))
            .limit(paginationParams.count);
      } else {
        afterDataQuerySnapshot = await collectionRef
            .orderBy("timestamp", descending: true)
            .where("user.id", isEqualTo: userId!)
            .limit(paginationParams.count);
      }
      final datasQuerySnapshot = await afterDataQuerySnapshot.get();

      List<ParagraphModel> list = [];
      for (final doc in datasQuerySnapshot.docs) {
        list.add(ParagraphModel.fromDoc(doc: doc));
      }
      List<ParagraphModel> results =
          await getLikesForParagraph(paragraphs: list);
      List<ParagraphModel> resultsWithComments =
          await getCommentsForParagraph(paragraphs: results);
      return resultsWithComments;
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e, stack) {
      print(e);
      print(stack);
      rethrow;
    }
  }

  Future<List<FollowModel>> getFollowers(
      {PaginationParams paginationParams = const PaginationParams(),
      required String userId}) async {
    try {
      Query<Map<String, dynamic>> afterDataQuerySnapshot;
      if (paginationParams.last != null) {
        afterDataQuerySnapshot = await followsRef
            .orderBy("timestamp", descending: true)
            .where("userId", isEqualTo: userId)
            .startAfterDocument(await getDocumentSnapshotByDocId(
                documentId: paginationParams.last!))
            .limit(paginationParams.count);
      } else {
        afterDataQuerySnapshot = await followsRef
            .orderBy("timestamp", descending: true)
            .where("userId", isEqualTo: userId)
            .limit(paginationParams.count);
      }
      final datasQuerySnapshot = await afterDataQuerySnapshot.get();

      List<FollowModel> list = [];
      for (final doc in datasQuerySnapshot.docs) {
        list.add(FollowModel.fromDoc(followDoc: doc));
      }

      return list;
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e, stack) {
      rethrow;
    }
  }

  Future<List<FollowModel>> getAllFollowers({required String userId}) async {
    try {
      Query<Map<String, dynamic>> afterDataQuerySnapshot;

      afterDataQuerySnapshot = await followsRef
          .orderBy("timestamp", descending: true)
          .where("userId", isEqualTo: userId);

      final datasQuerySnapshot = await afterDataQuerySnapshot.get();

      List<FollowModel> list = [];
      for (final doc in datasQuerySnapshot.docs) {
        list.add(FollowModel.fromDoc(followDoc: doc));
      }

      return list;
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e, stack) {
      rethrow;
    }
  }

  Future<List<UserModel>> getUserFromFollow(
      {required List<FollowModel> follows}) async {
    try {
      List<UserModel> list = [];
      List<Future<DocumentSnapshot>> futures = [];
      for (final follow in follows) {
        final documentReference = usersRef.doc(follow.targetUserId);
        futures.add(documentReference.get());
      }

      List<DocumentSnapshot> documentSnapshots = await Future.wait(futures);
      for (final userDoc in documentSnapshots) {
        list.add(UserModel.fromDoc(userDoc: userDoc));
      }
      return list;
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e, stack) {
      rethrow;
    }
  }

  Future<List<CommentModel>> getComments(
      {PaginationParams paginationParams = const PaginationParams(),
      required String paragraphId}) async {
    try {
      Query<Map<String, dynamic>> afterDataQuerySnapshot;
      if (paginationParams.last != null) {
        afterDataQuerySnapshot = await collectionRef
            .orderBy("timestamp", descending: true)
            .where("paragraphId", isEqualTo: paragraphId)
            .startAfterDocument(await getDocumentSnapshotByDocId(
                documentId: paginationParams.last!))
            .limit(paginationParams.count);
      } else {
        afterDataQuerySnapshot = await collectionRef
            .orderBy("timestamp", descending: true)
            .where("paragraphId", isEqualTo: paragraphId)
            .limit(paginationParams.count);
      }
      final datasQuerySnapshot = await afterDataQuerySnapshot.get();

      List<CommentModel> list = [];
      for (final doc in datasQuerySnapshot.docs) {
        list.add(CommentModel.fromDoc(doc: doc));
      }

      List<CommentModel> results = await getLikesForComment(comments: list);
      return results;
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e, stack) {
      rethrow;
    }
  }

  Future<List<ShortVideoModel>> getShortVideos(
      {PaginationParams paginationParams = const PaginationParams()}) async {
    try {
      Query<Map<String, dynamic>> afterDataQuerySnapshot;
      if (paginationParams.last != null) {
        afterDataQuerySnapshot = await shortVideosRef
            .orderBy("timestamp", descending: true)
            .startAfterDocument(await getDocumentSnapshotByDocId(
                documentId: paginationParams.last!))
            .limit(paginationParams.count);
      } else {
        //처음 페이지네이션하는경우.
        afterDataQuerySnapshot = await shortVideosRef
            .orderBy("timestamp", descending: true)
            .limit(paginationParams.count);
      }
      final datasQuerySnapshot = await afterDataQuerySnapshot.get();

      List<ShortVideoModel> list = [];
      for (final doc in datasQuerySnapshot.docs) {
        list.add(ShortVideoModel.fromDoc(doc: doc));
      }
      List<ShortVideoModel> results = await getLikesForShortVideo(shorts: list);
      List<ShortVideoModel> resultsWithComments =
          await getCommentsForShortVideo(shorts: results);
      return resultsWithComments;
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e, stack) {
      rethrow;
    }
  }

  Future<List<ShortVideoModel>> getShortVideosOfUser(
      {PaginationParams paginationParams = const PaginationParams(),
        required String userId}) async {
    try {
      Query<Map<String, dynamic>> afterDataQuerySnapshot;
      if (paginationParams.last != null) {
        afterDataQuerySnapshot = await shortVideosRef
            .orderBy("timestamp", descending: true)
            .where("user.id", isEqualTo: userId  )
            .startAfterDocument(await getDocumentSnapshotByDocId(
            documentId: paginationParams.last!))
            .limit(paginationParams.count);
      } else {
        //처음 페이지네이션하는경우.
        afterDataQuerySnapshot = await shortVideosRef
            .orderBy("timestamp", descending: true)
            .where("user.id", isEqualTo: userId  )
            .limit(paginationParams.count);
      }
      final datasQuerySnapshot = await afterDataQuerySnapshot.get();

      List<ShortVideoModel> list = [];
      for (final doc in datasQuerySnapshot.docs) {
        list.add(ShortVideoModel.fromDoc(doc: doc));
      }
      List<ShortVideoModel> results = await getLikesForShortVideo(shorts: list);
      List<ShortVideoModel> resultsWithComments =
      await getCommentsForShortVideo(shorts: results);
      return resultsWithComments;
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e, stack) {
      rethrow;
    }
  }

  Future<List<CommentModel>> getLikesForComment(
      {required List<CommentModel> comments}) async {
    //like정보 추가해서 comments반환.
    try {
      List<CommentModel> list = [];
      List<Future> futures = [];
      for (final comment in comments) {
        final query = likesRef.where("targetId", isEqualTo: comment.id);
        final querySnapshot = await query.get();

        List<LikeModel> likes = [];
        for (final likeDoc in querySnapshot.docs) {
          likes.add(LikeModel.fromDoc(doc: likeDoc));
        }

        list.add(comment.copyWith(likes: likes));
      }
      return list;
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e, stack) {
      rethrow;
    }
  }

  Future<List<ParagraphModel>> getCommentsForParagraph(
      {required List<ParagraphModel> paragraphs}) async {
    //like정보 추가해서 comments반환.
    try {
      List<ParagraphModel> list = [];
      for (final paragraph in paragraphs) {
        final query = commentsRef.where("paragraphId", isEqualTo: paragraph.id);
        final querySnapshot = await query.get();

        List<CommentModel> comments = [];
        for (final commentDoc in querySnapshot.docs) {
          comments.add(CommentModel.fromDoc(doc: commentDoc));
        }

        list.add(paragraph.copyWith(comments: comments));
      }
      return list;
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e, stack) {
      rethrow;
    }
  }

  Future<List<ShortVideoModel>> getCommentsForShortVideo(
      {required List<ShortVideoModel> shorts}) async {
    //like정보 추가해서 comments반환.
    try {
      List<ShortVideoModel> list = [];
      for (final short in shorts) {
        final query = commentsRef.where("paragraphId", isEqualTo: short.id);
        final querySnapshot = await query.get();

        List<CommentModel> comments = [];
        for (final commentDoc in querySnapshot.docs) {
          comments.add(CommentModel.fromDoc(doc: commentDoc));
        }

        list.add(short.copyWith(comments: comments));
      }
      return list;
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e, stack) {
      rethrow;
    }
  }

  Future<List<ParagraphModel>> getLikesForParagraph(
      {required List<ParagraphModel> paragraphs}) async {
    //like정보 추가해서 comments반환.
    try {
      List<ParagraphModel> list = [];
      List<Future> futures = [];
      for (final paragraph in paragraphs) {
        final query = likesRef.where("targetId", isEqualTo: paragraph.id);
        final querySnapshot = await query.get();

        List<LikeModel> likes = [];
        for (final likeDoc in querySnapshot.docs) {
          likes.add(LikeModel.fromDoc(doc: likeDoc));
        }

        list.add(paragraph.copyWith(likes: likes));
      }
      return list;
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e, stack) {
      rethrow;
    }
  }

  Future<List<ShortVideoModel>> getLikesForShortVideo(
      {required List<ShortVideoModel> shorts}) async {
    //like정보 추가해서 comments반환.
    try {
      List<ShortVideoModel> list = [];
      List<Future> futures = [];
      for (final short in shorts) {
        final query = likesRef.where("targetId", isEqualTo: short.id);
        final querySnapshot = await query.get();

        List<LikeModel> likes = [];
        for (final likeDoc in querySnapshot.docs) {
          likes.add(LikeModel.fromDoc(doc: likeDoc));
        }

        list.add(short.copyWith(likes: likes));
      }
      return list;
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e, stack) {
      rethrow;
    }
  }

  Future<bool> hasNext({required String last}) async {
    // db.collection('cities')
    //     .orderBy('population')
    //     .startAfter(last.data().population)
    //     .limit(3);
    try {
      Query<Map<String, dynamic>> afterDataQuerySnapshot;
      afterDataQuerySnapshot = await collectionRef
          .orderBy("timestamp", descending: true)
          .startAfterDocument(
              await getDocumentSnapshotByDocId(documentId: last))
          .limit(1);

      final datasQuerySnapshot = await afterDataQuerySnapshot.get();

      if (paginationType == PaginationType.paragraph) {
        List<T> list = [];
        for (final doc in datasQuerySnapshot.docs) {
          list.add(ParagraphModel.fromDoc(doc: doc) as T);
        }
        return list.isNotEmpty;
      } else if (paginationType == PaginationType.comment) {
        List<T> list = [];
        for (final doc in datasQuerySnapshot.docs) {
          list.add(CommentModel.fromDoc(doc: doc) as T);
        }
        return list.isNotEmpty;
      }

      return false;
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e, stack) {
      print(e);
      print(stack);
      rethrow;
    }
  }

  Future<bool> hasNextParagraphOfUser(
      {required String last, required String userId}) async {
    // db.collection('cities')
    //     .orderBy('population')
    //     .startAfter(last.data().population)
    //     .limit(3);
    try {
      Query<Map<String, dynamic>> afterDataQuerySnapshot;
      afterDataQuerySnapshot = await collectionRef
          .orderBy("timestamp", descending: true)
          .where("user.id", isEqualTo: userId!)
          .startAfterDocument(
              await getDocumentSnapshotByDocId(documentId: last))
          .limit(1);

      final datasQuerySnapshot = await afterDataQuerySnapshot.get();

      List<ParagraphModel> list = [];
      for (final doc in datasQuerySnapshot.docs) {
        list.add(ParagraphModel.fromDoc(doc: doc));
      }
      return list.isNotEmpty;
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e, stack) {
      rethrow;
    }
  }

  Future<bool> hasNextComment(
      {required String last, required String paragraphId}) async {
    // db.collection('cities')
    //     .orderBy('population')
    //     .startAfter(last.data().population)
    //     .limit(3);
    try {
      Query<Map<String, dynamic>> afterDataQuerySnapshot;
      afterDataQuerySnapshot = await collectionRef
          .orderBy("timestamp", descending: true)
          .where("paragraphId", isEqualTo: paragraphId)
          .startAfterDocument(
              await getDocumentSnapshotByDocId(documentId: last))
          .limit(1);

      final datasQuerySnapshot = await afterDataQuerySnapshot.get();

      if (paginationType == PaginationType.paragraph) {
        List<T> list = [];
        for (final doc in datasQuerySnapshot.docs) {
          list.add(ParagraphModel.fromDoc(doc: doc) as T);
        }
        return list.isNotEmpty;
      } else if (paginationType == PaginationType.comment) {
        List<T> list = [];
        for (final doc in datasQuerySnapshot.docs) {
          list.add(CommentModel.fromDoc(doc: doc) as T);
        }
        return list.isNotEmpty;
      }

      return false;
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e, stack) {
      print(e);
      print(stack);
      rethrow;
    }
  }

  Future<bool> hasNextFollow(
      {required String last, required String userId}) async {
    try {
      Query<Map<String, dynamic>> afterDataQuerySnapshot;
      afterDataQuerySnapshot = await followsRef
          .orderBy("timestamp", descending: true)
          .where("userId", isEqualTo: userId)
          .startAfterDocument(
              await getDocumentSnapshotByDocId(documentId: last))
          .limit(1);

      final datasQuerySnapshot = await afterDataQuerySnapshot.get();

      List<FollowModel> list = [];
      for (final doc in datasQuerySnapshot.docs) {
        list.add(FollowModel.fromDoc(followDoc: doc));
      }
      return list.isNotEmpty;
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e, stack) {
      print(e);
      print(stack);
      rethrow;
    }
  }

  Future<bool> hasNextShortVideo({required String last}) async {
    // db.collection('cities')
    //     .orderBy('population')
    //     .startAfter(last.data().population)
    //     .limit(3);
    try {
      Query<Map<String, dynamic>> afterDataQuerySnapshot;
      afterDataQuerySnapshot = await shortVideosRef
          .orderBy("timestamp", descending: true)
          .startAfterDocument(
              await getDocumentSnapshotByDocId(documentId: last))
          .limit(1);

      final datasQuerySnapshot = await afterDataQuerySnapshot.get();

      List<ShortVideoModel> list = [];
      for (final doc in datasQuerySnapshot.docs) {
        list.add(ShortVideoModel.fromDoc(doc: doc));
      }
      return list.isNotEmpty;
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e, stack) {
      print(e);
      print(stack);
      rethrow;
    }
  }

  Future<bool> hasNextShortVideoOfUser({required String last, required String userId}) async {
    // db.collection('cities')
    //     .orderBy('population')
    //     .startAfter(last.data().population)
    //     .limit(3);
    try {
      Query<Map<String, dynamic>> afterDataQuerySnapshot;
      afterDataQuerySnapshot = await shortVideosRef
          .orderBy("timestamp", descending: true)
          .where("user.id", isEqualTo: userId)
          .startAfterDocument(
          await getDocumentSnapshotByDocId(documentId: last))
          .limit(1);

      final datasQuerySnapshot = await afterDataQuerySnapshot.get();

      List<ShortVideoModel> list = [];
      for (final doc in datasQuerySnapshot.docs) {
        list.add(ShortVideoModel.fromDoc(doc: doc));
      }
      return list.isNotEmpty;
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e, stack) {
      print(e);
      print(stack);
      rethrow;
    }
  }
}
