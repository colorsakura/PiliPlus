import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_folder/list.dart';

/// Repository interface for favorite folder operations
abstract class FavFolderRepository {
  /// Query folders containing a specific video
  ///
  /// Returns [Success] with list of folders, or [Error] if failed
  Future<LoadingState<List<FavFolderInfo>>> queryVideoInFolders();
}
