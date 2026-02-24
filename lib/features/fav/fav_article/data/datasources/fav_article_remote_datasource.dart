import 'package:PiliPlus/http/fav.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_article/data.dart';
import 'package:PiliPlus/models/fav/fav_article/item.dart';

/// Remote data source for favorite articles
class FavArticleRemoteDatasource {
  /// Get favorite articles from API
  Future<LoadingState<FavArticleData>> getFavArticles({required int page}) {
    return FavHttp.favArticle(page: page);
  }

  /// Remove article from favorites via API
  Future<LoadingState<void>> removeArticle({required String opusId}) {
    return FavHttp.communityAction(opusId: opusId, action: 4);
  }
}

/// Extension to convert FavArticleData to List<FavArticleItemModel>
extension FavArticleDataExtension on FavArticleData {
  List<FavArticleItemModel> toItemList() {
    return items ?? [];
  }
}
