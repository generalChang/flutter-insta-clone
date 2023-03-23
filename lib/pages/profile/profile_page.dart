import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_community/blocs/chat/chat_cubit.dart';
import 'package:flutter_community/blocs/chatroom/chat_room_cubit.dart';
import 'package:flutter_community/blocs/follow/follow_cubit.dart';
import 'package:flutter_community/blocs/pagination/pagination_cubit.dart';
import 'package:flutter_community/blocs/profile/profile_cubit.dart';
import 'package:flutter_community/blocs/user/user_cubit.dart';
import 'package:flutter_community/components/default_layout.dart';
import 'package:flutter_community/models/community/paragraph_model.dart';
import 'package:flutter_community/models/user/user_model.dart';
import 'package:flutter_community/pages/post/paragraph_detail_page.dart';
import 'package:flutter_community/repositories/follow_repository.dart';
import 'package:flutter_community/repositories/like_repository.dart';
import 'package:flutter_community/repositories/paragraph_of_user_repository.dart';
import 'package:flutter_community/utils/error_dialog.dart';
import 'package:flutter_community/utils/follow_dialog.dart';
import 'package:flutter_community/utils/pagination_data_utils.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:skeletons/skeletons.dart';

import '../../components/paragraph_card.dart';
import '../../consts/theme_const.dart';
import '../chat/chat_page.dart';
import '../main_page.dart';



class ProfilePage extends StatefulWidget {
  final String uid;
  static String get routeName => "/profile/detail";
  ProfilePage({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ScrollController _scrollController = ScrollController();

  bool showSpinner = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(listener);
    context.read<UserCubit>().getUser(userId: widget.uid);
    context
        .read<
            PaginationCubit<ParagraphModel, ParagraphOfUserRepository>>()
        .pagination(userId: widget.uid, forceRefetch: true);
  }

  void listener() {
    if (_scrollController.offset >
        _scrollController.position.maxScrollExtent - 200) {
      context
          .read<
              PaginationCubit<ParagraphModel, ParagraphOfUserRepository>>()
          .pagination(userId: widget.uid, fetchMore: true);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: DefaultLayout(
          onWillPop: () async => true,
          title: "프로필",
          automaticallyImplyLeading: false,
          body: RefreshIndicator(
            onRefresh: () async {
              context
                  .read<
                  PaginationCubit<ParagraphModel, ParagraphOfUserRepository>>()
                  .pagination(userId: widget.uid, forceRefetch: true);
            },
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                renderHeader(),
                renderLabel(),
                BlocConsumer<
                    PaginationCubit<ParagraphModel, ParagraphOfUserRepository>,
                    PaginationState<ParagraphModel>>(
                  listener: (context, state) {
                    // TODO: implement listener
                    if (state.status == PaginationStatus.error) {
                      errorDialog(context: context, error: state.error);
                    }
                  },
                  builder: (context, state) {
                    if (state.status == PaginationStatus.initial) {
                      return SliverToBoxAdapter(child: Container());
                    }
                    if (state.status == PaginationStatus.loading) {
                      return PaginationDataUtils.renderLoading();
                    }

                    if (state.status == PaginationStatus.error) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("정보를 불러오지 못했습니다."),
                              ElevatedButton(
                                onPressed: () {},
                                child: Text("다시시도"),
                                style: ElevatedButton.styleFrom(
                                    primary: SECONDERY_COLOR),
                              )
                            ],
                          ),
                        ),
                      );
                    }

                    return renderParagraphOfUser(
                        paragraphs: state.cursorPagination.data);
                  },
                )
              ],
            ),
          )),
    );
  }

  SliverToBoxAdapter renderLabel() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          "글 목록",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  SliverList renderParagraphOfUser({required List<ParagraphModel> paragraphs}) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    ParagraphDetailPage.routeName, (route) {
                  return route.settings.name == MainPage.routeName;
                }, arguments: paragraphs[index]);
              },
              child: ParagraphCard.fromModel(
                paragraphModel: paragraphs[index],
                isParagraphOfUser: true,
              ));
        },
        childCount: paragraphs.length,
      ),
    );
  }

  SliverToBoxAdapter renderHeader() {
    final profileState = context.watch<ProfileCubit>().state;
    final allFollowerState = context.watch<FollowCubit>().state;

    //팔로잉이 되어있는지 안되어있는지 확인.
    final followed = allFollowerState.followers.where((user) {
      return user.id == widget.uid;
    }).isNotEmpty;
    return SliverToBoxAdapter(
        child: BlocConsumer<UserCubit, UserState>(
      listener: (context, userState) {
        // TODO: implement listener
        if (userState.status == UserStatus.error) {
          errorDialog(context: context, error: userState.error);
        }
      },
      builder: (context, userState) {
        if (userState.status == UserStatus.loading) {
          return Center(
            child: Text("정보를 불러오는 중입니다.."),
          );
        }

        if (userState.status == UserStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("에러가 발생했습니다."),
                ElevatedButton(
                  onPressed: () {
                    context.read<UserCubit>().getUser(userId: widget.uid);
                  },
                  child: Text("다시시도"),
                  style: ElevatedButton.styleFrom(primary: SECONDERY_COLOR),
                )
              ],
            ),
          );
        }
        return Column(
          children: [
            Row(),
            SizedBox(
              height: 16,
            ),
            ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                child: Image.network(
                  userState.user!.photoUrl,
                  width: MediaQuery.of(context).size.width * 2 / 3,
                  fit: BoxFit.cover,
                )),
            SizedBox(
              height: 16,
            ),
            Text(
              "${userState.user!.name}",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              "${userState.user!.email}",
              style: TextStyle(fontSize: 19),
            ),
            SizedBox(
              height: 16,
            ),
            if (profileState.user!.id != widget.uid)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      followDialog(
                          context: context,
                          followed: followed,
                          userId: context.read<ProfileCubit>().state.user!.id,
                          targetUser: userState.user);
                    },
                    child: Text(followed ? "언팔로우하기" : "팔로우하기"),
                    style: followed
                        ? ElevatedButton.styleFrom(primary: SECONDERY_COLOR)
                        : ElevatedButton.styleFrom(
                            primary: Colors.white,
                            foregroundColor: SECONDERY_COLOR),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  ElevatedButton(
                      onPressed: joinChatRoom,
                      child: Text("채팅하기"),
                      style: ElevatedButton.styleFrom(primary: THIRD_COLOR)),
                ],
              )
          ],
        );
      },
    ));
  }

  Future<void> joinChatRoom() async {
    setState(() {
      showSpinner = true;
    });
    if (context.read<UserCubit>().state.status == UserStatus.success) {
      await context.read<ChatRoomCubit>().enterRoomByMember(
          me: context.read<ProfileCubit>().state.user!,
          member: context.read<UserCubit>().state.user);

      setState(() {
        showSpinner = false;
      });
      Navigator.of(context).pushNamedAndRemoveUntil(ChatPage.routeName,
          (route) {
        return route.settings.name == MainPage.routeName;
      }, arguments: context.read<ChatRoomCubit>().state.chatRoom);


    }
  }
}
