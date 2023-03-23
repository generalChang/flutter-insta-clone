import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_community/models/pagination/cursor_pagination.dart';
import 'package:flutter_community/models/pagination/model_with_id.dart';
import 'package:flutter_community/models/pagination/pagination_params.dart';
import 'package:flutter_community/repositories/base_pagination_repository.dart';
import 'package:flutter_community/services/short_video_api_serivces.dart';

import '../models/custom_error.dart';
import '../models/short_video/short_video_model.dart';
import '../models/user/user_model.dart';
import '../services/pagination_api_services.dart';

class ShortVideoRepository implements BasePaginationRepository<ShortVideoModel>{
  final ShortVideoApiServices shortVideoApiServices;
  final PaginationApiServices<ShortVideoModel,
      CollectionReference<Map<String, dynamic>>> paginationApiServices;

  const ShortVideoRepository({
    required this.shortVideoApiServices,
    required this.paginationApiServices,
  });

  @override
  Future<ShortVideoModel> getById({required String id}) {
    try {
      return shortVideoApiServices.getShortVideoById(id: id);
    } on FirebaseAuthException catch (e) {
      throw CustomError(code: e.code, message: e.message!, plugin: e.plugin);
    } catch (e) {
      throw CustomError(
          code: "Error!",
          message: e.toString(),
          plugin: "flutter_error/server_error");
    }
  }

  @override
  Future<CursorPagination<ShortVideoModel>> pagination({PaginationParams paginationParams = const PaginationParams(), String? paragraphId, String? userId}) async {
    try {
      // last 다음데이터부터 상위 count만큼의 데이터를 get한다. api호출이다.
      // 가져온 데이터의 마지막 데이터의 id값을 알아낸다.
      // 그 id값의 다음 데이터가 존재하는지 파악한다.(hasNext값 알아내기) api 호출이다.
      CursorPagination<ShortVideoModel> cursorPagination =
      CursorPagination<ShortVideoModel>.initial();
      Meta meta = Meta(count: paginationParams.count);

      final shorts = await paginationApiServices.getShortVideos(
          paginationParams: paginationParams);
      final hasNext = shorts.isNotEmpty &&
          await paginationApiServices.hasNextShortVideo(
          last: shorts.last.id);

      meta = meta.copyWith(hasNext: hasNext);
      cursorPagination = cursorPagination.copyWith(
          meta: meta,
          data: shorts
              .map((short) => short as ShortVideoModel)
              .toList());

      return cursorPagination;
    } on FirebaseException catch (e, stack) {
      throw CustomError(code: e.code, message: e.message!, plugin: e.plugin);
    } catch (e, stack) {
      throw CustomError(
          code: "Error!",
          message: e.toString(),
          plugin: "flutter_error/server_error");
    }
  }

  Future<ShortVideoModel> addShortVideo({
    required UserModel user,
    required String content,
    required File video,
  }) async {
    try {
      final short = await shortVideoApiServices.writeShortVideoContent(
          user: user, content: content);
      ShortVideoModel addshortVideo;
      addshortVideo = await shortVideoApiServices.writeShortVideo(
          shortVideo: short, video: video);

      return addshortVideo;
    } on FirebaseException catch (e) {
      throw CustomError(code: e.code, message: e.message!, plugin: e.plugin);
    } catch (e) {
      throw CustomError(
          code: "Error!",
          message: e.toString(),
          plugin: "flutter_error/server_error");
    }
  }
  
 

}