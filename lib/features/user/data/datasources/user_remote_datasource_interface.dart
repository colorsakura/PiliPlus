import 'package:PiliPlus/models/user/info.dart';
import 'package:PiliPlus/models/user/stat.dart';
import 'package:PiliPlus/models/later/data.dart';

/// Data source interface for user operations
abstract class IUserRemoteDataSource {
  /// Fetch user navigation info
  Future<UserInfoData> userInfo();

  /// Fetch user statistics (owner)
  Future<UserStat> userStatOwner();

  /// Fetch "See You Later" (watch later) list
  Future<LaterData> seeYouLater({
    required int page,
    int viewed,
    String keyword,
    bool asc,
  });
}
