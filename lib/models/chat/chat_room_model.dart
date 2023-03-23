import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_community/models/community/paragraph_model.dart';
import 'package:flutter_community/models/user/user_model.dart';

class ChatRoomModel{
  final String id; //방 id
  final String roomName; //방이름
  final String recentMessage; //방의 최근 메세지
  final List<UserModel> members; //방에 있는 사람들
  final Timestamp timestamp;

  ChatRoomModel({
    String? id,
    required this.roomName,
    required this.recentMessage,
    this.members = const [],
    required this.timestamp,
  }) : this.id = id ?? uuid.v4();

  factory ChatRoomModel.initial(){
    return ChatRoomModel(
        roomName: "",
        recentMessage: "",
        members: [],
        timestamp: Timestamp.now());
  }

  ChatRoomModel copyWith({
    String? id,
    String? roomName,
    String? recentMessage,
    List<UserModel>? members,
    Timestamp? timestamp,
  }) {
    return ChatRoomModel(
      id: id ?? this.id,
      roomName: roomName ?? this.roomName,
      recentMessage: recentMessage ?? this.recentMessage,
      members: members ?? this.members,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'roomName': this.roomName,
      'recentMessage': this.recentMessage,
      'members': this.members.map((member) => member.id).toList(),
      'timestamp': this.timestamp,
    };
  }

  factory ChatRoomModel.fromDoc({required DocumentSnapshot chatDoc}) {
    final chatroom = chatDoc.data() as Map<String, dynamic>?;
    return ChatRoomModel(
      id: chatroom!['id'] as String,
      roomName: chatroom['roomName'] as String,
      recentMessage: chatroom['recentMessage'] as String,
      timestamp: chatroom['timestamp'] as Timestamp,
      members: chatroom["members"].map<UserModel>((userid) => UserModel.initial().copyWith(id: userid)).toList()
    );
  }
}