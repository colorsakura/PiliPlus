import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/fav_create/domain/entities/fav_folder.dart';

/// Favorite folder repository interface
abstract class FavFolderRepository {
  /// Get favorite folder info
  Future<LoadingState<FavFolderEntity>> getFolderInfo(String mediaId);

  /// Create or edit favorite folder
  Future<LoadingState<String>> createOrEditFolder(FavFolderParamsEntity params);

  /// Upload cover image
  Future<LoadingState<String>> uploadCover(String imagePath);
}
