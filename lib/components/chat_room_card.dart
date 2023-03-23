import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_community/blocs/profile/profile_cubit.dart';
import 'package:flutter_community/consts/theme_const.dart';
import 'package:flutter_community/models/chat/chat_room_model.dart';
import 'package:flutter_community/pages/main_page.dart';
import 'package:flutter_community/utils/data_utils.dart';

import '../models/user/user_model.dart';
import '../pages/profile/profile_page.dart';


class ChatRoomCard extends StatelessWidget {
  final String id; //방 id
  final String roomName; //방이름
  final String recentMessage; //방의 최근 메세지
  final List<UserModel> members; //방에 있는 사람들

  final Timestamp timestamp;

  const ChatRoomCard({Key? key, required this.id,
    required this.members, required this.recentMessage, required this.timestamp,
    required this.roomName}) : super(key: key);


  factory ChatRoomCard.fromModel({required ChatRoomModel chatroom}){
    return ChatRoomCard(
        id: chatroom.id,
        members: chatroom.members,
        recentMessage: chatroom.recentMessage,
        timestamp: chatroom.timestamp,
        roomName: chatroom.roomName);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if(state.status == ProfileStatus.loading){
          return Center(
            child: CircularProgressIndicator(color: SECONDERY_COLOR,),
          );
        }
        
        final imageUrl = members.where((member) => member.id != state.user!.id).last.photoUrl;
        final opponent = members.where((member) => member.id != state.user!.id).last.id;
        return Card(
          shape: RoundedRectangleBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: (){
                    Navigator.of(context).pushNamedAndRemoveUntil(ProfilePage.routeName,
                            (route){
                              return route.settings.name == MainPage.routeName;
                            }, arguments: opponent);
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(imageUrl),
                    radius: 25,
                  ),
                ),
                SizedBox(width: 16,),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(roomName, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),),
                    SizedBox(height: 8,),
                    Text(DataUtils.getSubString(str: recentMessage), style: TextStyle(fontSize: 14),),
                  ],
                )),
                SizedBox(width: 8,),
                Text(DataUtils.formatTimestamp(timestamp: timestamp))
              ],
            ),
          ),
        );
      },
    );
  }
}
