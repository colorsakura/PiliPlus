import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_folder/list.dart';
import 'package:PiliPlus/features/fav_panel/domain/repositories/fav_folder_repository.dart';

/// Use case for querying folders containing a specific video
class QueryVideoInFolders {
  final FavFolderRepository repository;

  const QueryVideoInFolders(this.repository);

  /// Execute the query
  ///
  /// Returns [Success] with list of folders containing the video,
  /// or [Error] if failed
  Future<LoadingState<List<FavFolderInfo>>> call() {
    return repository.queryVideoInFolders();
  }
}
