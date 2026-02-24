import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_article/item.dart';
import 'package:PiliPlus/features/fav/fav_article/domain/repositories/fav_article_repository.dart';
import 'package:PiliPlus/features/fav/fav_article/data/datasources/fav_article_remote_datasource.dart';

/// Repository implementation for favorite articles
class FavArticleRepositoryImpl implements FavArticleRepository {
  const FavArticleRepositoryImpl(this._remoteDatasource);

  final FavArticleRemoteDatasource _remoteDatasource;

  @override
  Future<LoadingState<List<FavArticleItemModel>>> getFavArticles(int page) async {
    final result = await _remoteDatasource.getFavArticles(page: page);
    return switch (result) {
      Loading() => LoadingState.loading(),
      Success(:final response) => Success(response.toItemList()),
      Error(:final errMsg) => Error(errMsg),
    };
  }

  @override
  Future<LoadingState<void>> removeArticle(String opusId) {
    return _remoteDatasource.removeArticle(opusId: opusId);
  }
}
