import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/article/domain/repositories/article_repository.dart';

/// Like article use case
class LikeArticle {
  final ArticleRepository repository;

  const LikeArticle(this.repository);

  Future<LoadingState<void>> call(String? dynIdStr, {required bool isLike}) {
    return repository.likeArticle(dynIdStr, isLike: isLike);
  }
}
