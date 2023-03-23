import 'package:chewie/chewie.dart';
import "package:flutter/material.dart";
import 'package:video_player/video_player.dart';

class VideoPlayerView extends StatefulWidget {
  final String url;
  const VideoPlayerView({Key? key, required this.url}) : super(key: key);

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _videoPlayerController = VideoPlayerController.network(widget.url);
    _videoPlayerController.initialize().then((value) {
      setState(() {
        _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController);
      });
    });

  }

  @override
  void dispose() {
    // TODO: implement dispose
    if(_videoPlayerController != null){
      _videoPlayerController.dispose();
    }
    if(_chewieController != null){
      _chewieController!.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _videoPlayerController.value.isInitialized && _chewieController != null ?
        AspectRatio(
          aspectRatio: _videoPlayerController.value.aspectRatio,
          child: Chewie(
            controller: _chewieController!,
          ),
        ) : SizedBox.shrink()
      ],
    );
  }
}
