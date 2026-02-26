import 'package:PiliPlus/models/user/info.dart';
import 'package:PiliPlus/models/user/stat.dart';
import 'package:PiliPlus/models/later/data.dart';
import 'package:PiliPlus/features/user/domain/entities/user_params.dart';

/// Repository interface for user operations
abstract class UserRepository {
  /// Fetch user navigation info
  Future<UserInfoData> fetchUserInfo([FetchUserInfoParams? params]);

  /// Fetch user statistics
  Future<UserStat> fetchUserStat(FetchUserStatParams params);

  /// Fetch "See You Later" (watch later) list
  Future<LaterData> fetchSeeYouLater(FetchSeeYouLaterParams params);
}
