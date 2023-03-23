import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_community/models/short_video/short_video_model.dart';
import 'package:flutter_community/repositories/short_video_repository.dart';

import '../../blocs/pagination/pagination_cubit.dart';
import '../../blocs/profile/profile_cubit.dart';
import '../../components/custom_bottom_sheet.dart';
import '../../components/default_layout.dart';
import '../../components/short_video_card.dart';
import '../../consts/theme_const.dart';
import '../../models/comment/comment_model.dart';
import '../../repositories/comment_repository.dart';
import '../../utils/error_dialog.dart';
import '../../utils/pagination_data_utils.dart';

class ShortVideoDetailPage extends StatefulWidget {
  final String id;
  const ShortVideoDetailPage({Key? key, required this.id}) : super(key: key);

  static String get routeName => "/short/detail";

  @override
  State<ShortVideoDetailPage> createState() => _ShortVideoDetailPageState();
}

class _ShortVideoDetailPageState extends State<ShortVideoDetailPage> {
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(scrollListener);
    context
        .read<PaginationCubit<CommentModel, CommentRepository>>()
        .pagination(forceRefetch: true, paragraphId: widget.id);
    context
        .read<PaginationCubit<ShortVideoModel, ShortVideoRepository>>()
        .get(id: widget.id);
  }

  void scrollListener() {
    if (_scrollController.offset >
        _scrollController.position.maxScrollExtent - 200) {
      context
          .read<PaginationCubit<CommentModel, CommentRepository>>()
          .pagination(fetchMore: true, paragraphId: widget.id);
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
        context.read<PaginationCubit<ShortVideoModel, ShortVideoRepository>>();

    final profileState = context.watch<ProfileCubit>().state;

    return DefaultLayout(
        floatingActionButton: FloatingActionButton(
          backgroundColor: SECONDERY_COLOR,
          onPressed: () {
            showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return CustomBottomSheet(paragraphId: widget.id);
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
            BlocConsumer<PaginationCubit<ShortVideoModel, ShortVideoRepository>,
                PaginationState<ShortVideoModel>>(
              listener: (context, state) {
                // TODO: implement listener
              },
              builder: (context, state) {
                if (state.cursorPagination.data
                    .where((e) => e.id == widget.id)
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
                final myShortVideo = state.cursorPagination.data
                    .where((e) => e.id == widget.id)
                    .last;
                return renderShortVideo(short: myShortVideo);
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

              return PaginationDataUtils.renderComments(
                  comments: state.cursorPagination.data);
            }, listener: (context, state) {
              if (state.status == PaginationStatus.error) {
                errorDialog(context: context, error: state.error);
              }
            })
          ],
        ));
  }

  SliverToBoxAdapter renderShortVideo({required ShortVideoModel short}) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: ShortVideoCard.fromModel(
          shortVideo: short,
        ),
      ),
    );
  }
}
