import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_folder/list.dart';

/// Repository interface for favorite folders (video collections)
abstract class FavVideoRepository {
  /// Get favorite folders list
  Future<LoadingState<List<FavFolderInfo>>> getFavFolders(int page);
}
