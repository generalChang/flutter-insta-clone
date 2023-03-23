
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_community/blocs/auth/auth_bloc.dart';
import 'package:flutter_community/components/default_layout.dart';
import 'package:flutter_community/consts/theme_const.dart';
import 'package:flutter_community/pages/post/paragraph_page.dart';
import 'package:flutter_community/pages/post/posting_page.dart';
import 'package:flutter_community/pages/profile/my_page.dart';
import 'package:flutter_community/pages/short/short_video_page.dart';

import 'chat/chat_room_list_page.dart';

class MainPage extends StatefulWidget {
  static String get routeName => "/main";
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin{

  int _index = 0;
  late final TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(tabListener);
  }

  void tabListener(){
    setState(() {
      _index = _tabController.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        selectedItemColor: SECONDERY_COLOR,
        selectedIconTheme: IconThemeData(color: SECONDERY_COLOR),
        unselectedIconTheme: IconThemeData(color: Colors.grey),
        unselectedItemColor: Colors.grey,
        onTap: (int index){
          _tabController.animateTo(index);
        },
        currentIndex: _index,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.account_circle, ), label: "프로필"),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_customize, ), label: "게시글"),
          BottomNavigationBarItem(icon: Icon(Icons.chat, ), label: "채팅"),
          BottomNavigationBarItem(icon: Icon(Icons.video_library), label: "영상"),
        ],
      ),
      automaticallyImplyLeading: false,
      actions: [
        IconButton(onPressed: (){
          Navigator.of(context).pushNamed(PostingPage.routeName);
        }, icon: Icon(Icons.add_box)),
        IconButton(onPressed: (){
          context.read<AuthBloc>().add(SignoutEvent());
        }, icon: Icon(Icons.exit_to_app)),
      ],
      title: "메인",
        body: TabBarView(
          controller: _tabController,
          children: [
            MyPage(),
            ParagraphPage(),
            ChatRoomListPage(),
            VideoPage(),
          ],
        ));
  }
}
