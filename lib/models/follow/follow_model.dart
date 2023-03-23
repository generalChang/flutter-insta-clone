import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_community/models/community/paragraph_model.dart';
import 'package:flutter_community/models/pagination/model_with_id.dart';

class FollowModel implements IPaginationBaseModel{
  final String id;
  final String userId;
  final String targetUserId;
  final Timestamp timestamp;

  FollowModel({
    String? id,
    required this.userId,
    required this.targetUserId,
    required this.timestamp
  }) : this.id = id ?? uuid.v4();

  factory FollowModel.initial(){
    return FollowModel(
        userId: "",
        targetUserId: "",
    timestamp: Timestamp.now());
  }

  FollowModel copyWith({
    String? id,
    String? userId,
    String? targetUserId,
    Timestamp? timestamp
  }) {
    return FollowModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      targetUserId: targetUserId ?? this.targetUserId,
        timestamp : timestamp ?? this.timestamp
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'userId': this.userId,
      'targetUserId': this.targetUserId,
      "timestamp" : this.timestamp
    };
  }

  factory FollowModel.fromDoc({required DocumentSnapshot followDoc}) {
    final follow = followDoc.data() as Map<String, dynamic>?;
    return FollowModel(
      id: follow!['id'] as String,
      userId: follow!['userId'] as String,
      targetUserId: follow!['targetUserId'] as String,
        timestamp: follow!["timestamp"]
    );
  }
}