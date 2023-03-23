import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_community/blocs/pagination/pagination_cubit.dart';
import 'package:flutter_community/consts/theme_const.dart';
import 'package:flutter_community/models/comment/comment_model.dart';
import 'package:flutter_community/models/community/paragraph_model.dart';
import 'package:flutter_community/models/user/user_model.dart';
import 'package:flutter_community/pages/main_page.dart';
import 'package:flutter_community/pages/post/posting_page.dart';
import 'package:flutter_community/repositories/like_repository.dart';
import 'package:flutter_community/repositories/paragraph_of_user_repository.dart';
import 'package:flutter_community/repositories/paragraph_repository.dart';
import 'package:flutter_community/utils/data_utils.dart';

import '../blocs/profile/profile_cubit.dart';
import '../models/like_model.dart';
import '../pages/profile/profile_page.dart';

class ParagraphCard extends StatelessWidget {
  final UserModel user;
  final String id;
  final String content;
  final List<String> images;
  final Timestamp timestamp;
  final bool isDetail;
  final bool isParagraphOfUser;
  final List<LikeModel> likes;
  final List<CommentModel> comments;
  const ParagraphCard(
      {Key? key,
      this.isDetail = false,
        this.isParagraphOfUser = false,
      required this.user,
      required this.id,
      required this.timestamp,
      required this.content,
      required this.likes,
      required this.images,
      required this.comments})
      : super(key: key);

  factory ParagraphCard.fromModel(
      {required ParagraphModel paragraphModel,
      bool isDetail = false,
      bool isParagraphOfUser = false}) {
    return ParagraphCard(
        isDetail: isDetail,
        user: paragraphModel.user,
        id: paragraphModel.id,
        timestamp: paragraphModel.timestamp,
        content: paragraphModel.content,
        likes: paragraphModel.likes,
        images: paragraphModel.imagesUrl,
        comments: paragraphModel.comments,
        isParagraphOfUser:  isParagraphOfUser,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
        PaginationCubit<ParagraphModel, ParagraphRepository>,
        PaginationState<ParagraphModel>>(
      builder: (context, state) {
        return Card(
          shape: RoundedRectangleBorder(),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                _Header(user: user, timestamp: timestamp),
                SizedBox(
                  height: 16,
                ),
                _Body(
                  isParagraphOfUser: isParagraphOfUser,
                  id: id,
                  images: images,
                  likes: likes,
                  content: content,
                  isDetail: isDetail,
                  timestamp: timestamp,
                  user: user,
                  comments: comments,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final UserModel user;
  final Timestamp timestamp;
  const _Header({Key? key, required this.user, required this.timestamp})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: (){
            Navigator.of(context).pushNamedAndRemoveUntil(ProfilePage.routeName, arguments: user.id,
                    (route) {
                      return route.settings.name == MainPage.routeName;
                    });
          },
          child: CircleAvatar(
            backgroundImage: NetworkImage(user.photoUrl),
            radius: 25,
          ),
        ),
        SizedBox(
          width: 8,
        ),
        Expanded(
            child: Text(
          user.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        )),
        Text(DataUtils.formatTimestamp(timestamp: timestamp))
      ],
    );
  }
}

class _Body extends StatefulWidget {
  final String id;
  final String content;
  final List<String> images;
  final List<LikeModel> likes;
  final Timestamp timestamp;
  final UserModel user;
  final bool isDetail;
  final bool isParagraphOfUser;
  final List<CommentModel> comments;

  const _Body(
      {Key? key,
        required this.isParagraphOfUser,
      required this.isDetail,
      required this.timestamp,
      required this.user,
      required this.id,
      required this.images,
      required this.likes,
      required this.content,
      required this.comments})
      : super(key: key);

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = context.watch<ProfileCubit>().state;
    final paginationCubit = context.read<
        PaginationCubit<ParagraphModel, ParagraphRepository>>();
    final paragraphOfUserCubit = context.read<
        PaginationCubit<ParagraphModel, ParagraphOfUserRepository>>();
    final liked = widget.likes
        .where((like) => like.userId == profileState.user!.id)
        .isNotEmpty;
    final isMyParagraph = widget.user.id == profileState.user!.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.images.isNotEmpty && widget.images.length == 1 ||
            widget.isDetail)
          Container(
            height: widget.images.isNotEmpty ? 180 : 0,
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final image = Image.network(widget.images[index]);
                  return ClipRRect(
                      borderRadius: BorderRadius.circular(12), child: image);
                },
                separatorBuilder: (context, index) {
                  return SizedBox(
                    width: 8,
                  );
                },
                itemCount: widget.images.length),
          ),
        if (widget.images.isNotEmpty &&
            widget.images.length >= 2 &&
            !widget.isDetail)
          Container(
            height: 150,
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  if (index == 2) {
                    return Container(
                      width: 200,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          "더보기..",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    );
                  }
                  final image = Image.network(widget.images[index]);
                  return ClipRRect(
                      borderRadius: BorderRadius.circular(12), child: image);
                },
                separatorBuilder: (context, index) {
                  return SizedBox(
                    width: 8,
                  );
                },
                itemCount: 3),
          ),
        SizedBox(
          height: 8,
        ),
        Text(
          widget.isDetail
              ? widget.content
              : DataUtils.getSubString(str: widget.content),
          textAlign: TextAlign.start,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
                label: Text(
                  "${widget.likes.length}",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  if(widget.isParagraphOfUser){
                    paragraphOfUserCubit.updateLike(targetId: widget.id, userId: context.read<ProfileCubit>().state.user!.id,
                    likeRepository: context.read<LikeRepository>());
                  }else{
                    paginationCubit.updateLike(
                        targetId: widget.id,
                        userId: context.read<ProfileCubit>().state.user!.id,
                        likeRepository: context.read<LikeRepository>());
                  }
                },
                icon: Icon(
                  liked ? Icons.recommend : Icons.recommend_outlined,
                  color: liked ? SECONDERY_COLOR : Colors.grey,
                )),
            Row(
              children: [
                SizedBox(
                  width: 8,
                ),
                TextButton.icon(
                    onPressed: () {},
                    icon: Icon(
                      Icons.comment,
                      color: SECONDERY_COLOR,
                    ),
                    label: Text(
                      "${widget.comments.length}",
                      style: TextStyle(color: Colors.black),
                    )),
              ],
            ),
            if (isMyParagraph)
              Row(
                children: [
                  SizedBox(
                    width: 8,
                  ),
                  IconButton(
                    color: SECONDERY_COLOR,
                    onPressed: () async {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => PostingPage(
                                paragraph: ParagraphModel(
                                  id: widget.id,
                                  content: widget.content,
                                  timestamp: widget.timestamp,
                                  imagesUrl: widget.images,
                                  user: widget.user,
                                  likes: widget.likes,
                                  comments: widget.comments
                                ),
                                isEdit: true,
                              )));
                    },
                    icon: Icon(Icons.edit),
                  ),
                ],
              )
          ],
        )
      ],
    );
  }
}
