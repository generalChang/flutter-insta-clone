import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_community/blocs/pagination/pagination_cubit.dart';
import 'package:flutter_community/components/comment_card.dart';
import 'package:flutter_community/components/custom_bottom_sheet.dart';
import 'package:flutter_community/components/default_layout.dart';
import 'package:flutter_community/consts/theme_const.dart';
import 'package:flutter_community/models/comment/comment_model.dart';
import 'package:flutter_community/models/community/paragraph_model.dart';
import 'package:flutter_community/repositories/like_repository.dart';
import 'package:flutter_community/repositories/comment_repository.dart';
import 'package:flutter_community/utils/error_dialog.dart';
import 'package:skeletons/skeletons.dart';

import '../../blocs/profile/profile_cubit.dart';
import '../../components/paragraph_card.dart';
import '../../repositories/paragraph_repository.dart';
import '../../utils/pagination_data_utils.dart';

class ParagraphDetailPage extends StatefulWidget {
  final ParagraphModel paragraphModel;

  static String get routeName => "/paragraph/detail";

  const ParagraphDetailPage({Key? key, required this.paragraphModel})
      : super(key: key);

  @override
  State<ParagraphDetailPage> createState() => _ParagraphDetailPageState();
}

class _ParagraphDetailPageState extends State<ParagraphDetailPage> {
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(scrollListener);
    context
        .read<PaginationCubit<CommentModel, CommentRepository>>()
        .pagination(forceRefetch: true, paragraphId: widget.paragraphModel.id);
    context
        .read<PaginationCubit<ParagraphModel, ParagraphRepository>>()
        .get(id: widget.paragraphModel.id);
  }

  void scrollListener() {
    if (_scrollController.offset >
        _scrollController.position.maxScrollExtent - 200) {
      context
          .read<PaginationCubit<CommentModel, CommentRepository>>()
          .pagination(fetchMore: true, paragraphId: widget.paragraphModel.id);
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
    final paginationCubit =
        context.read<PaginationCubit<ParagraphModel, ParagraphRepository>>();

    final profileState = context.watch<ProfileCubit>().state;

    return DefaultLayout(
        floatingActionButton: FloatingActionButton(
          backgroundColor: SECONDERY_COLOR,
          onPressed: () {
            showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return CustomBottomSheet(
                      paragraphId: widget.paragraphModel.id);
                });
          },
          child: Icon(
            Icons.edit,
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false,
        onWillPop: () async => true,
        title: "상세정보",
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            BlocConsumer<PaginationCubit<ParagraphModel, ParagraphRepository>,
                PaginationState<ParagraphModel>>(
              listener: (context, state) {
                // TODO: implement listener
              },
              builder: (context, state) {
                if (state.cursorPagination.data
                    .where((e) => e.id == widget.paragraphModel.id)
                    .isEmpty) {
                  //아직 해당 모델이 없으면
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Text("로딩중입니다.."),
                    ),
                  );
                }
                if (state.status == PaginationStatus.error) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("에러가 발생했습니다"),
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
                final myParagraph = state.cursorPagination.data.where((e) => e.id == widget.paragraphModel.id).last;
                return renderParagraph(paragraphModel: myParagraph);
              },
            ),
            PaginationDataUtils.renderCommentHeader(),
            BlocConsumer<PaginationCubit<CommentModel, CommentRepository>,
                PaginationState<CommentModel>>(builder: (context, state) {
              if (state.status == PaginationStatus.loading) {
                return PaginationDataUtils.renderLoading();
              }

              if (state.status == PaginationStatus.error) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("댓글을 불러오지 못했습니다."),
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

              return PaginationDataUtils.renderComments(comments: state.cursorPagination.data);
            }, listener: (context, state) {
              if (state.status == PaginationStatus.error) {
                errorDialog(context: context, error: state.error);
              }
            })
          ],
        ));
  }

  SliverToBoxAdapter renderParagraph({required ParagraphModel paragraphModel}) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: ParagraphCard.fromModel(
          paragraphModel: paragraphModel,
          isDetail: true,
        ),
      ),
    );
  }
}
