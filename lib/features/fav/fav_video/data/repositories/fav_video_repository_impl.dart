import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_folder/list.dart';
import 'package:PiliPlus/features/fav/fav_video/domain/repositories/fav_video_repository.dart';
import 'package:PiliPlus/features/fav/fav_video/data/datasources/fav_video_remote_datasource.dart';

/// Repository implementation for favorite folders
class FavVideoRepositoryImpl implements FavVideoRepository {
  const FavVideoRepositoryImpl(this._remoteDatasource);

  final FavVideoRemoteDatasource _remoteDatasource;

  @override
  Future<LoadingState<List<FavFolderInfo>>> getFavFolders(int page) async {
    final result = await _remoteDatasource.getFavFolders(page: page);
    return switch (result) {
      Loading() => LoadingState.loading(),
      Success(:final response) => Success(response.toItemList()),
      Error(:final errMsg) => Error(errMsg),
    };
  }
}
