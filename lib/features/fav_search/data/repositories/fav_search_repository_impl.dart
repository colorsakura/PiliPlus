import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/fav_search/data/datasources/fav_search_remote_datasource.dart';
import 'package:PiliPlus/features/fav_search/domain/entities/fav_search_result.dart';
import 'package:PiliPlus/features/fav_search/domain/repositories/fav_search_repository.dart';

/// Favorite search repository implementation
class FavSearchRepositoryImpl implements FavSearchRepository {
  final FavSearchRemoteDataSource remoteDataSource;

  const FavSearchRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<LoadingState<FavSearchResultEntity>> searchFavorites(
    FavSearchParamsEntity params,
  ) async {
    final result = await remoteDataSource.searchFolderDetail(
      pn: params.page,
      ps: params.pageSize,
      mediaId: params.mediaId,
      keyword: params.keyword,
      type: params.type,
      order: params.order,
    );

    if (result case Success(:final data)) {
      return Success(
        FavSearchResultEntity(
          medias: data.medias ?? [],
          hasMore: data.hasMore != false,
        ),
      );
    } else {
      return result as Error;
    }
  }
}
