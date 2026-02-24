import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_article/item.dart';
import 'package:PiliPlus/features/fav/fav_article/domain/repositories/fav_article_repository.dart';

/// Use case for getting favorite articles
class GetFavArticlesUseCase {
  const GetFavArticlesUseCase(this._repository);

  final FavArticleRepository _repository;

  Future<LoadingState<List<FavArticleItemModel>>> call(int page) {
    return _repository.getFavArticles(page);
  }
}
