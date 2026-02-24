import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/fav/fav_article/domain/repositories/fav_article_repository.dart';

/// Use case for removing an article from favorites
class RemoveArticleUseCase {
  const RemoveArticleUseCase(this._repository);

  final FavArticleRepository _repository;

  Future<LoadingState<void>> call(String opusId) {
    return _repository.removeArticle(opusId);
  }
}
