import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_community/consts/firebase_const.dart';
import 'package:flutter_community/models/chat/chat_room_model.dart';
import 'package:flutter_community/models/chat/message_model.dart';
import 'package:flutter_community/models/custom_error.dart';
import 'package:flutter_community/models/user/user_model.dart';

import '../models/community/paragraph_model.dart';

class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  ChatRepository({
    required this.firestore,
    required this.storage
  });

  Stream<QuerySnapshot<Map<String, dynamic>>> getChatRooms(
      {required String userId}) {
    return chatsRef
        .where("members", arrayContains: userId)
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(
      {required String chatRoomId}) {
    return chatsRef.doc(chatRoomId).collection("messages").orderBy("timestamp", descending: true).snapshots();
  }

  Future<bool> hasChatRoom({required UserModel me, required UserModel member}) async {
    try {
      final query = await chatsRef.where("members", arrayContains: me.id);
      final querySnapshot = await query.get();

      List<ChatRoomModel> chatrooms = [];
      for(final chatRoomDoc in querySnapshot.docs) {
        chatrooms.add(ChatRoomModel.fromDoc(chatDoc: chatRoomDoc));
      }

      List<ChatRoomModel> chatRoomsByMeAndMember = [];

      chatRoomsByMeAndMember = chatrooms.where((chatroom) => chatroom.members.where((user) => user.id == member.id).isNotEmpty).toList();



      return chatRoomsByMeAndMember.isNotEmpty;
    } on FirebaseException catch (e) {
      throw CustomError(code: e.code, message: e.message!, plugin: e.plugin);
    } catch (e, stack) {
      print(e);
      print(stack);
      throw CustomError(
          code: "Error!",
          message: e.toString(),
          plugin: "flutter_error/server_error");
    }
  }

  Future<ChatRoomModel> joinChatRoomByMember({required UserModel me, required UserModel member}) async {
    try {
      final query = await chatsRef.where("members", arrayContains: me.id);
      final querySnapshot = await query.get();

      List<ChatRoomModel> chatrooms = [];
      for(final chatRoomDoc in querySnapshot.docs) {
        chatrooms.add(ChatRoomModel.fromDoc(chatDoc: chatRoomDoc));
      }

      List<ChatRoomModel> chatRoomsByMeAndMember = [];

      chatRoomsByMeAndMember = chatrooms.where((chatroom) => chatroom.members.where((user) => user.id == member.id).isNotEmpty).toList();



      return chatRoomsByMeAndMember.first;
    } on FirebaseException catch (e) {
      throw CustomError(code: e.code, message: e.message!, plugin: e.plugin);
    } catch (e) {
      throw CustomError(
          code: "Error!",
          message: e.toString(),
          plugin: "flutter_error/server_error");
    }
  }

  Future<ChatRoomModel> enterChatRoomByChatRoomId({required String chatRoomId}) async {
    try {
      final chatRoomDocumentReference = await chatsRef.doc(chatRoomId);
      final chatroomDocuemntSnapshot = await chatRoomDocumentReference.get();
      return ChatRoomModel.fromDoc(chatDoc: chatroomDocuemntSnapshot);
    } on FirebaseException catch (e) {
      throw CustomError(code: e.code, message: e.message!, plugin: e.plugin);
    } catch (e) {
      throw CustomError(
          code: "Error!",
          message: e.toString(),
          plugin: "flutter_error/server_error");
    }
  }

  Future<ChatRoomModel> enterChatRoom({required UserModel me, required UserModel member}) async {
    try {
      final isAlreadyRoom = await hasChatRoom(me: me, member: member);
      ChatRoomModel chatroom = ChatRoomModel.initial();
      if(isAlreadyRoom){
        //이미 잇으면
        chatroom = await joinChatRoomByMember(me: me, member: member);

      }else{
        chatroom = await createChatRoom(me: me, member: member);
      }
      return chatroom;
    } on FirebaseException catch (e) {
      throw CustomError(code: e.code, message: e.message!, plugin: e.plugin);
    } catch (e,stack) {

      throw CustomError(
          code: "Error!",
          message: e.toString(),
          plugin: "flutter_error/server_error");
    }
  }

  Future<ChatRoomModel> createChatRoom({required UserModel me, required UserModel member}) async {
    try {
      ChatRoomModel chatroom = ChatRoomModel.initial();
      chatroom = chatroom.copyWith(roomName: "${member.name}님과의 대화",
      members: [me, member], );
      final documentReference = await chatsRef.add(chatroom.toJson());
      chatroom = chatroom.copyWith(id: documentReference.id);
      await chatsRef.doc(documentReference.id).set(
          chatroom.toJson()
      );
      return chatroom;
    } on FirebaseException catch (e) {
      throw CustomError(code: e.code, message: e.message!, plugin: e.plugin);
    } catch (e) {
      throw CustomError(
          code: "Error!",
          message: e.toString(),
          plugin: "flutter_error/server_error");
    }
  }

  Future<void> sendImages({required String chatRoomId, required UserModel user, required List<File> images}) async {
    try {
      MessageModel message = MessageModel.initial();
      message = message.copyWith(user: user, content: "");

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

      message = message.copyWith(imagesUrl: downloadUrls);
      final documentReference = await chatsRef
          .doc(chatRoomId)
          .collection("messages")
          .add(message.toJson());
      await chatsRef
          .doc(chatRoomId)
          .collection("messages")
          .doc(documentReference.id)
          .set(message.copyWith(id: documentReference.id).toJson());
      await chatsRef.doc(chatRoomId).update({
        "recentMessage": "사진을 보냈습니다.",
        "timestamp":Timestamp.now()
      });
    } on FirebaseException catch (e) {
      throw CustomError(code: e.code, message: e.message!, plugin: e.plugin);
    } catch (e) {
      throw CustomError(
          code: "Error!",
          message: e.toString(),
          plugin: "flutter_error/server_error");
    }
  }

  Reference uploadVideo({
    required String chatRoomId,
    required UserModel user,
    required File video})  {
    try {
      MessageModel message = MessageModel.initial();
      message = message.copyWith(user: user, content: "");


      final refVideo = storage
          .ref()
          .child("picked_video")
          .child("${uuid.v4()}" + ".mp4");
      return refVideo;
      // UploadTask uploadTask = refVideo.putFile(video);
      //
      // return uploadTask;
      // await refVideo.putFile(video);
      //
      // String downloadUrl = await refVideo.getDownloadURL();
      //
      // message = message.copyWith(videoUrl: downloadUrl);
      // final documentReference = await chatsRef
      //     .doc(chatRoomId)
      //     .collection("messages")
      //     .add(message.toJson());
      // await chatsRef
      //     .doc(chatRoomId)
      //     .collection("messages")
      //     .doc(documentReference.id)
      //     .set(message.copyWith(id: documentReference.id).toJson());
      // await chatsRef.doc(chatRoomId).update({
      //   "recentMessage": "동영상을 보냈습니다.",
      //   "timestamp":Timestamp.now()
      // });
    } on FirebaseException catch (e) {
      throw CustomError(code: e.code, message: e.message!, plugin: e.plugin);
    } catch (e) {
      throw CustomError(
          code: "Error!",
          message: e.toString(),
          plugin: "flutter_error/server_error");
    }
  }

  Future<void> uploadVideoDetail({required String chatRoomId,
    required UserModel user,
    required String downloadUrl}) async {
    MessageModel message = MessageModel.initial();
    message = message.copyWith(user: user, content: "");
    message = message.copyWith(videoUrl: downloadUrl);
    final documentReference = await chatsRef
        .doc(chatRoomId)
        .collection("messages")
        .add(message.toJson());
    await chatsRef
        .doc(chatRoomId)
        .collection("messages")
        .doc(documentReference.id)
        .set(message.copyWith(id: documentReference.id).toJson());
    await chatsRef.doc(chatRoomId).update({
      "recentMessage": "동영상을 보냈습니다.",
      "timestamp":Timestamp.now()
    });
  }

  Future<void> sendMesage(
      {required String chatRoomId,
      required UserModel user,
      required String content}) async {
    try {
      MessageModel message = MessageModel.initial();
      message = message.copyWith(user: user, content: content);
      final documentReference = await chatsRef
          .doc(chatRoomId)
          .collection("messages")
          .add(message.toJson());
      await chatsRef
          .doc(chatRoomId)
          .collection("messages")
          .doc(documentReference.id)
          .set(message.copyWith(id: documentReference.id).toJson());
      await chatsRef.doc(chatRoomId).update({
        "recentMessage":content,
        "timestamp":Timestamp.now()
      });
    } on FirebaseException catch (e) {
      throw CustomError(code: e.code, message: e.message!, plugin: e.plugin);
    } catch (e) {
      throw CustomError(
          code: "Error!",
          message: e.toString(),
          plugin: "flutter_error/server_error");
    }
  }
}
