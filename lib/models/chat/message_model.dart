import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_community/models/community/paragraph_model.dart';
import 'package:flutter_community/models/user/user_model.dart';

class MessageModel{
  final String id; //메세지 식별 id
  final String content;
  final Timestamp timestamp;
  final UserModel user;
  final List<String> imagesUrl;
  final String videoUrl;

  MessageModel({
    String? id,
    required this.content,
    required this.timestamp,
    required this.user,
    this.imagesUrl = const [],
    this.videoUrl = ""
  }) : this.id = id ?? uuid.v4();

  factory MessageModel.initial(){
    return MessageModel(
        content: "",
        timestamp: Timestamp.now(),
        user: UserModel.initial());
  }

  MessageModel copyWith({
    String? id,
    String? content,
    Timestamp? timestamp,
    UserModel? user,
    List<String>? imagesUrl,
    String? videoUrl
  }) {
    return MessageModel(
      id: id ?? this.id,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      user: user ?? this.user,
      imagesUrl: imagesUrl ?? this.imagesUrl,
        videoUrl : videoUrl ?? this.videoUrl
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'content': this.content,
      'timestamp': this.timestamp,
      'user': this.user.toJson(),
      "imagesUrl":imagesUrl,
      "videoUrl":videoUrl,
    };
  }

  factory MessageModel.fromDoc({required DocumentSnapshot messageDoc}) {
    final message = messageDoc.data() as Map<String, dynamic>?;
    return MessageModel(
      id: message!['id'] as String,
      content: message['content'] as String,
      timestamp: message['timestamp'] as Timestamp,
      user: UserModel.fromJson(json: message["user"]),
        imagesUrl: List<String>.from(message["imagesUrl"] ?? [],),
        videoUrl : message["videoUrl"] ?? ""
    );
  }
}