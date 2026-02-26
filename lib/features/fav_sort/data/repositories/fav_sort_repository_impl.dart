import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/fav_sort/domain/entities/fav_sort_entity.dart';
import 'package:PiliPlus/features/fav_sort/domain/repositories/fav_sort_repository.dart';
import 'package:PiliPlus/features/fav_sort/data/datasources/fav_sort_remote_datasource.dart';

/// Implementation of favorite sort repository
class FavSortRepositoryImpl implements FavSortRepository {
  final FavSortRemoteDataSource remoteDataSource;

  const FavSortRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<LoadingState<Null>> sortFavorites(FavSortEntity params) {
    return remoteDataSource.sortFavorites(
      mediaId: params.mediaId,
      sort: params.sort,
    );
  }
}
