import 'package:PiliPlus/features/mine/domain/entities/fav_folder_entity.dart';
import 'package:PiliPlus/features/mine/domain/entities/user_info_entity.dart';
import 'package:PiliPlus/features/mine/domain/entities/user_stat_entity.dart';

/// 我的页面仓库接口
///
/// 定义所有我的页面相关的数据操作
abstract interface class MineRepository {
  /// 获取用户信息
  Future<UserInfoEntity> getUserInfo();

  /// 获取用户统计信息
  Future<UserStatEntity> getUserStat();

  /// 获取收藏夹列表
  ///
  /// [mid] 用户ID
  /// [pn] 页码
  /// [ps] 每页数量
  Future<FavFolderListEntity> getFavFolders({
    required String mid,
    int pn = 1,
    int ps = 20,
  });

  /// 保存用户信息到本地缓存
  Future<void> cacheUserInfo(UserInfoEntity userInfo);
}
