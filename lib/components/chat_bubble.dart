import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_community/blocs/profile/profile_cubit.dart';
import 'package:flutter_community/components/video_player_view.dart';
import 'package:flutter_community/consts/theme_const.dart';
import 'package:flutter_community/models/chat/message_model.dart';

import '../models/user/user_model.dart';

class ChatBubbles extends StatelessWidget {

  final String message;
  final List<String> imageUrl;
  final UserModel user;
  final Timestamp timestamp;
  final String videoUrl;

  const ChatBubbles({Key? key, required this.timestamp,
  required this.message, required this.user, this.imageUrl = const [],
  this.videoUrl = ""}) : super(key: key);

  factory ChatBubbles.fromModel({required MessageModel messageModel}){
    return ChatBubbles(
        timestamp: messageModel.timestamp,
        message: messageModel.content,
        user: messageModel.user,
        imageUrl: messageModel.imagesUrl,
        videoUrl: messageModel.videoUrl,);
  }

  @override
  Widget build(BuildContext context) {
    final isMe = user.id == context.read<ProfileCubit>().state.user!.id;

    return Stack(
      children: [
        Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if(isMe)
              Padding(
                padding: const EdgeInsets.only(right: 35, top: 10),
                child: ChatBubble(
                  clipper: ChatBubbleClipper8(type: BubbleType.sendBubble),
                  alignment: Alignment.topRight,
                  margin: EdgeInsets.only(top: 20),
                  backGroundColor: SECONDERY_COLOR,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                        ),),
                        if(imageUrl.isNotEmpty)
                          renderImages(),
                        if(videoUrl != "")
                          VideoPlayerView(url: videoUrl,),
                        Text(
                          message,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if(!isMe)
              Padding(
                padding: const EdgeInsets.only(left: 35, top: 10),
                child: ChatBubble(
                  clipper: ChatBubbleClipper8(type: BubbleType.receiverBubble),
                  backGroundColor: Color(0xffE7E7ED),
                  margin: EdgeInsets.only(top: 20),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black
                        ),),
                        if(imageUrl.isNotEmpty)
                          renderImages(),
                        if(videoUrl != "")
                          VideoPlayerView(url: videoUrl,),
                        Text(
                          message,
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              )
          ],
        ),
        Positioned(
          top: 0,
          right: isMe ? 5 : null,
          left : isMe ? null : 5,
          child: CircleAvatar(
            backgroundImage: NetworkImage(
              user.photoUrl
            ),
          ),
        )
      ],

    );
  }

  Widget renderImages(){
    return SizedBox(
      height: 200,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index){
            return Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 12, left: 12,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(imageUrl[index], fit: BoxFit.cover,),
              ),
            );
          },
          itemCount: imageUrl.length),
    );
  }
}
