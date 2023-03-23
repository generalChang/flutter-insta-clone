part of 'short_thumbnail_cubit.dart';

enum ShortThumbnailStatus{
  initial,
  loading,
  success,
  error
}

class ShortThumbnailState{
  final ShortThumbnailStatus status;
  final List<ShortVideoThumbnailModel> thumbnails;
  final CustomError error;

  const ShortThumbnailState({
    required this.status,
    required this.thumbnails,
    required this.error,
  });

  factory ShortThumbnailState.initial(){
    return ShortThumbnailState(
        status: ShortThumbnailStatus.initial,
        thumbnails: [],
        error: CustomError());
  }

  ShortThumbnailState copyWith({
    ShortThumbnailStatus? status,
    List<ShortVideoThumbnailModel>? thumbnails,
    CustomError? error,
  }) {
    return ShortThumbnailState(
      status: status ?? this.status,
      thumbnails: thumbnails ?? this.thumbnails,
      error: error ?? this.error,
    );
  }
}