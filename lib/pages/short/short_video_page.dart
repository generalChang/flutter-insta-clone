import 'dart:typed_data';

import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_community/blocs/pagination/pagination_cubit.dart';
import 'package:flutter_community/blocs/short/thumbnail/short_thumbnail_cubit.dart';
import 'package:flutter_community/components/video_player_view.dart';
import 'package:flutter_community/consts/theme_const.dart';
import 'package:flutter_community/models/short_video/short_video_model.dart';
import 'package:flutter_community/pages/main_page.dart';
import 'package:flutter_community/pages/short/short_video_detail_page.dart';
import 'package:flutter_community/pages/short/short_video_upload_page.dart';

import 'package:flutter_community/repositories/short_video_repository.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({Key? key}) : super(key: key);

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {

  ScrollController _controller = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<PaginationCubit<ShortVideoModel, ShortVideoRepository>>()
        .pagination(
        forceRefetch: true,
        count: 30
    );
    _controller.addListener(listner);
  }

  void listner() {
    if (_controller.offset > _controller.position.maxScrollExtent - 200) {
      context.read<PaginationCubit<ShortVideoModel, ShortVideoRepository>>()
          .pagination(fetchMore: true, count: 30);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.removeListener(listner);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("짧영",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
            IconButton(onPressed: () {
              Navigator.of(context).pushNamed(ShortVideoUploadPage.routeName);
            }, icon: Icon(Icons.video_collection_rounded,),
              color: SECONDERY_COLOR, iconSize: 35,),
          ],
        ),
        BlocConsumer<
            PaginationCubit<ShortVideoModel, ShortVideoRepository>,
            PaginationState<ShortVideoModel>>(
          listener: (context, state) {
            // TODO: implement listener

          },
          builder: (context, state) {
            if (state.status == PaginationStatus.initial) {
              return Container();
            }

            if (state.status == PaginationStatus.loading) {
              return Center(
                child: CircularProgressIndicator(color: SECONDERY_COLOR,),
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

            final shorts = state.cursorPagination.data;
            return BlocBuilder<ShortThumbnailCubit, ShortThumbnailState>(
              builder: (context, state) {
                if(state.status == ShortThumbnailStatus.loading){
                  return Center(
                    child: Text("로딩중입니다.."),
                  );
                }
                return Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<PaginationCubit<ShortVideoModel, ShortVideoRepository>>()
                          .pagination(
                          forceRefetch: true,
                          count: 30
                      );
                    },
                    child: GridView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      controller: _controller,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 3,
                        mainAxisSpacing: 3
                      ),
                      itemBuilder: (context, index) {
                        return LayoutBuilder(
                            builder: (context, constraints) {
                              return GestureDetector(
                                onTap: (){
                                  Navigator.of(context).pushNamedAndRemoveUntil(ShortVideoDetailPage.routeName,
                                          (route){
                                            return route.settings.name == MainPage.routeName;
                                          }, arguments: state.thumbnails[index].id);
                                },
                                child: Container(
                                    color: Colors.black,
                                    height: constraints.maxWidth / 3,
                                    child: Image.memory(state.thumbnails[index].thumbnail!)),
                              );
                            }
                        );
                      },
                      itemCount: state.thumbnails!.length,),
                  ),
                );
              },
            );
          },
        )
      ],
    );
  }

}
