import 'package:PiliPlus/features/member_article/domain/entities/member_article_item_entity.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Repository interface for fetching member articles
abstract class MemberArticleRepository {
  /// Fetch articles for a member
  ///
  /// [mid] - Member ID
  /// [page] - Page number (1-indexed)
  Future<LoadingState<List<MemberArticleItemEntity>>> fetchMemberArticles({
    required int mid,
    required int page,
  });
}
