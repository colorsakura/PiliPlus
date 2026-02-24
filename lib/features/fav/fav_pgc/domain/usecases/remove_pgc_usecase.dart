import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/fav/fav_pgc/domain/repositories/fav_pgc_repository.dart';

/// Use case for removing PGC from favorites
class RemovePgcUseCase {
  const RemovePgcUseCase(this._repository);

  final FavPgcRepository _repository;

  Future<LoadingState<String?>> call(int seasonId) {
    return _repository.removePgc(seasonId);
  }
}
