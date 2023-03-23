import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_community/models/community/paragraph_model.dart';
import 'package:flutter_community/models/custom_error.dart';
import 'package:flutter_community/models/pagination/cursor_pagination.dart';
import 'package:flutter_community/models/pagination/pagination_params.dart';
import 'package:flutter_community/models/user/user_model.dart';
import 'package:flutter_community/repositories/base_pagination_repository.dart';
import 'package:flutter_community/services/pagination_api_services.dart';
import 'package:flutter_community/services/paragraph_api_services.dart';
import 'package:http/http.dart';

class ParagraphRepository implements BasePaginationRepository<ParagraphModel> {
  final ParagraphApiServices paragraphApiServices;
  final PaginationApiServices<ParagraphModel,
      CollectionReference<Map<String, dynamic>>> paginationApiServices;

  const ParagraphRepository(
      {required this.paragraphApiServices,
      required this.paginationApiServices});

  Future<CursorPagination<ParagraphModel>> pagination(
      {PaginationParams paginationParams = const PaginationParams(),
      String? paragraphId,
      String? userId,
      }) async {
    try {
      // last 다음데이터부터 상위 count만큼의 데이터를 get한다. api호출이다.
      // 가져온 데이터의 마지막 데이터의 id값을 알아낸다.
      // 그 id값의 다음 데이터가 존재하는지 파악한다.(hasNext값 알아내기) api 호출이다.
      CursorPagination<ParagraphModel> cursorPagination =
          CursorPagination<ParagraphModel>.initial();
      Meta meta = Meta(count: paginationParams.count);

      final paragraphs = await paginationApiServices.getParagraphs(
          paginationParams: paginationParams);
      final hasNext = paragraphs.isNotEmpty &&
          await paginationApiServices.hasNext(
              last: paragraphs.last.id);

      meta = meta.copyWith(hasNext: hasNext);
      cursorPagination = cursorPagination.copyWith(
          meta: meta,
          data: paragraphs
              .map((paragraph) => paragraph as ParagraphModel)
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

  Future<ParagraphModel> addPost({
    required UserModel user,
    required String content,
    required List<File> images,
  }) async {
    try {
      final paragraph = await paragraphApiServices.writeParagraph(
          user: user, content: content);
      ParagraphModel addParagraph;
      addParagraph = await paragraphApiServices.writeImages(
          paragraph: paragraph, images: images);

      return addParagraph;
    } on FirebaseException catch (e) {
      throw CustomError(code: e.code, message: e.message!, plugin: e.plugin);
    } catch (e) {
      throw CustomError(
          code: "Error!",
          message: e.toString(),
          plugin: "flutter_error/server_error");
    }
  }

  Future<ParagraphModel> updatePost(
      {required ParagraphModel paragraph, required List<File> images}) async {
    try {
      final updatedParagraph =
          await paragraphApiServices.updateParagraph(paragraph: paragraph);

      final addParagraph = await paragraphApiServices.updateImages(
          paragraph: updatedParagraph, images: images);

      return addParagraph;
    } on FirebaseException catch (e) {
      throw CustomError(code: e.code, message: e.message!, plugin: e.plugin);
    } catch (e) {
      throw CustomError(
          code: "Error!",
          message: e.toString(),
          plugin: "flutter_error/server_error");
    }
  }

  @override
  Future<ParagraphModel> getById({required String id}) {
    try {
      return paragraphApiServices.getParagraphById(id: id);
    } on FirebaseAuthException catch (e) {
      throw CustomError(code: e.code, message: e.message!, plugin: e.plugin);
    } catch (e) {
      throw CustomError(
          code: "Error!",
          message: e.toString(),
          plugin: "flutter_error/server_error");
    }
  }
}
