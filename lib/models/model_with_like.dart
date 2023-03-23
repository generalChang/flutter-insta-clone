import 'like_model.dart';

abstract class IBaseModelWithLike{
  List<LikeModel> likes;

  IBaseModelWithLike({
    required this.likes,
  });
}