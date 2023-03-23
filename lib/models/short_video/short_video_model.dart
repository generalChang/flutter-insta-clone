import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_community/models/community/paragraph_model.dart';
import 'package:flutter_community/models/model_with_id_and_like.dart';

import '../comment/comment_model.dart';
import '../like_model.dart';
import '../user/user_model.dart';

class ShortVideoModel implements IBaseModelWithIdAndLike {
  final UserModel user;
  final String id;
  final String content;
  final String videoUrl;
  final Timestamp timestamp;
  List<LikeModel> likes;
  final List<CommentModel> comments;

  ShortVideoModel({
    required this.user,
    String? id,
    required this.content,
    required this.videoUrl,
    required this.timestamp,
    this.likes = const [],
    this.comments = const [],
  }) : this.id = id ?? uuid.v4();

  factory ShortVideoModel.fromDoc({required DocumentSnapshot doc}) {
    final shortVideo = doc.data() as Map<String, dynamic>?;
    return ShortVideoModel(
      user: UserModel.fromJson(json: shortVideo!["user"]),
      id: shortVideo!["id"],
      content: shortVideo!["content"],
      videoUrl: shortVideo!["videoUrl"] ?? "",
      timestamp: shortVideo!["timestamp"],
    );
  }

  factory ShortVideoModel.initial(){
    return ShortVideoModel(
        user: UserModel.initial(),
        content: "",
        videoUrl: "",
        timestamp: Timestamp.now());
  }

  ShortVideoModel copyWith({
    UserModel? user,
    String? id,
    String? content,
    String? videoUrl,
    Timestamp? timestamp,
    List<LikeModel>? likes,
    List<CommentModel>? comments,
  }) {
    return ShortVideoModel(
      user: user ?? this.user,
      id: id ?? this.id,
      content: content ?? this.content,
      videoUrl: videoUrl ?? this.videoUrl,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': this.user.toJson(),
      'id': this.id,
      'content': this.content,
      'videoUrl': this.videoUrl,
      'timestamp': this.timestamp,
    };
  }
}