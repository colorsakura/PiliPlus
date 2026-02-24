import 'package:PiliPlus/features/article_list/data/datasources/article_list_remote_datasource.dart';
import 'package:PiliPlus/features/article_list/domain/entities/article_list_item.dart';
import 'package:PiliPlus/features/article_list/domain/repositories/article_list_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Article list repository implementation
///
/// Implements the article list repository using remote data source
class ArticleListRepositoryImpl implements ArticleListRepository {
  final ArticleListRemoteDataSource _remoteDataSource;

  ArticleListRepositoryImpl({
    required ArticleListRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<LoadingState<ArticleListDataEntity>> getArticleList(String id) {
    return _remoteDataSource.getArticleList(id);
  }
}
