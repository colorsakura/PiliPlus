import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_folder/list.dart';
import 'package:PiliPlus/features/fav/fav_video/domain/repositories/fav_video_repository.dart';

/// Use case for getting favorite folders
class GetFavFoldersUseCase {
  const GetFavFoldersUseCase(this._repository);

  final FavVideoRepository _repository;

  Future<LoadingState<List<FavFolderInfo>>> call(int page) {
    return _repository.getFavFolders(page);
  }
}
