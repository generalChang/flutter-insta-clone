import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_community/components/video_player_view.dart';
import 'package:flutter_community/repositories/short_video_repository.dart';

import '../blocs/pagination/pagination_cubit.dart';
import '../blocs/profile/profile_cubit.dart';
import '../consts/theme_const.dart';
import '../models/comment/comment_model.dart';
import '../models/like_model.dart';
import '../models/short_video/short_video_model.dart';
import '../models/user/user_model.dart';
import '../pages/main_page.dart';
import '../pages/profile/profile_page.dart';
import '../repositories/like_repository.dart';
import '../utils/data_utils.dart';

class ShortVideoCard extends StatelessWidget {
  final UserModel user;
  final String id;
  final String content;
  final String videoUrl;
  final Timestamp timestamp;
  final List<LikeModel> likes;
  final List<CommentModel> comments;
  const ShortVideoCard(
      {Key? key,
      required this.id,
      required this.videoUrl,
      required this.content,
      required this.comments,
      required this.likes,
      required this.user,
      required this.timestamp})
      : super(key: key);

  factory ShortVideoCard.fromModel({
    required ShortVideoModel shortVideo,
  }) {
    return ShortVideoCard(
      user: shortVideo.user,
      id: shortVideo.id,
      timestamp: shortVideo.timestamp,
      content: shortVideo.content,
      likes: shortVideo.likes,
      videoUrl: shortVideo.videoUrl,
      comments: shortVideo.comments,
    );
  }

  @override
  Widget build(BuildContext context) {
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
              videoUrl: videoUrl,
              id: id,
              likes: likes,
              content: content,
              timestamp: timestamp,
              user: user,
              comments: comments,
            ),
          ],
        ),
      ),
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
          onTap: () {
            Navigator.of(context).pushNamedAndRemoveUntil(ProfilePage.routeName,
                arguments: user.id, (route) {
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
  final String videoUrl;
  final List<LikeModel> likes;
  final Timestamp timestamp;
  final UserModel user;
  final List<CommentModel> comments;

  const _Body(
      {Key? key,
      required this.timestamp,
      required this.user,
      required this.id,
      required this.videoUrl,
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
    final paginationCubit =
        context.read<PaginationCubit<ShortVideoModel, ShortVideoRepository>>();
    final liked = widget.likes
        .where((like) => like.userId == profileState.user!.id)
        .isNotEmpty;
    final isMyVideo = widget.user.id == profileState.user!.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VideoPlayerView(
          url: widget.videoUrl,
        ),
        SizedBox(
          height: 8,
        ),
        Text(
          widget.content,
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

                    paginationCubit.updateLike(
                        targetId: widget.id,
                        userId: context.read<ProfileCubit>().state.user!.id,
                        likeRepository: context.read<LikeRepository>());
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
          ],
        )
      ],
    );
  }
}
