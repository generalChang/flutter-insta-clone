import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_community/models/chat/chat_room_model.dart';
import 'package:flutter_community/models/custom_error.dart';
import 'package:meta/meta.dart';

import '../../models/chat/message_model.dart';
import '../../models/user/user_model.dart';
import '../../repositories/chat_repository.dart';

part 'chat_room_state.dart';

class ChatRoomCubit extends Cubit<ChatRoomState> {
  final ChatRepository repository;
  StreamSubscription? messageStreamSubscription;
  ChatRoomCubit({required this.repository}) : super(ChatRoomState.initial());

  Future<void> enterRoomByMember({required UserModel me, required UserModel member}) async {
    emit(state.copyWith(
      status: ChatRoomStatus.loading,
    ));
    try{
      final chatroom = await repository.enterChatRoom(me: me, member: member);
      emit(state.copyWith(
        status: ChatRoomStatus.success,
        chatRoom: chatroom
      ));
    }on CustomError catch(e){
      emit(state.copyWith(
        status: ChatRoomStatus.error,
        error: e
      ));
    }
  }

  void listeningMessages(){
    if(messageStreamSubscription != null){
      messageStreamSubscription!.cancel();
    }
    messageStreamSubscription = repository.getMessages(chatRoomId: state.chatRoom.id).listen((querySnapshot) async {
      List<MessageModel> messages = [];
      emit(state.copyWith(
          status: ChatRoomStatus.loading
      ));
      for(final messageDoc in querySnapshot.docs){
        MessageModel message = MessageModel.fromDoc(messageDoc: messageDoc);

        messages.add(message);
      }
      emit(state.copyWith(
          status: ChatRoomStatus.success,
          messages: messages
      ));
    });
  }

  Future<void> sendMessage({required String chatRoomId, required UserModel user, required String content}) async {
    try{
      await repository.sendMesage(chatRoomId: chatRoomId, user: user, content: content);
    }on CustomError catch(e){
      emit(state.copyWith(
          status: ChatRoomStatus.error,
          error: e
      ));
    }
  }

  Future<void> uploadVideo({required String chatRoomId, required UserModel user, required File video}) async {
    try{
      Reference reference = repository.uploadVideo(chatRoomId: chatRoomId, user: user, video: video);
      UploadTask uploadTask = reference.putFile(video);
      uploadTask.snapshotEvents.listen((event) async {
        emit(state.copyWith(
          progress: (event.bytesTransferred.toDouble() / event.totalBytes.toDouble() * 100).roundToDouble()
        ));
        if(event.bytesTransferred == event.totalBytes){
          //업로드 완료
          repository.uploadVideoDetail(chatRoomId: chatRoomId, user: user, downloadUrl:  await reference.getDownloadURL());
        }
      });
    }on CustomError catch(e){
      emit(state.copyWith(
          status: ChatRoomStatus.error,
          error: e
      ));
    }
  }

  Future<void> sendImages({required String chatRoomId, required UserModel user, required List<File> images}) async {
    try{
      await repository.sendImages(chatRoomId: chatRoomId, user: user, images: images);
    }on CustomError catch(e){
      emit(state.copyWith(
          status: ChatRoomStatus.error,
          error: e
      ));
    }
  }

  Future<void> enterRoomByRoomId({required String chatRoomId}) async {
    emit(state.copyWith(
      status: ChatRoomStatus.loading,
    ));
    try{
      final chatroom = await repository.enterChatRoomByChatRoomId(chatRoomId: chatRoomId);
      emit(state.copyWith(
          status: ChatRoomStatus.success,
          chatRoom: chatroom
      ));
    }on CustomError catch(e){
      emit(state.copyWith(
          status: ChatRoomStatus.error,
          error: e
      ));
    }
  }

  @override
  Future<void> close() {
    // TODO: implement close
    messageStreamSubscription!.cancel();
    return super.close();
  }
}
