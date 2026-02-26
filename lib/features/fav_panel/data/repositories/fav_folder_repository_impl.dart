import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/fav_panel/domain/repositories/fav_folder_repository.dart';
import 'package:PiliPlus/features/fav_panel/data/datasources/fav_folder_remote_datasource.dart';
import 'package:PiliPlus/models/fav/fav_folder/list.dart';

/// Implementation of favorite folder repository
class FavFolderRepositoryImpl implements FavFolderRepository {
  final FavFolderRemoteDataSource remoteDataSource;

  const FavFolderRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<LoadingState<List<FavFolderInfo>>> queryVideoInFolders() {
    return remoteDataSource.queryVideoInFolders();
  }
}
