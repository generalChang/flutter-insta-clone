part of 'short_video_add_cubit.dart';

enum ShortVideoAddStatus { initial, uploading, success, error }

class ShortVideoAddState {
  final ShortVideoAddStatus status;
  final ShortVideoModel shortVideo;
  final CustomError error;

  ShortVideoAddState({
    required this.shortVideo,
    required this.status,
    required this.error,
  });

  factory ShortVideoAddState.initial() {
    return ShortVideoAddState(
        status: ShortVideoAddStatus.initial,
        shortVideo: ShortVideoModel.initial(),
        error: CustomError());
  }

  ShortVideoAddState copyWith(
      {ShortVideoAddStatus? status,
        CustomError? error,
        ShortVideoModel? shortVideo}) {
    return ShortVideoAddState(
        status: status ?? this.status,
        error: error ?? this.error,
        shortVideo: shortVideo ?? this.shortVideo);
  }
}