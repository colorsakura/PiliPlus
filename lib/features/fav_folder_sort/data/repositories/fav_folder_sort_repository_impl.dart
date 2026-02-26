import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/fav_folder_sort/domain/entities/fav_folder_sort_params.dart';
import 'package:PiliPlus/features/fav_folder_sort/domain/repositories/fav_folder_sort_repository.dart';
import 'package:PiliPlus/features/fav_folder_sort/data/datasources/fav_folder_sort_remote_datasource.dart';

/// Implementation of favorite folder sort repository
class FavFolderSortRepositoryImpl implements FavFolderSortRepository {
  final FavFolderSortRemoteDataSource remoteDataSource;

  const FavFolderSortRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<LoadingState<Null>> sortFolders(FavFolderSortParams params) {
    return remoteDataSource.sortFolders(
      sort: params.sortString,
    );
  }
}
