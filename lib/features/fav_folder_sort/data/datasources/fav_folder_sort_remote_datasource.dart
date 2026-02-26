import 'package:PiliPlus/http/loading_state.dart';

/// Data source interface for favorite folder sort operations
abstract class FavFolderSortRemoteDataSource {
  /// Sort favorite folders via API
  ///
  /// [sort] is comma-separated folder IDs in order
  Future<LoadingState<Null>> sortFolders({
    required String sort,
  });
}
