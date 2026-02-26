import 'package:PiliPlus/http/fav.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/user.dart';
import 'package:PiliPlus/models/user/info.dart';
import 'package:PiliPlus/models/user/stat.dart';
import 'package:PiliPlus/models/fav/fav_folder/data.dart';
import 'package:PiliPlus/features/mine/data/datasources/mine_remote_datasource.dart';
import 'package:PiliPlus/features/mine/domain/entities/fav_folder_entity.dart';
import 'package:PiliPlus/features/mine/domain/entities/user_info_entity.dart';
import 'package:PiliPlus/features/mine/domain/entities/user_stat_entity.dart';
import 'package:PiliPlus/features/mine/domain/repositories/mine_repository.dart';

/// 我的页面仓库实现
class MineRepositoryImpl implements MineRepository {
  final MineRemoteDataSource _remoteDataSource;

  MineRepositoryImpl({
    required MineRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<UserInfoEntity> getUserInfo() async {
    // 使用现有的HTTP请求方法
    final result = await UserHttp.userInfo();

    if (result is Success<UserInfoData>) {
      final userInfo = result.response;
      // 缓存用户信息
      await _remoteDataSource.cacheUserInfo(userInfo);
      return UserInfoEntity.fromModel(userInfo);
    } else {
      throw Exception('获取用户信息失败: $result');
    }
  }

  @override
  Future<UserStatEntity> getUserStat() async {
    final result = await UserHttp.userStatOwner();

    if (result is Success<UserStat>) {
      return UserStatEntity.fromModel(result.response);
    } else {
      throw Exception('获取用户统计信息失败: $result');
    }
  }

  @override
  Future<FavFolderListEntity> getFavFolders({
    required String mid,
    int pn = 1,
    int ps = 20,
  }) async {
    final result = await FavHttp.userfavFolder(
      pn: pn,
      ps: ps,
      mid: mid,
    );

    if (result is Success<FavFolderData>) {
      return FavFolderListEntity.fromModel(result.response);
    } else {
      throw Exception('获取收藏夹列表失败: $result');
    }
  }

  @override
  Future<void> cacheUserInfo(UserInfoEntity userInfo) async {
    // 转换为UserInfoData并缓存
    final userInfoData = UserInfoData(
      mid: userInfo.mid,
      uname: userInfo.uname,
      face: userInfo.face,
      levelInfo: userInfo.level != null
          ? LevelInfo(currentLevel: userInfo.level!)
          : null,
      vipStatus: userInfo.vipStatus,
      vipType: userInfo.vipType,
      vipDueDate: userInfo.vipDueDate,
      isLogin: userInfo.isLogin,
    );
    await _remoteDataSource.cacheUserInfo(userInfoData);
  }
}
