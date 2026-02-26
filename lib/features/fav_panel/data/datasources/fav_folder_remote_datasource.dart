import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_folder/list.dart';

/// Data source interface for favorite folder operations
abstract class FavFolderRemoteDataSource {
  /// Query folders containing a specific video via API
  ///
  /// Returns [Success] with list of folders, or [Error] if failed
  Future<LoadingState<List<FavFolderInfo>>> queryVideoInFolders();
}
