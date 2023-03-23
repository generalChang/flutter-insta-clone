import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_community/blocs/follow/follow_cubit.dart';
import 'package:flutter_community/blocs/pagination/pagination_cubit.dart';
import 'package:flutter_community/blocs/profile/profile_cubit.dart';
import 'package:flutter_community/consts/theme_const.dart';
import 'package:flutter_community/pages/follow/follow_page.dart';
import 'package:flutter_community/pages/main_page.dart';
import 'package:flutter_community/pages/profile/profile_page.dart';
import 'package:flutter_community/pages/profile/profile_update_page.dart';


import 'package:flutter_community/repositories/follow_repository.dart';
import 'package:flutter_community/repositories/like_repository.dart';
import 'package:flutter_community/utils/error_dialog.dart';

import '../../components/user_card.dart';
import '../../models/user/user_model.dart';




class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(listener);
  }

  void listener() {
    if (_scrollController.offset >
        _scrollController.position.maxScrollExtent - 200) {
      context
          .read<PaginationCubit<UserModel, FollowRepository>>()
          .pagination(
              userId: context.read<ProfileCubit>().state.user!.id,
              fetchMore: true);
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
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        // TODO: implement listener
        if (state.status == ProfileStatus.error) {
          errorDialog(context: context, error: state.error);
        }

        if (state.status == ProfileStatus.success) {
          context
              .read<
                  PaginationCubit<UserModel, FollowRepository>>()
              .pagination(userId: state.user!.id, forceRefetch: true);
        }
      },
      builder: (context, state) {
        if (state.status == ProfileStatus.initial) {
          return Container();
        }

        if (state.status == ProfileStatus.loading) {
          return Center(
            child: CircularProgressIndicator(
              color: PRIMARY_COLOR,
            ),
          );
        }

        if (state.status == ProfileStatus.error) {
          return Center(
            child: Text("Ooops.. error.."),
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            context
                .read<
                    PaginationCubit<UserModel, FollowRepository>>()
                .pagination(userId: state.user!.id, forceRefetch: true);
          },
          child: CustomScrollView(
            slivers: [
              renderHeader(state: state),
              renderRow(uid: state.user!.id)

              // renderLabel(),
              // BlocBuilder<
              //     PaginationCubit<UserModel, FollowRepository, LikeRepository>,
              //     PaginationState<UserModel>>(builder: (context, state) {
              //       print(state.status);
              //   if (state.status == PaginationStatus.loading) {
              //     return PaginationDataUtils.renderLoading();
              //   }
              //
              //   if (state.status == PaginationStatus.error) {
              //     return SliverToBoxAdapter(
              //       child: Center(
              //         child: Column(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: [
              //             Text("정보를 불러오지 못했습니다."),
              //             ElevatedButton(
              //               onPressed: () {},
              //               child: Text("다시시도"),
              //               style: ElevatedButton.styleFrom(
              //                   primary: SECONDERY_COLOR),
              //             )
              //           ],
              //         ),
              //       ),
              //     );
              //   }
              //
              //   return renderFollowers(followers: state.cursorPagination.data);
              // })
            ],
          ),
        );
      },
    );
  }

  SliverToBoxAdapter renderLabel() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          "팔로잉",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  SliverToBoxAdapter renderRow({required String uid}) {
    final ts = TextStyle(fontSize: 18, fontWeight: FontWeight.w700);
    final allFolloweeState = context.watch<FollowCubit>().state;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
                onTap: () {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(ProfilePage.routeName, (route) {
                    return route.settings.name == MainPage.routeName;
                  }, arguments: uid);
                },
                child: Text(
                  "게시글",
                  style: ts,
                )),
            if(allFolloweeState.status == FollowStatus.success)
            InkWell(
              onTap: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(FollowPage.routeName, (route) {
                  return route.settings.name == MainPage.routeName;
                });
              },
              child: Text(
                "팔로잉 ${allFolloweeState.followers.length}",
                style: ts,
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter renderHeader({required ProfileState state}) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          SizedBox(
            height: 16,
          ),
          ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              child: Image.network(
                state.user!.photoUrl,
                width: MediaQuery.of(context).size.width * 2 / 3,
                fit: BoxFit.cover,
              )),
          SizedBox(
            height: 16,
          ),
          Text(
            "${state.user!.name}",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            "${state.user!.email}",
            style: TextStyle(fontSize: 19),
          ),
          SizedBox(
            height: 16,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed(ProfileUpdatePage.routeName);
            },
            child: Text("프로필 업데이트"),
            style: ElevatedButton.styleFrom(primary: SECONDERY_COLOR),
          ),
          Divider(),
        ],
      ),
    );
  }

  SliverList renderFollowers({required List<UserModel> followers}) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
      (context, index) {
        final follower = followers[index];
        return UserCard.fromModel(userModel: follower);
      },
      childCount: followers.length,
    ));
  }
}
