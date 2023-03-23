import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_community/blocs/chat/chat_cubit.dart';
import 'package:flutter_community/blocs/chatroom/chat_room_cubit.dart';
import 'package:flutter_community/consts/theme_const.dart';
import 'package:flutter_community/models/chat/chat_room_model.dart';
import 'package:flutter_community/pages/main_page.dart';
import 'package:flutter_community/utils/error_dialog.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../components/chat_room_card.dart';
import 'chat_page.dart';



class ChatRoomListPage extends StatefulWidget {
  const ChatRoomListPage({Key? key}) : super(key: key);

  @override
  State<ChatRoomListPage> createState() => _ChatRoomListPageState();
}

class _ChatRoomListPageState extends State<ChatRoomListPage> {

  bool showSpinner = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<ChatCubit>().setChatRooms();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(  
      inAsyncCall: showSpinner,
      child: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          // TODO: implement listener
        },
        builder: (context, state) {
          if (state.status == ChatStatus.loading) {
            return Center(
              child: CircularProgressIndicator(
                color: SECONDERY_COLOR,
              ),
            );
          }

          final chatRooms = state.chatRooms;

          if (chatRooms.length == 0) {
            return Center(
              child: Text("방이 없습니다."),
            );
          }

          return ListView.builder(
              itemBuilder: (context, index) {
                final chatRoom = chatRooms[index];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: InkWell(
                      onTap: () {
                        joinChatRoom(chatRoom: chatRoom);
                      },
                      child: ChatRoomCard.fromModel(chatroom: chatRoom)),
                );
              },
              itemCount: chatRooms.length);
        },
      ),
    );
  }

  Future<void> joinChatRoom({required ChatRoomModel chatRoom})  async {
    setState(() {
      showSpinner = true;
    });
    await context.read<ChatRoomCubit>().enterRoomByRoomId(chatRoomId: chatRoom.id);

    setState(() {
      showSpinner = false;
    });
    Navigator.of(context).pushNamedAndRemoveUntil(ChatPage
        .routeName,
            (route) {
          return route.settings.name ==
              MainPage.routeName;
        }, arguments: chatRoom);
  }
}
