import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/fav/fav_pgc/domain/repositories/fav_pgc_repository.dart';

/// Use case for updating PGC follow status
class UpdatePgcFollowStatusUseCase {
  const UpdatePgcFollowStatusUseCase(this._repository);

  final FavPgcRepository _repository;

  Future<LoadingState<String?>> call(String seasonId, int followStatus) {
    return _repository.updatePgcFollowStatus(seasonId, followStatus);
  }
}
