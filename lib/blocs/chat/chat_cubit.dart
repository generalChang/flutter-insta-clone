import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_community/models/custom_error.dart';
import 'package:meta/meta.dart';

import '../../models/chat/chat_room_model.dart';
import '../../repositories/chat_repository.dart';
import '../../repositories/user_repository.dart';
import '../profile/profile_cubit.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  StreamSubscription? chatRoomStreamSubscription;
  StreamSubscription? profileStreamSubscription;
  final ChatRepository chatRepository;
  final ProfileCubit profileCubit;
  final UserRepository userRepository;
  ChatCubit({required this.chatRepository, required this.profileCubit, required this.userRepository}) : super(ChatState.initial());


  void setChatRooms(){
    if(chatRoomStreamSubscription != null){
      chatRoomStreamSubscription!.cancel();
    }
    emit(
      state.copyWith(
        status: ChatStatus.loading,
        chatRooms: []
      )
    );
    chatRoomStreamSubscription = chatRepository.getChatRooms(userId: profileCubit.state.user!.id).listen((querySnapshot) async {
      List<ChatRoomModel> chatRooms = [];
      emit(state.copyWith(
        status: ChatStatus.loading
      ));
      for(final chatRoomDoc in querySnapshot.docs){
        ChatRoomModel chatroom = ChatRoomModel.fromDoc(chatDoc: chatRoomDoc);

        final memberId = chatroom.members.where((member) => profileCubit.state.user!.id != member.id).last.id;

        final member = await userRepository.getProfile(uid: memberId);

        chatroom = chatroom.copyWith(
          members: [profileCubit.state.user!, member],
          roomName: "${member.name}님과의 대화"
        );

        chatRooms.add(chatroom);
      }
      emit(state.copyWith(
        status: ChatStatus.success,
        chatRooms: chatRooms
      ));
    });
  }


  @override
  Future<void> close() {
    chatRoomStreamSubscription!.cancel();
    profileStreamSubscription!.cancel();
    // TODO: implement close
    return super.close();
  }
}
