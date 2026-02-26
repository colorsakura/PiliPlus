import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/article/data/datasources/article_remote_datasource.dart';
import 'package:PiliPlus/features/article/domain/entities/article_content.dart';
import 'package:PiliPlus/features/article/domain/entities/article_summary.dart';
import 'package:PiliPlus/features/article/domain/repositories/article_repository.dart';
import 'package:PiliPlus/models/dynamics/result.dart';

/// Article repository implementation
class ArticleRepositoryImpl implements ArticleRepository {
  final ArticleRemoteDataSource remoteDataSource;

  const ArticleRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<LoadingState<OpusContentEntity>> getOpusDetail(String opusId) async {
    final result = await remoteDataSource.getOpusDetail(opusId);
    if (result case Success(:final response)) {
      return Success(
        OpusContentEntity(
          id: opusId,
          idStr: response.idStr,
          title: response.modules.moduleTag?.text,
          cover: response.modules.moduleAuthor?.face,
          publishTime: response.modules.moduleAuthor?.pubTs,
          commentIdStr: response.basic?.commentIdStr,
          commentType: response.basic?.commentType,
          content: response.modules.moduleContent,
          stat: _convertModuleStat(response.modules.moduleStat),
        ),
      );
    }
    return result as Error;
  }

  @override
  Future<LoadingState<ReadContentEntity>> getReadArticleDetail(int cvId) async {
    final result = await remoteDataSource.getReadArticleDetail(cvId);
    if (result case Success(:final response)) {
      return Success(
        ReadContentEntity(
          id: cvId.toString(),
          title: response.title,
          cover: response.originImageUrls?.firstOrNull,
          publishTime: response.publishTime,
          dynIdStr: response.dynIdStr,
          content: response.content,
          originImageUrl: response.originImageUrls?.firstOrNull,
          type: response.type,
          ops: response.ops,
        ),
      );
    }
    return result as Error;
  }

  @override
  Future<LoadingState<ArticleSummaryEntity>> getArticleInfo(int cvId) async {
    final result = await remoteDataSource.getArticleInfo(cvId);
    if (result case Success(:final response)) {
      return Success(
        ArticleSummaryEntity(
          title: response.title,
          cover: response.originImageUrls?.firstOrNull,
          author: response.author,
        ),
      );
    }
    return result as Error;
  }

  @override
  Future<LoadingState<void>> likeArticle(String? dynIdStr, {required bool isLike}) {
    return remoteDataSource.likeArticle(dynIdStr, isLike: isLike);
  }

  @override
  Future<LoadingState<void>> favoriteArticle({
    required int cvId,
    required String opusId,
    required bool isFavorite,
  }) {
    return remoteDataSource.favoriteArticle(
      cvId: cvId,
      opusId: opusId,
      isFavorite: isFavorite,
    );
  }

  ArticleStatEntity? _convertModuleStat(ModuleStatModel? moduleStat) {
    if (moduleStat == null) return null;
    return ArticleStatEntity(
      like: moduleStat.like?.count,
      favorite: moduleStat.favorite?.count,
      reply: moduleStat.comment?.count,
      share: moduleStat.forward?.count,
      isLiked: moduleStat.like?.status == true,
      isFavorited: moduleStat.favorite?.status == true,
    );
  }
}
