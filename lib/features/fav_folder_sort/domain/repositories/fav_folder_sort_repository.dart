import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/fav_folder_sort/domain/entities/fav_folder_sort_params.dart';

/// Repository interface for favorite folder sort operations
abstract class FavFolderSortRepository {
  /// Sort favorite folders by order
  ///
  /// [params] contains ordered list of folder IDs
  ///
  /// Returns [Success] if sort was successful, [Error] otherwise
  Future<LoadingState<Null>> sortFolders(FavFolderSortParams params);
}
