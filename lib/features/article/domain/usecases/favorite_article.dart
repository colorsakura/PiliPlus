import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/article/domain/repositories/article_repository.dart';

/// Favorite article use case
class FavoriteArticle {
  final ArticleRepository repository;

  const FavoriteArticle(this.repository);

  Future<LoadingState<void>> call({
    required int cvId,
    required String opusId,
    required bool isFavorite,
  }) {
    return repository.favoriteArticle(
      cvId: cvId,
      opusId: opusId,
      isFavorite: isFavorite,
    );
  }
}
