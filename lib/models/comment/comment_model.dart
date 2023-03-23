import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_community/models/community/paragraph_model.dart';
import 'package:flutter_community/models/model_with_id_and_like.dart';
import 'package:flutter_community/models/model_with_like.dart';
import 'package:flutter_community/models/pagination/model_with_id.dart';
import 'package:flutter_community/models/user/user_model.dart';

import '../like_model.dart';

class CommentModel implements IBaseModelWithIdAndLike {
  final String id;
  final UserModel user;
  final String paragraphId;
  final String message;
  final Timestamp timestamp;
  List<LikeModel> likes;

  CommentModel(
      {required this.paragraphId,
      required this.user,
      String? id,
      required this.message,
      required this.timestamp,
      this.likes = const []})
      : this.id = id ?? uuid.v4();

  factory CommentModel.initial() {
    return CommentModel(
        likes: [],
        user: UserModel.initial(),
        message: "",
        timestamp: Timestamp.now(),
        paragraphId: "");
  }

  factory CommentModel.fromDoc({required DocumentSnapshot doc}) {
    final comment = doc.data() as Map<String, dynamic>?;
    return CommentModel(
        user: UserModel.fromJson(json: comment!["user"]),
        id: comment["id"],
        message: comment["message"],
        timestamp: comment["timestamp"],
        paragraphId: comment["paragraphId"],
        likes: []);
  }

  CommentModel copyWith(
      {UserModel? user,
      String? id,
      String? message,
      Timestamp? timestamp,
      String? paragraphId,
      List<LikeModel>? likes}) {
    return CommentModel(
        user: user ?? this.user,
        id: id ?? this.id,
        message: message ?? this.message,
        timestamp: timestamp ?? this.timestamp,
        paragraphId: paragraphId ?? this.paragraphId,
        likes: likes ?? this.likes);
  }

  Map<String, dynamic> toJson() {
    return {
      'user': this.user.toJson(),
      'id': this.id,
      'message': this.message,
      'timestamp': this.timestamp,
      "paragraphId": this.paragraphId,
    };
  }

  factory CommentModel.fromJson({required Map<String, dynamic> json}) {
    return CommentModel(
        user: UserModel.fromJson(json: json["user"]),
        id: json['id'] as String,
        message: json['message'] as String,
        timestamp: json['timestamp'] as Timestamp,
        paragraphId: json["paragraphId"],
    );
  }
}
