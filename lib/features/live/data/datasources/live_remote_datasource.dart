/// 直播远程数据源
///
/// 负责所有直播相关的网络请求
library;

// 忽略类型推断警告
// ignore_for_file: prefer_collection_literals, map_value_type_not_assignable

import 'package:PiliPlus/core/network/http_client.dart';
import 'package:PiliPlus/core/constants/live_api_constants.dart';
import 'package:PiliPlus/core/errors/error_handler.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/models/common/account_type.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:PiliPlus/utils/accounts/account.dart';
import 'package:PiliPlus/utils/app_sign.dart';
import 'package:PiliPlus/utils/wbi_sign.dart';
import 'package:dio/dio.dart';

/// 直播远程数据源
class LiveRemoteDataSource {
  final Dio _httpClient = HttpClientManager.instance;

  /// 推荐账号
  Account get _recommend => Accounts.get(AccountType.recommend);

  /// 发送直播弹幕
  Future<void> sendLiveMsg({
    required Object roomId,
    required Object msg,
    Object? dmType,
    Object? emoticonOptions,
    int replyMid = 0,
    String replayDmid = '',
  }) async {
    try {
      final csrf = Accounts.main.csrf;
      final response = await _httpClient.post(
        LiveApiConstants.sendLiveMsg,
        queryParameters: await WbiSign.makSign({
          'web_location': 444.8,
        }),
        data: FormData.fromMap({
          'bubble': 0,
          'msg': msg,
          'color': 16777215,
          'mode': 1,
          'dm_type': dmType,
          if (emoticonOptions != null)
            'emoticonOptions': emoticonOptions
          else ...{
            'room_type': 0,
            'jumpfrom': 0,
            'reply_mid': replyMid,
            'reply_attr': 0,
            'replay_dmid': replayDmid,
            'statistics': '{"appId":100,"platform":5}',
            'reply_type': 0,
            'reply_uname': '',
          },
          'fontsize': 25,
          'rnd': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          'roomid': roomId,
          'csrf': csrf,
          'csrf_token': csrf,
        }),
      );

      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '发送弹幕失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 直播间播放信息
  Future<Map<String, dynamic>> liveRoomInfo({
    required Object roomId,
    Object? qn,
    bool onlyAudio = false,
  }) async {
    try {
      final response = await _httpClient.get(
        LiveApiConstants.liveRoomInfo,
        queryParameters: await WbiSign.makSign({
          'room_id': roomId,
          'protocol': '0,1',
          'format': '0,1,2',
          'codec': '0,1,2',
          'qn': qn,
          'platform': 'web',
          'ptype': 8,
          'dolby': 5,
          'panorama': 1,
          if (onlyAudio) 'only_audio': 1,
          'web_location': 444.8,
        }),
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取直播间信息失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 直播间信息（H5）
  Future<Map<String, dynamic>> liveRoomInfoH5({
    required Object roomId,
  }) async {
    try {
      final response = await _httpClient.get(
        LiveApiConstants.liveRoomInfoH5,
        queryParameters: {
          'room_id': roomId,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取直播间信息失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 直播间弹幕预取
  Future<List<dynamic>?> liveRoomDmPrefetch({
    required Object roomId,
  }) async {
    try {
      final response = await _httpClient.get(
        LiveApiConstants.liveRoomDmPrefetch,
        queryParameters: {'roomid': roomId},
        options: Options(
          headers: {
            'referer': 'https://live.bilibili.com/$roomId',
          },
        ),
      );

      if (response.data['code'] == 0) {
        return response.data['data']?['room'] as List<dynamic>?;
      } else {
        throw ServerException(
          response.data['message'] ?? '获取弹幕历史失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 直播间弹幕 Token
  Future<Map<String, dynamic>> liveRoomGetDanmakuToken({
    required Object roomId,
  }) async {
    try {
      final response = await _httpClient.get(
        LiveApiConstants.liveRoomDmToken,
        queryParameters: await WbiSign.makSign({
          'id': roomId,
          'web_location': 444.8,
        }),
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取弹幕Token失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 获取直播间表情
  Future<Map<String, dynamic>> getLiveEmoticons({
    required int roomId,
  }) async {
    try {
      final response = await _httpClient.get(
        LiveApiConstants.getLiveEmoticons,
        queryParameters: {
          'platform': 'pc',
          'room_id': roomId,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取表情失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 直播首页推荐
  Future<Map<String, dynamic>> liveFeedIndex({
    required int pn,
    bool moduleSelect = false,
  }) async {
    try {
      final params = {
        'access_key': _recommend.accessKey,
        'channel': 'master',
        'actionKey': 'appkey',
        'build': 8430300,
        'version': '8.43.0',
        'c_locale': 'zh_CN',
        'device': 'android',
        'device_name': 'android',
        'device_type': 0,
        'fnval': 912,
        'disable_rcmd': 0,
        'https_url_req': 1,
        if (moduleSelect) 'module_select': 1,
        'mobi_app': 'android',
        'network': 'wifi',
        'page': pn,
        'platform': 'android',
        if (_recommend.isLogin) 'relation_page': 1,
        's_locale': 'zh_CN',
        'scale': 2,
        'statistics': _getStatisticsApp(),
      } as Map<String, dynamic>;
      AppSign.appSign(params);

      final response = await _httpClient.get(
        LiveApiConstants.liveFeedIndex,
        queryParameters: params,
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取直播推荐失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 关注的直播
  Future<Map<String, dynamic>> liveFollow(int page) async {
    try {
      final response = await _httpClient.get(
        LiveApiConstants.liveFollow,
        queryParameters: {
          'page': page,
          'page_size': 9,
          'ignoreRecord': 1,
          'hit_ab': true,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取关注列表失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 直播分区列表
  Future<Map<String, dynamic>?> liveAreaList() async {
    try {
      final params = {
        'access_key': _recommend.accessKey,
        'actionKey': 'appkey',
        'build': 8430300,
        'channel': 'master',
        'version': '8.43.0',
        'c_locale': 'zh_CN',
        'device': 'android',
        'disable_rcmd': 0,
        'mobi_app': 'android',
        'platform': 'android',
        's_locale': 'zh_CN',
        'statistics': _getStatisticsApp(),
      } as Map<String, dynamic>;
      AppSign.appSign(params);

      final response = await _httpClient.get(
        LiveApiConstants.liveAreaList,
        queryParameters: params,
      );

      if (response.data['code'] == 0) {
        return response.data['data'] as Map<String, dynamic>?;
      } else {
        throw ServerException(
          response.data['message'] ?? '获取分区列表失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 直播搜索
  Future<Map<String, dynamic>> liveSearch({
    required int page,
    required String keyword,
    required String type,
  }) async {
    try {
      final params = {
        'access_key': _recommend.accessKey,
        'actionKey': 'appkey',
        'build': 8430300,
        'channel': 'master',
        'version': '8.43.0',
        'c_locale': 'zh_CN',
        'device': 'android',
        'page': page,
        'pagesize': 30,
        'keyword': keyword,
        'disable_rcmd': 0,
        'mobi_app': 'android',
        'platform': 'android',
        's_locale': 'zh_CN',
        'statistics': _getStatisticsApp(),
        'type': type,
      } as Map<String, dynamic>;
      AppSign.appSign(params);

      final response = await _httpClient.get(
        LiveApiConstants.liveSearch,
        queryParameters: params,
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '直播搜索失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 直播静音设置
  Future<void> liveSetSilent({
    required String type,
    required int level,
  }) async {
    try {
      final csrf = Accounts.main.csrf;
      final response = await _httpClient.post(
        LiveApiConstants.liveSetSilent,
        data: {
          'type': type,
          'level': level,
          'csrf': csrf,
          'csrf_token': csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '设置静音失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 添加屏蔽关键词
  Future<void> addShieldKeyword({
    required String keyword,
  }) async {
    try {
      final csrf = Accounts.main.csrf;
      final response = await _httpClient.post(
        LiveApiConstants.addShieldKeyword,
        data: {
          'keyword': keyword,
          'csrf': csrf,
          'csrf_token': csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '添加屏蔽关键词失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 删除屏蔽关键词
  Future<void> delShieldKeyword({
    required String keyword,
  }) async {
    try {
      final csrf = Accounts.main.csrf;
      final response = await _httpClient.post(
        LiveApiConstants.delShieldKeyword,
        data: {
          'keyword': keyword,
          'csrf': csrf,
          'csrf_token': csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '删除屏蔽关键词失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 直播屏蔽用户
  Future<Map<String, dynamic>> liveShieldUser({
    required Object uid,
    required Object roomid,
    required int type,
  }) async {
    try {
      final csrf = Accounts.main.csrf;
      final response = await _httpClient.post(
        LiveApiConstants.liveShieldUser,
        data: {
          'uid': uid,
          'roomid': roomid,
          'type': type,
          'csrf': csrf,
          'csrf_token': csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '屏蔽用户失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 超级聊天消息列表
  Future<Map<String, dynamic>> superChatMsg(
    Object roomId,
  ) async {
    try {
      final response = await _httpClient.get(
        LiveApiConstants.superChatMsg,
        queryParameters: {
          'room_id': roomId,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取超级聊天失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 辅助方法：获取统计信息
  String _getStatisticsApp() {
    // 简化的实现，实际应该返回更复杂的统计信息
    return '{"appId":1,"platform":3,"version":"8.43.0","abtest":""}';
  }
}
