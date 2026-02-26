import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/fav_panel/data/datasources/fav_folder_remote_datasource.dart';
import 'package:PiliPlus/models/fav/fav_folder/list.dart';

/// Implementation of favorite folder remote data source
/// Note: The actual implementation delegates to the FavMixin controller
/// which provides the queryVideoInFolder method
class FavFolderRemoteDataSourceImpl implements FavFolderRemoteDataSource {
  const FavFolderRemoteDataSourceImpl();

  @override
  Future<LoadingState<List<FavFolderInfo>>> queryVideoInFolders() {
    // This should be implemented with the actual controller mixin
    // The FavPanel widget uses FavMixin controller directly
    throw UnimplementedError(
      'This is handled by the FavMixin controller in the presentation layer',
    );
  }
}
