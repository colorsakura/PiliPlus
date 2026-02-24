import 'package:PiliPlus/features/member_article/domain/entities/member_article_item_entity.dart';
import 'package:PiliPlus/features/member_article/domain/repositories/member_article_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Use case for fetching member articles
class FetchMemberArticlesUseCase {
  const FetchMemberArticlesUseCase(this._repository);

  final MemberArticleRepository _repository;

  /// Execute the use case
  ///
  /// [mid] - Member ID
  /// [page] - Page number (1-indexed)
  Future<LoadingState<List<MemberArticleItemEntity>>> call({
    required int mid,
    required int page,
  }) {
    return _repository.fetchMemberArticles(mid: mid, page: page);
  }
}
