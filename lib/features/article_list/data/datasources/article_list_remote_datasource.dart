import 'package:PiliPlus/features/article_list/domain/entities/article_list_item.dart';
import 'package:PiliPlus/http/dynamics.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Article list remote data source
///
/// Responsible for fetching article list data from the API
class ArticleListRemoteDataSource {
  /// Get article list by ID from API
  Future<LoadingState<ArticleListDataEntity>> getArticleList(String id) async {
    final result = await DynamicsHttp.articleList(id: id);

    return switch (result) {
      Loading() => result as LoadingState<ArticleListDataEntity>,
      Success(:final response) => Success(
          ArticleListDataEntity.fromModel(response),
        ),
      Error() => result as LoadingState<ArticleListDataEntity>,
    };
  }
}
