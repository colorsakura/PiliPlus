import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/fav_detail/domain/entities/fav_detail_params.dart';
import 'package:PiliPlus/features/fav_detail/domain/repositories/fav_detail_repository.dart';

/// Use case for canceling favorites
class CancelFavorites {
  final FavDetailRepository repository;

  const CancelFavorites(this.repository);

  Future<LoadingState<Null>> call(CancelFavoriteParams params) =>
      repository.cancelFavorites(params);
}
