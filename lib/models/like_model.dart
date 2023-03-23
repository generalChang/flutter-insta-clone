import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_community/models/community/paragraph_model.dart';

class LikeModel {
  final String id;
  final String userId;
  final String targetId;

  LikeModel({
    required this.targetId,
    required this.userId,
    String? id,
  }) : this.id = id ?? uuid.v4();

  factory LikeModel.initial() {
    return LikeModel(userId: "", targetId: "");
  }

  LikeModel copyWith({
    String? userId,
    String? id,
    String? targetId
  }) {
    return LikeModel(
      targetId: targetId ?? this.targetId,
      userId: userId ?? this.userId,
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': this.userId,
      'id': this.id,
      "targetId": this.targetId
    };
  }

  factory LikeModel.fromDoc({required DocumentSnapshot doc}) {
    final like = doc.data() as Map<String, dynamic>?;
    return LikeModel(
      userId: like!['userId'] as String,
      id: like!['id'] as String,
      targetId: like["targetId"],
    );
  }
  factory LikeModel.fromJson({required Map<String, dynamic> json}) {
    return LikeModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      targetId: json["targetId"]
    );
  } //누가 어떤 게시물 혹은 댓글에 좋아요를 눌렀는지 나타내는 모델.

}
