import "package:flutter/material.dart";


import 'package:flutter_community/blocs/pagination/pagination_cubit.dart';
import 'package:flutter_community/models/pagination/model_with_id.dart';
import 'package:flutter_community/repositories/base_like_repository.dart';
import 'package:flutter_community/repositories/base_pagination_repository.dart';
import 'package:skeletons/skeletons.dart';

import '../components/comment_card.dart';
import '../consts/theme_const.dart';
import '../models/comment/comment_model.dart';
class PaginationDataUtils{


  static SliverList renderLoading() {
    return SliverList(
      delegate: SliverChildListDelegate(List.generate(
          3,
              (index) => Padding(
            padding: const EdgeInsets.only(top: 32),
            child: SkeletonListTile(
              leadingStyle: SkeletonAvatarStyle(
                  width: 45, height: 45, shape: BoxShape.circle),
              titleStyle: SkeletonLineStyle(
                  height: 16,
                  minLength: 200,
                  randomLength: true,
                  borderRadius: BorderRadius.circular(12)),
              subtitleStyle: SkeletonLineStyle(
                  height: 12,
                  maxLength: 200,
                  randomLength: true,
                  borderRadius: BorderRadius.circular(12)),
            ),
          ))),
    );
  }

  static SliverToBoxAdapter renderCommentHeader() {
    return SliverToBoxAdapter(
      child: Row(
        children: [
          Icon(
            Icons.comment,
            size: 30,
            color: SECONDERY_COLOR,
          ),
          SizedBox(
            width: 4,
          ),
          Text(
            "댓글",
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  static SliverList renderComments({required List<CommentModel> comments}) {
    return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: CommentCard.fromModel(commentModel: comments[index]),
          );
        }, childCount: comments.length));
  }
}