/// 我的页面远程数据源
///
/// 负责所有我的页面相关的网络请求
library;

import 'dart:convert';

import 'package:PiliPlus/models/fav/fav_folder/data.dart';
import 'package:PiliPlus/models/user/info.dart';
import 'package:PiliPlus/models/user/stat.dart';
import 'package:PiliPlus/core/storage/storage.dart';

/// 我的页面远程数据源
class MineRemoteDataSource {
  /// 获取用户信息
  Future<UserInfoData> getUserInfo() async {
    // 这里使用现有的HTTP请求方法
    // 实际实现中应该直接使用Dio进行请求
    throw UnimplementedError('请使用UserHttp.userInfo()');
  }

  /// 获取用户统计信息
  Future<UserStat> getUserStat() async {
    throw UnimplementedError('请使用UserHttp.userStatOwner()');
  }

  /// 获取收藏夹列表
  Future<FavFolderData> getFavFolders({
    required String mid,
    int pn = 1,
    int ps = 20,
  }) async {
    throw UnimplementedError('请使用FavHttp.userfavFolder()');
  }

  /// 保存用户信息到本地缓存
  Future<void> cacheUserInfo(UserInfoData userInfo) async {
    await GStorage.userInfoRepository.set('userInfoCache', userInfo);
  }

  /// 从本地缓存获取用户信息
  Future<UserInfoData?> getCachedUserInfo() async {
    return GStorage.userInfoRepository.get('userInfoCache');
  }
}
