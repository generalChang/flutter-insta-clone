import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_community/models/model_with_id_and_like.dart';
import 'package:flutter_community/models/model_with_like.dart';
import 'package:flutter_community/models/pagination/model_with_id.dart';
import 'package:uuid/uuid.dart';
import "package:collection/collection.dart";

import '../comment/comment_model.dart';
import '../like_model.dart';
import '../user/user_model.dart';

Uuid uuid = Uuid();

class ParagraphModel implements IBaseModelWithIdAndLike {
  final UserModel user;
  final String id;
  final String content;
  final List<String> imagesUrl;
  final String videoUrl;
  final Timestamp timestamp;
  List<LikeModel> likes;
  final List<CommentModel> comments;

  ParagraphModel(
      {String? id,
      required this.user,
      required this.content,
      required this.imagesUrl,
      required this.timestamp,
      this.comments = const [],
      this.likes = const [],
      this.videoUrl = ""})
      : this.id = id ?? uuid.v4();

  factory ParagraphModel.fromDoc({required DocumentSnapshot doc}) {
    final paragraph = doc.data() as Map<String, dynamic>?;
    return ParagraphModel(
      user: UserModel.fromJson(json: paragraph!["user"]),
      id: paragraph!["id"],
      content: paragraph!["content"],
      imagesUrl: List<String>.from(paragraph!["imagesUrl"] ?? []),
      videoUrl: paragraph!["videoUrl"] ?? "",
      timestamp: paragraph!["timestamp"],
    );
  }

  factory ParagraphModel.initial() {
    return ParagraphModel(
      user: UserModel.initial(),
      content: "",
      imagesUrl: [],
      videoUrl: "",
      timestamp: Timestamp.now(),
      likes: [],
      comments: [],
    );
  }

  // @override
  // // TODO: implement props
  // List<Object?> get props => [userId, userName, id, title, content, imagesUrl, like,dislike, timestamp];

  Map<String, dynamic> toJson() {
    return {
      "user": this.user.toJson(),
      'id': this.id,
      'content': this.content,
      'imagesUrl': this.imagesUrl,
      "videoUrl": this.videoUrl,
      "timestamp": this.timestamp,
    };
  }

  ParagraphModel copyWith({
    UserModel? user,
    String? id,
    String? content,
    List<String>? imagesUrl,
    Timestamp? timestamp,
    List<LikeModel>? likes,
    List<CommentModel>? comments,
    String? videoUrl,
  }) {
    return ParagraphModel(
      user: user ?? this.user,
      id: id ?? this.id,
      content: content ?? this.content,
      imagesUrl: imagesUrl ?? this.imagesUrl,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }

  @override
  String toString() {
    return 'ParagraphModel{user: $user, id: $id, content: $content, imagesUrl: $imagesUrl, timestamp: $timestamp, likes: $likes, comments: $comments}';
  }
}
