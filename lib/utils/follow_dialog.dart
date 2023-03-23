import 'dart:io';

import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_community/blocs/pagination/pagination_cubit.dart';
import 'package:flutter_community/models/user/user_model.dart';
import 'package:flutter_community/repositories/follow_repository.dart';
import 'package:flutter_community/repositories/like_repository.dart';

import '../blocs/profile/profile_cubit.dart';

void followDialog(
    {required BuildContext context,
    required bool followed,
    required String userId,
    required UserModel targetUser}) {
  if (Platform.isAndroid) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("확인메세지"),
            content: Text(followed ? "언팔로우 하시겠습니까?" : "팔로우 하시겠습니까?"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("취소")),
              TextButton(
                  onPressed: () {
                    if (followed) {
                      context
                          .read<
                              PaginationCubit<UserModel, FollowRepository>>()
                          .deleteFollow(
                              userId: userId, targetUserId: targetUser.id);
                    } else {
                      context
                          .read<
                              PaginationCubit<UserModel, FollowRepository>>()
                          .addFollow(userId: userId, targetUser: targetUser);
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text("확인")),
            ],
          );
        });
  } else {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text("확인메세지"),
            content: Text(followed ? "언팔로우 하시겠습니까?" : "팔로우 하시겠습니까?"),
            actions: [
              CupertinoDialogAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("취소")),
              CupertinoDialogAction(
                  onPressed: () {
                    if (followed) {
                      context
                          .read<
                          PaginationCubit<UserModel, FollowRepository>>()
                          .deleteFollow(
                          userId: userId, targetUserId: targetUser.id);
                    } else {
                      context
                          .read<
                          PaginationCubit<UserModel, FollowRepository>>()
                          .addFollow(userId: userId, targetUser: targetUser);
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text("확인")),
            ],
          );
        });
  }
}
