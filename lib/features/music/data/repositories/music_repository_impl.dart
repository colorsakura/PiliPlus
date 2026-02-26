import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/music/data/datasources/music_remote_datasource_interface.dart';
import 'package:PiliPlus/features/music/domain/entities/music_detail.dart';
import 'package:PiliPlus/features/music/domain/repositories/music_repository.dart';
import 'package:PiliPlus/models/music/bgm_detail.dart';

/// Music repository implementation
class MusicRepositoryImpl implements MusicRepository {
  final MusicRemoteDataSource remoteDataSource;

  const MusicRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<LoadingState<MusicDetailEntity>> getMusicDetail(String musicId) async {
    try {
      final rawData = await remoteDataSource.getBgmDetail(musicId);
      final detail = MusicDetail.fromJson(rawData);

      final comment = detail.musicComment;
      return Success(
        MusicDetailEntity(
          musicId: musicId,
          title: detail.musicTitle,
          author: detail.originArtist,
          cover: detail.mvCover,
          audioUrl: detail.musicOutUrl,
          duration: null, // Duration not available in MusicDetail
          isLiked: detail.wishListen ?? false,
          likeCount: detail.wishCount,
          playCount: detail.listenPv,
          comment: comment != null
              ? MusicCommentEntity(
                  oid: comment.oid,
                  pageType: comment.pageType,
                  count: comment.nums,
                )
              : null,
        ),
      );
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<LoadingState<void>> updateFavoriteStatus({
    required String musicId,
    required bool isFavorite,
  }) async {
    try {
      await remoteDataSource.updateWishStatus(
        musicId: musicId,
        hasLike: isFavorite,
      );
      return const Success(null);
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<LoadingState<List<MusicRecommendEntity>>> getMusicRecommendations(
    String musicId,
  ) async {
    try {
      final rawData = await remoteDataSource.getBgmRecommend(musicId);
      if (rawData == null) {
        return const Success([]);
      }

      final recommendations = rawData
          .map((item) => MusicRecommendEntity(
                musicId: item['id']?.toString(),
                title: item['title']?.toString(),
                author: item['author']?.toString(),
                cover: item['cover']?.toString(),
                duration: item['duration'] as int?,
              ))
          .toList();

      return Success(recommendations);
    } catch (e) {
      return Error(e.toString());
    }
  }
}
