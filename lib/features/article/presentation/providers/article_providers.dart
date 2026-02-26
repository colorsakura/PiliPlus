import 'package:PiliPlus/features/article/data/datasources/article_remote_datasource.dart';
import 'package:PiliPlus/features/article/data/repositories/article_repository_impl.dart';
import 'package:PiliPlus/features/article/domain/repositories/article_repository.dart';
import 'package:PiliPlus/features/article/domain/usecases/favorite_article.dart';
import 'package:PiliPlus/features/article/domain/usecases/get_article_info.dart';
import 'package:PiliPlus/features/article/domain/usecases/get_opus_detail.dart';
import 'package:PiliPlus/features/article/domain/usecases/get_read_article_detail.dart';
import 'package:PiliPlus/features/article/domain/usecases/like_article.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Article remote data source provider
final articleRemoteDataSourceProvider = Provider<ArticleRemoteDataSource>((ref) {
  return const ArticleRemoteDataSourceImpl();
});

/// Article repository provider
final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  final remoteDataSource = ref.watch(articleRemoteDataSourceProvider);
  return ArticleRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});

/// Get opus detail use case provider
final getOpusDetailUseCaseProvider = Provider<GetOpusDetail>((ref) {
  final repository = ref.watch(articleRepositoryProvider);
  return GetOpusDetail(repository);
});

/// Get read article detail use case provider
final getReadArticleDetailUseCaseProvider = Provider<GetReadArticleDetail>((ref) {
  final repository = ref.watch(articleRepositoryProvider);
  return GetReadArticleDetail(repository);
});

/// Get article info use case provider
final getArticleInfoUseCaseProvider = Provider<GetArticleInfo>((ref) {
  final repository = ref.watch(articleRepositoryProvider);
  return GetArticleInfo(repository);
});

/// Like article use case provider
final likeArticleUseCaseProvider = Provider<LikeArticle>((ref) {
  final repository = ref.watch(articleRepositoryProvider);
  return LikeArticle(repository);
});

/// Favorite article use case provider
final favoriteArticleUseCaseProvider = Provider<FavoriteArticle>((ref) {
  final repository = ref.watch(articleRepositoryProvider);
  return FavoriteArticle(repository);
});
