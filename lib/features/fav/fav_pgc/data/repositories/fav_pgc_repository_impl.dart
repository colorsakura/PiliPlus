import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_pgc/list.dart';
import 'package:PiliPlus/features/fav/fav_pgc/domain/repositories/fav_pgc_repository.dart';
import 'package:PiliPlus/features/fav/fav_pgc/data/datasources/fav_pgc_remote_datasource.dart';

/// Repository implementation for favorite PGC
class FavPgcRepositoryImpl implements FavPgcRepository {
  const FavPgcRepositoryImpl(this._remoteDatasource);

  final FavPgcRemoteDatasource _remoteDatasource;

  @override
  Future<LoadingState<List<FavPgcItemModel>>> getFavPgc(int page, int type, int followStatus) async {
    final result = await _remoteDatasource.getFavPgc(
      page: page,
      type: type,
      followStatus: followStatus,
    );
    return switch (result) {
      Loading() => LoadingState.loading(),
      Success(:final response) => Success(response.toItemList()),
      Error(:final errMsg) => Error(errMsg),
    };
  }

  @override
  Future<LoadingState<String?>> removePgc(int seasonId) {
    return _remoteDatasource.removePgc(seasonId);
  }

  @override
  Future<LoadingState<String?>> updatePgcFollowStatus(String seasonId, int followStatus) {
    return _remoteDatasource.updatePgcFollowStatus(
      seasonId: seasonId,
      followStatus: followStatus,
    );
  }
}
