import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/article/domain/entities/article_summary.dart';
import 'package:PiliPlus/features/article/domain/repositories/article_repository.dart';

/// Get article info use case
class GetArticleInfo {
  final ArticleRepository repository;

  const GetArticleInfo(this.repository);

  Future<LoadingState<ArticleSummaryEntity>> call(int cvId) {
    return repository.getArticleInfo(cvId);
  }
}
