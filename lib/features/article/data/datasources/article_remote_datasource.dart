import 'package:PiliPlus/http/dynamics.dart';
import 'package:PiliPlus/http/fav.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamics/result.dart';

/// Article remote data source interface
abstract class ArticleRemoteDataSource {
  Future<LoadingState<DynamicItemModel>> getOpusDetail(String opusId);
  Future<LoadingState> getReadArticleDetail(int cvId);
  Future<LoadingState> getArticleInfo(int cvId);
  Future<LoadingState<void>> likeArticle(String? dynIdStr, {required bool isLike});
  Future<LoadingState<void>> favoriteArticle({
    required int cvId,
    required String opusId,
    required bool isFavorite,
  });
}

/// Article remote data source implementation
class ArticleRemoteDataSourceImpl implements ArticleRemoteDataSource {
  const ArticleRemoteDataSourceImpl();

  @override
  Future<LoadingState<DynamicItemModel>> getOpusDetail(String opusId) {
    return DynamicsHttp.opusDetail(opusId: opusId);
  }

  @override
  Future<LoadingState> getReadArticleDetail(int cvId) {
    return DynamicsHttp.articleView(cvId: cvId);
  }

  @override
  Future<LoadingState> getArticleInfo(int cvId) {
    return DynamicsHttp.articleInfo(cvId: cvId);
  }

  @override
  Future<LoadingState<void>> likeArticle(String? dynIdStr, {required bool isLike}) {
    return DynamicsHttp.thumbDynamic(
      dynamicId: dynIdStr,
      up: isLike ? 2 : 1,
    );
  }

  @override
  Future<LoadingState<void>> favoriteArticle({
    required int cvId,
    required String opusId,
    required bool isFavorite,
  }) {
    if (opusId.isNotEmpty) {
      // Opus favorite
      return FavHttp.communityAction(
        opusId: opusId,
        action: isFavorite ? 4 : 3,
      );
    } else {
      // Read article favorite
      return isFavorite
          ? FavHttp.delFavArticle(id: cvId)
          : FavHttp.addFavArticle(id: cvId);
    }
  }
}
