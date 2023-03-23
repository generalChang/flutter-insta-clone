import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_community/blocs/pagination/pagination_cubit.dart';
import 'package:flutter_community/blocs/profile/profile_cubit.dart';
import 'package:flutter_community/components/custom_bottom_sheet.dart';
import 'package:flutter_community/models/comment/comment_model.dart';
import 'package:flutter_community/repositories/like_repository.dart';
import 'package:flutter_community/repositories/comment_repository.dart';

import '../consts/theme_const.dart';
import '../models/like_model.dart';
import '../models/user/user_model.dart';
import '../pages/main_page.dart';
import '../pages/profile/profile_page.dart';
import '../utils/data_utils.dart';

class CommentCard extends StatefulWidget {
  final String id;
  final UserModel user;
  final String paragraphId;
  final String message;
  final Timestamp timestamp;
  final List<LikeModel> likes;

  CommentCard(
      {Key? key,
      required this.id,
      required this.user,
      required this.paragraphId,
      required this.message,
      required this.timestamp,
      required this.likes})
      : super(key: key);

  factory CommentCard.fromModel(
      {required CommentModel commentModel}) {
    return CommentCard(
        id: commentModel.id,
        user: commentModel.user,
        paragraphId: commentModel.paragraphId,
        message: commentModel.message,
        timestamp: commentModel.timestamp,
        likes: commentModel.likes);
  }

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
        PaginationCubit<CommentModel, CommentRepository>,
        PaginationState<CommentModel>>(
      builder: (context, state) {
        return Card(
          shape: RoundedRectangleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                _Header(user: widget.user, timestamp: widget.timestamp),
                _Body(
                  id: widget.id,
                  likes: widget.likes,
                  message: widget.message,
                  timestamp: widget.timestamp,
                  user: widget.user,
                  paragraphId: widget.paragraphId
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
            // Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfilePage(uid: user.id)));
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

class _Body extends StatelessWidget {
  final String id;
  final String message;
  final List<LikeModel> likes;
  final String paragraphId;
  final UserModel user;
  final Timestamp timestamp;

  const _Body(
      {Key? key, required this.id, required this.likes, required this.user, required this.paragraphId, required this.message
      ,required this.timestamp})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final paginationCubit = context.read<
        PaginationCubit<CommentModel, CommentRepository>>();
    final paginationState = context
        .watch<
            PaginationCubit<CommentModel, CommentRepository>>()
        .state;

    final profileState = context.watch<ProfileCubit>().state;

    final liked = paginationState.cursorPagination.data
        .where((comment) => comment.id == id)
        .first
        .likes
        .where((like) => like.userId == profileState.user!.id)
        .isNotEmpty;

    final isMyComment = paginationState.cursorPagination.data
        .where((comment) => comment.id == id)
        .first
        .user.id == profileState.user!.id;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              textAlign: TextAlign.start,
            ),
          ),
          TextButton.icon(
              label: Text(
                "${likes.length}",
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                paginationCubit.updateLike(
                    targetId: id,
                    userId: context.read<ProfileCubit>().state.user!.id,
                   likeRepository: context.read<LikeRepository>());
              },
              icon: Icon(
                liked ? Icons.recommend : Icons.recommend_outlined,
                color: liked ? SECONDERY_COLOR : Colors.grey,
              )),
          if(isMyComment)
          Row(
            children: [
              SizedBox(
                width: 8,
              ),
              IconButton(
                color: SECONDERY_COLOR,
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (context){
                        return CustomBottomSheet(
                            paragraphId: paragraphId,
                          isEdit: true,
                          prevComment: CommentModel(
                            id: id,
                            message: message,
                            paragraphId: paragraphId,
                            user: user,
                            timestamp: timestamp,
                            likes: likes
                          ),
                        );
                      },
                  isScrollControlled: true);
                },
                icon: Icon(Icons.edit),
              ),
            ],
          )
        ],
      ),
    );
  }
}
