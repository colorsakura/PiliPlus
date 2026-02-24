import 'package:PiliPlus/features/article_list/domain/entities/article_list_item.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Article list repository interface
abstract interface class ArticleListRepository {
  /// Get article list by ID
  Future<LoadingState<ArticleListDataEntity>> getArticleList(String id);
}
