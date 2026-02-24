import 'package:PiliPlus/features/article_list/domain/repositories/article_list_repository.dart';
import 'package:PiliPlus/features/article_list/domain/entities/article_list_item.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Get article list use case
///
/// Retrieves a list of articles for a given collection ID
class GetArticleListUseCase {
  final ArticleListRepository _repository;

  const GetArticleListUseCase(this._repository);

  /// Execute the use case
  Future<LoadingState<ArticleListDataEntity>> call(String id) {
    return _repository.getArticleList(id);
  }
}
