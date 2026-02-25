/// 用户远程数据源
///
/// 负责所有用户相关的网络请求
library;

// 忽略类型推断警告
// ignore_for_file: prefer_collection_literals, map_value_type_not_assignable

import 'dart:convert';

import 'package:PiliPlus/core/network/http_client.dart';
import 'package:PiliPlus/core/constants/user_api_constants.dart';
import 'package:PiliPlus/core/errors/error_handler.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/models/user/info.dart';
import 'package:PiliPlus/models/user/stat.dart';
import 'package:PiliPlus/models/coin_log/data.dart';
import 'package:PiliPlus/models/follow/data.dart';
import 'package:PiliPlus/models/history/data.dart';
import 'package:PiliPlus/models/later/data.dart';
import 'package:PiliPlus/models/login_log/data.dart';
import 'package:PiliPlus/models/media_list/data.dart';
import 'package:PiliPlus/models/space_setting/data.dart';
import 'package:PiliPlus/models/sub/sub/data.dart';
import 'package:PiliPlus/models/user_real_name/data.dart';
import 'package:PiliPlus/models/video/video_tag/data.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:PiliPlus/utils/accounts/account.dart';
import 'package:PiliPlus/utils/app_sign.dart';
import 'package:PiliPlus/utils/global_data.dart';
import 'package:PiliPlus/utils/wbi_sign.dart';
import 'package:dio/dio.dart';

/// 用户远程数据源
class UserRemoteDataSource {
  final Dio _httpClient = HttpClientManager.instance;

  /// 获取用户导航信息
  Future<UserInfoData> userInfo() async {
    try {
      final response = await _httpClient.get(UserApiConstants.userInfo);
      if (response.data['code'] == 0) {
        final data = UserInfoData.fromJson(response.data['data']);
        GlobalData().coins = data.money;
        return data;
      } else {
        throw ServerException(
          response.data['message'] ?? '获取用户信息失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 获取用户统计数据（所有者）
  Future<UserStat> userStatOwner() async {
    try {
      final response = await _httpClient.get(UserApiConstants.userStatOwner);
      if (response.data['code'] == 0) {
        return UserStat.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取用户统计失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 稍后再看列表
  ///
  /// [page] 页码
  /// [viewed] 查看状态：0-未查看，1-已查看
  /// [keyword] 搜索关键词
  /// [asc] 是否升序
  Future<LaterData> seeYouLater({
    required int page,
    int viewed = 0,
    String keyword = '',
    bool asc = false,
  }) async {
    try {
      final response = await _httpClient.get(
        UserApiConstants.seeYouLater,
        queryParameters: await WbiSign.makSign({
          'pn': page,
          'ps': 20,
          'viewed': viewed,
          'key': keyword,
          'asc': asc,
          'need_split': true,
          'web_location': 333.881,
        }),
      );
      if (response.data['code'] == 0) {
        return LaterData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取稍后再看列表失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 观看历史列表
  ///
  /// [type] 历史类型：archive-视频，live-直播，article-文章
  /// [max] 最大ID
  /// [viewAt] 查看时间戳
  /// [account] 账号
  Future<HistoryData> historyList({
    required String type,
    int? max,
    int? viewAt,
    Account? account,
  }) async {
    try {
      final response = await _httpClient.get(
        UserApiConstants.historyList,
        queryParameters: {
          'type': type,
          'ps': 20,
          'max': max ?? 0,
          'view_at': viewAt ?? 0,
        },
      );
      if (response.data['code'] == 0) {
        return HistoryData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取观看历史失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 暂停观看历史
  ///
  /// [switchStatus] true-暂停，false-恢复
  /// [account] 账号
  Future<void> pauseHistory(
    bool switchStatus, {
    Account? account,
  }) async {
    try {
      final acc = account ?? Accounts.history;
      final response = await _httpClient.post(
        UserApiConstants.pauseHistory,
        data: {
          'switch': switchStatus,
          'jsonp': 'jsonp',
          'csrf': acc.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '暂停观看历史失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 观看历史暂停状态
  ///
  /// [account] 账号
  /// 返回 true-已暂停，false-未暂停
  Future<bool> historyStatus({Account? account}) async {
    try {
      final response = await _httpClient.get(UserApiConstants.historyStatus);
      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取历史状态失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 清空观看历史
  ///
  /// [account] 账号
  Future<void> clearHistory({Account? account}) async {
    try {
      final acc = account ?? Accounts.history;
      final response = await _httpClient.post(
        UserApiConstants.clearHistory,
        data: {
          'jsonp': 'jsonp',
          'csrf': acc.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '清空观看历史失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 添加到稍后再看
  ///
  /// [bvid] 视频BVID
  /// [aid] 视频AID
  Future<void> toViewLater({
    String? bvid,
    Object? aid,
  }) async {
    try {
      final response = await _httpClient.post(
        UserApiConstants.toViewLater,
        data: {
          'aid': aid,
          'bvid': bvid,
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '添加到稍后再看失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 从稍后再看删除
  ///
  /// [aids] 视频ID列表（逗号分隔）
  Future<void> toViewDel({required String aids}) async {
    try {
      final response = await _httpClient.post(
        UserApiConstants.toViewDel,
        data: {
          'csrf': Accounts.main.csrf,
          'resources': aids,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '从稍后再看删除失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 清空稍后再看
  ///
  /// [cleanType] 清空类型：null-全部，1-失效，2-已查看
  Future<void> toViewClear([int? cleanType]) async {
    try {
      final response = await _httpClient.post(
        UserApiConstants.toViewClear,
        data: {
          'clean_type': cleanType,
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '清空稍后再看失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 删除观看历史
  ///
  /// [kid] 历史记录ID
  /// [account] 账号
  Future<void> delHistory(
    String kid, {
    Account? account,
  }) async {
    try {
      final acc = account ?? Accounts.history;
      final response = await _httpClient.post(
        UserApiConstants.delHistory,
        data: {
          'kid': kid,
          'jsonp': 'jsonp',
          'csrf': acc.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '删除观看历史失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 检查是否关注
  ///
  /// [mid] 用户ID
  Future<Map<String, dynamic>> hasFollow(int mid) async {
    try {
      final response = await _httpClient.get(
        UserApiConstants.relation,
        queryParameters: {
          'fid': mid,
        },
      );
      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '检查关注状态失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 搜索观看历史
  ///
  /// [pn] 页码
  /// [keyword] 搜索关键词
  /// [account] 账号
  Future<HistoryData> searchHistory({
    required int pn,
    required String keyword,
    Account? account,
  }) async {
    try {
      final response = await _httpClient.get(
        UserApiConstants.searchHistory,
        queryParameters: {
          'pn': pn,
          'keyword': keyword,
          'business': 'all',
        },
      );
      if (response.data['code'] == 0) {
        return HistoryData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '搜索观看历史失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 我的订阅
  ///
  /// [mid] UP主ID
  /// [pn] 页码
  /// [ps] 每页数量
  Future<SubData> userSubFolder({
    required int mid,
    required int pn,
    required int ps,
  }) async {
    try {
      final response = await _httpClient.get(
        UserApiConstants.userSubFolder,
        queryParameters: {
          'up_mid': mid,
          'ps': ps,
          'pn': pn,
          'platform': 'web',
        },
      );
      if (response.data['code'] == 0 && response.data['data'] is Map) {
        return SubData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取订阅列表失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 视频标签
  ///
  /// [bvid] 视频BVID
  /// [cid] 视频CID
  Future<List<VideoTagItem>?> videoTags({
    required String bvid,
    Object? cid,
  }) async {
    try {
      final response = await _httpClient.get(
        UserApiConstants.videoTags,
        queryParameters: {'bvid': bvid, 'cid': cid},
      );
      if (response.data['code'] == 0) {
        return (response.data['data'] as List?)
            ?.map((e) => VideoTagItem.fromJson(e))
            .toList();
      } else {
        throw ServerException(
          response.data['message'] ?? '获取视频标签失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 媒体列表
  ///
  /// [type] 类型
  /// [bizId] 业务ID
  /// [ps] 每页数量
  /// [oid] 对象ID
  /// [otype] 对象类型
  /// [withCurrent] 是否包含当前
  /// [desc] 是否降序
  /// [sortField] 排序字段
  /// [direction] 排序方向
  Future<MediaListData> getMediaList({
    required Object type,
    required Object bizId,
    required int ps,
    dynamic oid,
    int? otype,
    bool withCurrent = false,
    bool desc = true,
    dynamic sortField = 1,
    bool direction = false,
  }) async {
    try {
      final response = await _httpClient.get(
        UserApiConstants.mediaList,
        queryParameters: {
          'mobi_app': 'web',
          'type': type,
          'biz_id': bizId,
          'oid': oid,
          'otype': otype,
          'ps': ps,
          'direction': direction,
          'desc': desc,
          'sort_field': sortField,
          'tid': 0,
          'with_current': withCurrent,
        },
      );
      if (response.data['code'] == 0) {
        return MediaListData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取媒体列表失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 获取硬币数量
  Future<num?> getCoin() async {
    try {
      final response = await _httpClient.get(UserApiConstants.getCoin);
      if (response.data['code'] == 0) {
        return response.data['data']?['money'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取硬币数量失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 动态举报
  ///
  /// [mid] UP主ID
  /// [dynId] 动态ID
  /// [reasonType] 举报原因类型：0-其他
  /// [reasonDesc] 举报原因描述
  Future<void> dynamicReport({
    required Object mid,
    required Object dynId,
    required int reasonType,
    String? reasonDesc,
  }) async {
    try {
      final response = await _httpClient.post(
        UserApiConstants.dynamicReport,
        queryParameters: {
          'csrf': Accounts.main.csrf,
        },
        data: {
          "accused_uid": mid,
          "dynamic_id": dynId,
          "reason_type": reasonType,
          "reason_desc": reasonType == 0 ? reasonDesc : null,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '动态举报失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 空间设置
  Future<SpaceSettingData> spaceSetting() async {
    try {
      final response = await _httpClient.get(
        UserApiConstants.spaceSetting,
        queryParameters: {
          'mid': Accounts.main.mid,
        },
      );
      if (response.data['code'] == 0) {
        return SpaceSettingData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取空间设置失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 修改空间设置
  ///
  /// [data] 设置数据
  Future<void> spaceSettingMod(Map<String, dynamic> data) async {
    try {
      final response = await _httpClient.post(
        UserApiConstants.spaceSettingMod,
        queryParameters: {
          'csrf': Accounts.main.csrf,
        },
        data: data,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '修改空间设置失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// VIP经验增加
  Future<void> vipExpAdd() async {
    try {
      final response = await _httpClient.post(
        UserApiConstants.vipExpAdd,
        queryParameters: {
          'mid': Accounts.main.mid,
          'csrf': Accounts.main.csrf,
        },
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? 'VIP经验增加失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 硬币日志
  Future<CoinLogData> coinLog() async {
    try {
      final response = await _httpClient.get(
        UserApiConstants.coinLog,
        queryParameters: {
          'jsonp': 'jsonp',
          'web_location': '333.33',
        },
      );
      if (response.data['code'] == 0) {
        return CoinLogData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取硬币日志失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 登录日志
  Future<LoginLogData> loginLog() async {
    try {
      final response = await _httpClient.get(
        UserApiConstants.loginLog,
        queryParameters: {
          'jsonp': 'jsonp',
          'web_location': '333.33',
        },
      );
      if (response.data['code'] == 0) {
        return LoginLogData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取登录日志失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 经验日志
  Future<CoinLogData> expLog() async {
    try {
      final response = await _httpClient.get(
        UserApiConstants.expLog,
        queryParameters: {
          'jsonp': 'jsonp',
          'web_location': '333.33',
        },
      );
      if (response.data['code'] == 0) {
        return CoinLogData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取经验日志失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// UP主实名信息
  ///
  /// [mid] UP主ID
  Future<UserRealNameData> getUserRealName(Object mid) async {
    try {
      final params = {
        'access_key': Accounts.main.accessKey,
        'up_mid': mid,
      };
      AppSign.appSign(params);
      final response = await _httpClient.get(
        UserApiConstants.userRealName,
        queryParameters: params,
      );
      if (response.data['code'] == 0) {
        return UserRealNameData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取UP主实名信息失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 关注的UP主
  ///
  /// [mid] UP主ID
  /// [pn] 页码
  Future<FollowData> followedUp({
    required Object mid,
    required int pn,
  }) async {
    try {
      final response = await _httpClient.get(
        UserApiConstants.followedUp,
        queryParameters: {
          'csrf': Accounts.main.csrf,
          'pn': pn,
          'vmid': mid,
          'web_location': 333.789,
          'x-bili-device-req-json':
              '{"platform":"web","device":"pc","spmid":"333.789"}',
        },
      );
      if (response.data['code'] == 0) {
        return FollowData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取关注的UP主失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 共同关注
  ///
  /// [mid] 用户ID
  /// [pn] 页码
  Future<FollowData> sameFollowing({
    required Object mid,
    int? pn,
  }) async {
    try {
      final response = await _httpClient.get(
        UserApiConstants.sameFollowing,
        queryParameters: {
          'csrf': Accounts.main.csrf,
          'pn': pn,
          'vmid': mid,
          'web_location': 333.789,
          'x-bili-device-req-json':
              '{"platform":"web","device":"pc","spmid":"333.789"}',
        },
      );
      if (response.data['code'] == 0) {
        return FollowData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取共同关注失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 修改用户关系（关注/取关/拉黑/移除黑名单等）
  ///
  /// [mid] 用户ID
  /// [act] 操作类型：2-关注，3-取关，5-拉黑，6-移除黑名单
  /// [reSrc] 操作来源：通常为11
  Future<void> relationMod({
    required int mid,
    required int act,
    required int reSrc,
  }) async {
    try {
      final response = await _httpClient.post(
        UserApiConstants.relationMod,
        queryParameters: {
          'statistics': '{"appId":100,"platform":5}',
          'x-bili-device-req-json':
              '{"platform":"web","device":"pc","spmid":"333.1387"}',
        },
        data: {
          'fid': mid,
          'act': act,
          're_src': reSrc,
          'gaia_source': 'web_main',
          'spmid': '333.1387',
          'extend_content':
              jsonEncode({
                "entity": "user",
                "entity_id": mid,
                'fp': 'pc',
              }),
          'csrf': Accounts.main.csrf,
        },
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '操作失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}
