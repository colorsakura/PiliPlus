import 'package:PiliPlus/http/fav.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_folder/data.dart';
import 'package:PiliPlus/models/fav/fav_folder/list.dart';
import 'package:PiliPlus/utils/accounts.dart';

/// Remote data source for favorite folders
class FavVideoRemoteDatasource {
  final account = Accounts.main;

  /// Get favorite folders from API
  Future<LoadingState<FavFolderData>> getFavFolders({required int page}) {
    if (!account.isLogin) {
      return Future.value(Error('账号未登录'));
    }
    return FavHttp.userfavFolder(
      pn: page,
      ps: 20,
      mid: account.mid,
    );
  }
}

/// Extension to convert FavFolderData to List<FavFolderInfo>
extension FavFolderDataExtension on FavFolderData {
  List<FavFolderInfo> toItemList() {
    return list ?? [];
  }

  bool get hasNextPage => hasMore == true;
}
