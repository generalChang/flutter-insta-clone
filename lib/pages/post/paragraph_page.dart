import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_community/blocs/pagination/pagination_cubit.dart';
import 'package:flutter_community/consts/theme_const.dart';
import 'package:flutter_community/models/community/paragraph_model.dart';
import 'package:flutter_community/pages/post/paragraph_detail_page.dart';
import 'package:flutter_community/repositories/like_repository.dart';
import 'package:flutter_community/repositories/paragraph_repository.dart';
import 'package:flutter_community/utils/error_dialog.dart';
import 'package:flutter_community/utils/pagination_data_utils.dart';

import '../../components/paragraph_card.dart';
import '../../models/comment/comment_model.dart';
import '../../repositories/comment_repository.dart';

class ParagraphPage extends StatefulWidget {
  const ParagraphPage({Key? key}) : super(key: key);


  @override
  State<ParagraphPage> createState() => _ParagraphPageState();
}

class _ParagraphPageState extends State<ParagraphPage> {

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(scrollListener);

  }

  void scrollListener(){
    if(_scrollController.offset > _scrollController.position.maxScrollExtent - 200){
      context.read<PaginationCubit<ParagraphModel, ParagraphRepository>>()
          .pagination(fetchMore: true);
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
    return BlocConsumer<PaginationCubit<ParagraphModel, ParagraphRepository>,
        PaginationState>(
      listener: (context, state) {
        // TODO: implement listener
        if(state.status == PaginationStatus.error){
          errorDialog(context: context, error: state.error);
        }
      },
      builder: (context, state) {
        if (state.status == PaginationStatus.loading) {
          return Center(
            child: CircularProgressIndicator(
              color: SECONDERY_COLOR,
            ),
          );
        }

        if (state.status == PaginationStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("에러가 발생했습니다."),
                ElevatedButton(
                  onPressed: () {},
                  child: Text("다시시도"),
                  style: ElevatedButton.styleFrom(primary: SECONDERY_COLOR),
                )
              ],
            ),
          );
        }

        final paragraphs = state.cursorPagination.data
            .map((paragraph) => paragraph as ParagraphModel)
            .toList();

        return RefreshIndicator(
          onRefresh: () async {
            context.read<PaginationCubit<ParagraphModel, ParagraphRepository>>().pagination(forceRefetch: true);
          },
          child: ListView.separated(
            physics: AlwaysScrollableScrollPhysics(),
            controller: _scrollController,
            separatorBuilder: (context, index) {
              return SizedBox(height: 16,);
            },
            itemBuilder: (context, index) {
              if (index == paragraphs.length) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Center(
                    child: state.status == PaginationStatus.fetchingMore
                        ? CircularProgressIndicator()
                        : Text("데이터가 없습니다."),
                  ),
                );
              }

              final paragraph = paragraphs[index];
              return GestureDetector(
                  onTap: (){
                    Navigator.of(context).pushNamed(ParagraphDetailPage.routeName, arguments: paragraph);
                    // Navigator.of(context).push(MaterialPageRoute(builder: (context) => ParagraphDetailPage(paragraphModel: paragraphs[index])));
                  },
                  child: ParagraphCard.fromModel(paragraphModel: paragraph));
            },
            itemCount: paragraphs.length + 1,
          ),
        );
      },
    );
  }
}
