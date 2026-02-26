import 'package:PiliPlus/models/user/info.dart';
import 'package:PiliPlus/models/user/stat.dart';
import 'package:PiliPlus/models/later/data.dart';
import 'package:PiliPlus/features/user/data/datasources/user_remote_datasource.dart';
import 'package:PiliPlus/features/user/data/datasources/user_remote_datasource_interface.dart';
import 'package:PiliPlus/features/user/data/datasources/user_remote_datasource_impl.dart';
import 'package:PiliPlus/features/user/domain/entities/user_params.dart';
import 'package:PiliPlus/features/user/domain/repositories/user_repository.dart';

/// Implementation of user repository
class UserRepositoryImpl implements UserRepository {
  final IUserRemoteDataSource remoteDataSource;

  const UserRepositoryImpl({
    required this.remoteDataSource,
  });

  /// Create from existing UserRemoteDataSource
  static UserRepositoryImpl fromDataSource(UserRemoteDataSource dataSource) {
    return UserRepositoryImpl(
      remoteDataSource: UserRemoteDataSourceImpl(dataSource),
    );
  }

  @override
  Future<UserInfoData> fetchUserInfo([FetchUserInfoParams? params]) {
    return remoteDataSource.userInfo();
  }

  @override
  Future<UserStat> fetchUserStat(FetchUserStatParams params) {
    return remoteDataSource.userStatOwner();
  }

  @override
  Future<LaterData> fetchSeeYouLater(FetchSeeYouLaterParams params) {
    return remoteDataSource.seeYouLater(
      page: params.page,
      viewed: params.viewed,
      keyword: params.keyword,
      asc: params.asc,
    );
  }
}
