import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/fav_folder_sort/domain/entities/fav_folder_sort_params.dart';
import 'package:PiliPlus/features/fav_folder_sort/domain/repositories/fav_folder_sort_repository.dart';

/// Use case for sorting favorite folders
class SortFavoriteFolders {
  final FavFolderSortRepository repository;

  const SortFavoriteFolders(this.repository);

  /// Execute the sort operation
  ///
  /// [params] contains ordered list of folder IDs
  ///
  /// Returns [Success] if sort was successful, [Error] otherwise
  Future<LoadingState<Null>> call(FavFolderSortParams params) {
    return repository.sortFolders(params);
  }
}
