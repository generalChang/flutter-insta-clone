import '../models/like_model.dart';

abstract class BaseLikeRepository{
  Future<void> upLike(
      {
        required String userId,
         required String targetId}); // userId.});

  Future<void> unLike(
      {required String userId,
        required String targetId});

  Future<List<LikeModel>> getLikes({required String targetId});
}