import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_community/components/default_layout.dart';
import 'package:flutter_community/components/user_card.dart';
import 'package:flutter_community/consts/theme_const.dart';

import '../../blocs/pagination/pagination_cubit.dart';
import '../../blocs/profile/profile_cubit.dart';
import '../../models/user/user_model.dart';
import '../../repositories/follow_repository.dart';
import '../../repositories/like_repository.dart';

class FollowPage extends StatefulWidget {

  static String get routeName => "/follow_page";

  const FollowPage({Key? key}) : super(key: key);

  @override
  State<FollowPage> createState() => _FollowPageState();
}

class _FollowPageState extends State<FollowPage> {
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context
        .read<PaginationCubit<UserModel, FollowRepository>>()
        .pagination(
            count: 30,
            forceRefetch: true,
            userId: context.read<ProfileCubit>().state.user!.id);
    _scrollController.addListener(listener);
  }

  void listener() {
    if (_scrollController.offset >
        _scrollController.position.maxScrollExtent - 200) {
      context
          .read<PaginationCubit<UserModel, FollowRepository>>()
          .pagination(
          count: 30,
              userId: context.read<ProfileCubit>().state.user!.id,
              fetchMore: true);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
        title: "팔로잉",
        onWillPop: () async => true,
        automaticallyImplyLeading: false,
        body: BlocBuilder<
            PaginationCubit<UserModel, FollowRepository>,
            PaginationState<UserModel>>(
          builder: (context, state) {
            if(state.status == PaginationStatus.loading){
              return Center(
                child: CircularProgressIndicator(color: SECONDERY_COLOR,),
              );
            }

            if(state.status == PaginationStatus.error){
              return Center(
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
              );
            }

            return renderFollowees(followees: state.cursorPagination.data);
          },
        ));
  }

  Widget renderFollowees({required List<UserModel> followees}) {
    return RefreshIndicator(
      onRefresh: () async{
        context
            .read<PaginationCubit<UserModel, FollowRepository>>()
            .pagination(
            count: 30,
            userId: context.read<ProfileCubit>().state.user!.id,
            fetchMore: true);
      },
      child: ListView.builder(
          physics: AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          itemBuilder: (context, index) {
            final followee = followees[index];
            return UserCard.fromModel(userModel: followee);
          },
          itemCount: followees.length),
    );
  }
}
