import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/fav_detail/domain/entities/fav_detail_params.dart';
import 'package:PiliPlus/features/fav_detail/domain/repositories/fav_detail_repository.dart';

/// Use case for cleaning all favorites in a folder
class CleanFavorites {
  final FavDetailRepository repository;

  const CleanFavorites(this.repository);

  Future<LoadingState<Null>> call(CleanFavoritesParams params) =>
      repository.cleanFavorites(params);
}
