/// 视频远程数据源
///
/// 负责所有视频相关的网络请求
library;

// 忽略类型推断警告
// ignore_for_file: prefer_collection_literals, map_value_type_not_assignable

import 'package:PiliPlus/core/network/http_client.dart';
import 'package:PiliPlus/core/constants/video_api_constants.dart';
import 'package:PiliPlus/core/errors/error_handler.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/models/common/account_type.dart';
import 'package:PiliPlus/models/video/video_play_info/data.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:PiliPlus/utils/app_sign.dart';
import 'package:PiliPlus/utils/global_data.dart';
import 'package:PiliPlus/utils/id_utils.dart';
import 'package:PiliPlus/utils/recommend_filter.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/utils/wbi_sign.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show compute;

/// 视频远程数据源
class VideoRemoteDataSource {
  final Dio _httpClient = HttpClientManager.instance;

  static RegExp zoneRegExp = RegExp(Pref.banWordForZone, caseSensitive: false);
  static bool enableFilter = zoneRegExp.pattern.isNotEmpty;

  /// 首页推荐视频
  Future<Map<String, dynamic>> rcmdVideoList({
    required int ps,
    required int freshIdx,
  }) async {
    try {
      final response = await _httpClient.get(
        VideoApiConstants.recommendListWeb,
        queryParameters: await WbiSign.makSign({
          'version': 1,
          'feed_version': 'V8',
          'homepage_ver': 1,
          'ps': ps,
          'fresh_idx': freshIdx,
          'brush': freshIdx,
          'fresh_type': 4,
        }),
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取推荐视频失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 视频详情
  Future<Map<String, dynamic>> videoInfo({
    String? bvid,
    int? aid,
  }) async {
    try {
      final response = await _httpClient.get(
        VideoApiConstants.videoIntro,
        queryParameters: {
          if (bvid != null) 'bvid': bvid,
          if (aid != null) 'aid': aid,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取视频详情失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 视频播放URL
  Future<Map<String, dynamic>> videoPlayUrl({
    required int cid,
    required int qn,
    int? fnval,
    int? fnver,
    bool fourk = false,
    String? bvid,
    int? aid,
    String? session,
  }) async {
    try {
      final params = {
        'cid': cid,
        'qn': qn,
        'fnval': fnval ?? 16,
        'fnver': fnver ?? 0,
        'fourk': fourk ? 1 : 0,
        'session': session,
      };

      // WBI签名
      final baseParams = <String, Object?>{
        'cid': cid,
        'qn': qn,
        'fnval': fnval ?? 16,
        'fnver': fnver ?? 0,
        'fourk': fourk ? 1 : 0,
        'session': session,
      };
      if (bvid != null) baseParams['bvid'] = bvid;
      if (aid != null) baseParams['aid'] = aid;

      final signedParams = await WbiSign.makSign(
        baseParams.cast<String, Object>(),
      );

      // 转换为动态Map以避免类型问题
      final queryParams = signedParams as Map<String, dynamic>;

      final response = await _httpClient.get(
        VideoApiConstants.ugcUrl,
        queryParameters: queryParams,
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取播放地址失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 点赞视频
  Future<void> likeVideo({
    required String bvid,
    required bool like,
  }) async {
    try {
      final response = await _httpClient.post(
        VideoApiConstants.likeVideo,
        data:
            {
                  'bvid': bvid,
                  'like': like ? 1 : 2,
                }
                as Map<String, dynamic>,
      );

      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '点赞失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 投币视频
  Future<void> coinVideo({
    required String bvid,
    required int num,
    bool selectLike = false,
  }) async {
    try {
      final response = await _httpClient.post(
        VideoApiConstants.coinVideo,
        data: {
          'bvid': bvid,
          'multiply': num,
          'select_like': selectLike ? 1 : 0,
        },
      );

      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '投币失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 收藏视频
  Future<void> favVideo({
    required String bvid,
    required List<int> addMediaIds,
    required List<int> delMediaIds,
  }) async {
    try {
      final response = await _httpClient.post(
        VideoApiConstants.favVideo,
        data: {
          'rid': IdUtils.bv2av(bvid),
          'type': 2,
          'add_media_ids': addMediaIds,
          'del_media_ids': delMediaIds,
        },
      );

      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '收藏失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 一键三连
  Future<Map<String, dynamic>> ugcTriple({
    required String bvid,
  }) async {
    try {
      final response = await _httpClient.post(
        VideoApiConstants.ugcTriple,
        queryParameters: {
          'bvid': bvid,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '操作失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 视频关系（点赞、投币、收藏状态）
  Future<Map<String, dynamic>> videoRelation({
    required String bvid,
  }) async {
    try {
      final response = await _httpClient.get(
        VideoApiConstants.videoRelation,
        queryParameters: {
          'bvid': bvid,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取视频关系失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 相关视频
  Future<List<dynamic>> relatedVideos({
    required String bvid,
  }) async {
    try {
      final response = await _httpClient.get(
        VideoApiConstants.relatedList,
        queryParameters: {
          'bvid': bvid,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取相关视频失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 发送弹幕
  Future<void> sendDanmaku({
    required String msg,
    required int oid,
    required int progress,
    required int type,
    int? color,
  }) async {
    try {
      final response = await _httpClient.post(
        VideoApiConstants.shootDanmaku,
        data: {
          'type': type,
          'oid': oid,
          'msg': msg,
          'progress': progress,
          'color': color ?? 16777215,
        },
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

  /// AI 总结
  Future<Map<String, dynamic>> aiConclusion({
    required String bvid,
    required int cid,
    int? upMid,
  }) async {
    try {
      final params = <String, Object?>{
        'bvid': bvid,
        'cid': cid,
      };
      if (upMid != null) params['up_mid'] = upMid.toString();

      final signedParams = await WbiSign.makSign(params.cast<String, Object>());

      // 转换为动态Map
      final queryParams = signedParams as Map<String, dynamic>;

      final response = await _httpClient.get(
        VideoApiConstants.aiConclusion,
        queryParameters: queryParams,
      );

      if (response.data['code'] == 0) {
        final int? dataCode = response.data['data']?['code'];
        if (dataCode == 0) {
          return response.data['data'];
        } else {
          throw ServerException(
            'AI总结失败',
            code: dataCode,
          );
        }
      } else {
        throw ServerException(
          response.data['message'] ?? '获取AI总结失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 播放信息
  Future<Map<String, dynamic>> playInfo({
    String? aid,
    String? bvid,
    required int cid,
    int? seasonId,
    int? epId,
  }) async {
    try {
      final response = await _httpClient.get(
        VideoApiConstants.playInfo,
        queryParameters: await WbiSign.makSign({
          if (aid != null) 'aid': aid,
          if (bvid != null) 'bvid': bvid,
          'cid': cid,
          if (seasonId != null) 'season_id': seasonId,
          if (epId != null) 'ep_id': epId,
        }),
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取播放信息失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 视频排行榜
  Future<List<dynamic>> getRankVideoList(int rid) async {
    try {
      final response = await _httpClient.get(
        VideoApiConstants.hotList,
        queryParameters: await WbiSign.makSign({
          'rid': rid,
          'type': 'all',
        }),
      );

      if (response.data['code'] == 0) {
        return response.data['data']['list'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取排行榜失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// PGC 排行
  Future<List<dynamic>?> pgcRankList({
    int day = 3,
    required int seasonType,
  }) async {
    try {
      final response = await _httpClient.get(
        VideoApiConstants.pgcRank,
        queryParameters: await WbiSign.makSign({
          'day': day,
          'season_type': seasonType,
        }),
      );

      if (response.data['code'] == 0) {
        return response.data['result']?['list'] as List<dynamic>?;
      } else {
        throw ServerException(
          response.data['message'] ?? '获取PGC排行失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 视频笔记列表
  Future<Map<String, dynamic>> getVideoNoteList({
    dynamic oid,
    dynamic uperMid,
    required int page,
  }) async {
    try {
      final response = await _httpClient.get(
        VideoApiConstants.archiveNoteList,
        queryParameters: {
          'csrf': Accounts.main.csrf,
          'oid': oid,
          'oid_type': 0,
          'pn': page,
          'ps': 10,
          'uper_mid': uperMid,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取笔记列表失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 热门合集列表
  Future<List<dynamic>?> popularSeriesList() async {
    try {
      final response = await _httpClient.get(
        VideoApiConstants.popularSeriesList,
        queryParameters: await WbiSign.makSign({
          'web_location': 333.934,
        }),
      );

      if (response.data['code'] == 0) {
        return response.data['data']?['list'] as List<dynamic>?;
      } else {
        throw ServerException(
          response.data['message'] ?? '获取热门合集失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 热门合集详情
  Future<Map<String, dynamic>> popularSeriesOne({
    required int number,
  }) async {
    try {
      final response = await _httpClient.get(
        VideoApiConstants.popularSeriesOne,
        queryParameters: await WbiSign.makSign({
          'number': number,
          'web_location': 333.934,
        }),
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取合集详情失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 热门视频
  Future<Map<String, dynamic>> popularPrecious({
    required int page,
  }) async {
    try {
      final response = await _httpClient.get(
        VideoApiConstants.popularPrecious,
        queryParameters: await WbiSign.makSign({
          'page_size': 100,
          'page': page,
          'web_location': 333.934,
        }),
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取热门视频失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 电视播放URL
  Future<Map<String, dynamic>> tvPlayUrl({
    required int cid,
    required int objectId,
    required int playurlType,
    int? qn,
  }) async {
    try {
      final accessKey = Accounts.get(AccountType.video).accessKey;
      final params = {
        'access_key': accessKey,
        'actionKey': 'appkey',
        'cid': cid,
        'fourk': 1,
        'is_proj': 1,
        'mobile_access_key': accessKey,
        'object_id': objectId,
        'mobi_app': 'android',
        'platform': 'android',
        'playurl_type': playurlType,
        'protocol': 0,
        'qn': qn ?? 80,
      };
      AppSign.appSign(params);

      final response = await _httpClient.get(
        VideoApiConstants.tvPlayUrl,
        queryParameters: params,
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取播放地址失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  // 辅助方法：处理字幕时间码
  static String _subtitleTimecode(num seconds) {
    int h = seconds ~/ 3600;
    seconds %= 3600;
    int m = seconds ~/ 60;
    seconds %= 60;
    String sms = seconds.toStringAsFixed(3).padLeft(6, '0');
    return h == 0
        ? "${m.toString().padLeft(2, '0')}:$sms"
        : "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:$sms";
  }

  // 辅助方法：处理字幕列表
  static String processList(List list) {
    final sb = StringBuffer('WEBVTT\n\n')
      ..writeAll(
        list.map(
          (item) =>
              '${item?['sid'] ?? 0}\n${_subtitleTimecode(item['from'])} --> ${_subtitleTimecode(item['to'])}\n${item['content'].trim()}',
        ),
        '\n\n',
      );
    return sb.toString();
  }

  /// 获取VTT字幕
  Future<String?> vttSubtitles(String subtitleUrl) async {
    try {
      final response = await _httpClient.get("https:$subtitleUrl");

      if (response.data?['body'] case List list) {
        return compute<List, String>(processList, list);
      }
      return null;
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}
