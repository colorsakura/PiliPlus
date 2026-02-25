import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_pgc/list.dart';
import 'package:PiliPlus/features/fav/fav_pgc/domain/repositories/fav_pgc_repository.dart';

/// Use case for getting favorite PGC
class GetFavPgcUseCase {
  const GetFavPgcUseCase(this._repository);

  final FavPgcRepository _repository;

  Future<LoadingState<List<FavPgcItemModel>>> call(
    int page,
    int type,
    int followStatus,
  ) {
    return _repository.getFavPgc(page, type, followStatus);
  }
}
