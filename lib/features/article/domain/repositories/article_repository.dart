import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/article/domain/entities/article_content.dart';
import 'package:PiliPlus/features/article/domain/entities/article_summary.dart';

/// Article repository interface
abstract class ArticleRepository {
  /// Get opus detail by opus id
  Future<LoadingState<OpusContentEntity>> getOpusDetail(String opusId);

  /// Get read article detail by cv id
  Future<LoadingState<ReadContentEntity>> getReadArticleDetail(int cvId);

  /// Get article info by cv id
  Future<LoadingState<ArticleSummaryEntity>> getArticleInfo(int cvId);

  /// Like/unlike article
  Future<LoadingState<void>> likeArticle(String? dynIdStr, {required bool isLike});

  /// Favorite/unfavorite article
  Future<LoadingState<void>> favoriteArticle({
    required int cvId,
    required String opusId,
    required bool isFavorite,
  });
}
