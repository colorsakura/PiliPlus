import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/fav_create/domain/entities/fav_folder.dart';
import 'package:PiliPlus/features/fav_create/domain/repositories/fav_folder_repository.dart';

/// Get favorite folder info use case
class GetFavFolderInfo {
  final FavFolderRepository repository;

  const GetFavFolderInfo(this.repository);

  Future<LoadingState<FavFolderEntity>> call(String mediaId) {
    return repository.getFolderInfo(mediaId);
  }
}

/// Create or edit favorite folder use case
class CreateOrEditFavFolder {
  final FavFolderRepository repository;

  const CreateOrEditFavFolder(this.repository);

  Future<LoadingState<String>> call(FavFolderParamsEntity params) {
    return repository.createOrEditFolder(params);
  }
}

/// Upload cover image use case
class UploadFavCover {
  final FavFolderRepository repository;

  const UploadFavCover(this.repository);

  Future<LoadingState<String>> call(String imagePath) {
    return repository.uploadCover(imagePath);
  }
}
