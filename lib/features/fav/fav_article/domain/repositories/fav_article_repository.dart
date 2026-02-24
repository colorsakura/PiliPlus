import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_article/item.dart';

/// Repository interface for favorite articles
abstract class FavArticleRepository {
  /// Get favorite articles list
  Future<LoadingState<List<FavArticleItemModel>>> getFavArticles(int page);

  /// Remove article from favorites
  Future<LoadingState<void>> removeArticle(String opusId);
}
