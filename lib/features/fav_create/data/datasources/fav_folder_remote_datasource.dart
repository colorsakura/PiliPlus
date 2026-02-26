import 'package:PiliPlus/http/fav.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/msg.dart';
import 'package:PiliPlus/models/fav/fav_folder/list.dart';

/// Favorite folder remote data source interface
abstract class FavFolderRemoteDataSource {
  /// Get favorite folder info
  Future<LoadingState<FavFolderInfo>> getFolderInfo(String mediaId);

  /// Create or edit favorite folder
  Future<LoadingState<FavFolderInfo>> addOrEditFolder({
    required bool isAdd,
    String? mediaId,
    required String title,
    required int privacy,
    required String cover,
    required String intro,
  });

  /// Upload image
  Future<LoadingState<Map<String, dynamic>>> uploadImage({
    required String path,
    required String bucket,
    required String dir,
  });
}

/// Favorite folder remote data source implementation
class FavFolderRemoteDataSourceImpl implements FavFolderRemoteDataSource {
  const FavFolderRemoteDataSourceImpl();

  @override
  Future<LoadingState<FavFolderInfo>> getFolderInfo(String mediaId) {
    return FavHttp.favFolderInfo(mediaId: mediaId);
  }

  @override
  Future<LoadingState<FavFolderInfo>> addOrEditFolder({
    required bool isAdd,
    String? mediaId,
    required String title,
    required int privacy,
    required String cover,
    required String intro,
  }) {
    return FavHttp.addOrEditFolder(
      isAdd: isAdd,
      mediaId: mediaId,
      title: title,
      privacy: privacy,
      cover: cover,
      intro: intro,
    );
  }

  @override
  Future<LoadingState<Map<String, dynamic>>> uploadImage({
    required String path,
    required String bucket,
    required String dir,
  }) {
    return MsgHttp.uploadImage(
      path: path,
      bucket: bucket,
      dir: dir,
    ).then((result) {
      // Convert Map<dynamic, dynamic> to Map<String, dynamic>
      if (result case Success(:final data)) {
        return Success(Map<String, dynamic>.from(data));
      }
      return result as Error;
    });
  }
}
