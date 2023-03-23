import 'dart:typed_data';

class ShortVideoThumbnailModel{
  final String id;
  final Uint8List? thumbnail;

  ShortVideoThumbnailModel({
    required this.id,
    required this.thumbnail,
  });

  factory ShortVideoThumbnailModel.initial(){
    return ShortVideoThumbnailModel(
        id: "",
        thumbnail: null);
  }

  ShortVideoThumbnailModel copyWith({
    String? id,
    Uint8List? thumbnail,
  }) {
    return ShortVideoThumbnailModel(
      id: id ?? this.id,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }
}