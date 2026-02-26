import 'package:PiliPlus/models/user/info.dart';
import 'package:PiliPlus/models/user/stat.dart';
import 'package:PiliPlus/models/later/data.dart';
import 'package:PiliPlus/features/user/data/datasources/user_remote_datasource.dart';
import 'package:PiliPlus/features/user/data/datasources/user_remote_datasource_interface.dart';

/// Implementation adapter that wraps existing UserRemoteDataSource
class UserRemoteDataSourceImpl implements IUserRemoteDataSource {
  final UserRemoteDataSource _dataSource;

  const UserRemoteDataSourceImpl(this._dataSource);

  @override
  Future<UserInfoData> userInfo() => _dataSource.userInfo();

  @override
  Future<UserStat> userStatOwner() => _dataSource.userStatOwner();

  @override
  Future<LaterData> seeYouLater({
    required int page,
    int viewed = 0,
    String keyword = '',
    bool asc = false,
  }) =>
      _dataSource.seeYouLater(
        page: page,
        viewed: viewed,
        keyword: keyword,
        asc: asc,
      );
}
