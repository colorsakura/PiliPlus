import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/article/domain/entities/article_content.dart';
import 'package:PiliPlus/features/article/domain/repositories/article_repository.dart';

/// Get read article detail use case
class GetReadArticleDetail {
  final ArticleRepository repository;

  const GetReadArticleDetail(this.repository);

  Future<LoadingState<ReadContentEntity>> call(int cvId) {
    return repository.getReadArticleDetail(cvId);
  }
}
