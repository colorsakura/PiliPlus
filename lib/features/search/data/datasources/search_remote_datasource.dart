/// 搜索远程数据源
///
/// 负责所有搜索相关的网络请求
library;

// 忽略类型推断警告
// ignore_for_file: prefer_collection_literals, map_value_type_not_assignable

import 'dart:convert';

import 'package:PiliPlus/core/network/http_client.dart';
import 'package:PiliPlus/core/constants/search_api_constants.dart';
import 'package:PiliPlus/core/errors/error_handler.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/utils/wbi_sign.dart';
import 'package:dio/dio.dart';

/// 搜索远程数据源
class SearchRemoteDataSource {
  final Dio _httpClient = HttpClientManager.instance;

  /// 获取搜索建议
  Future<Map<String, dynamic>?> searchSuggest({
    required String term,
  }) async {
    try {
      final response = await _httpClient.get(
        SearchApiConstants.searchSuggest,
        queryParameters: {
          'term': term,
          'main_ver': 'v1',
          'highlight': term,
        },
      );

      if (response.data is String) {
        final Map<String, dynamic> resultMap = json.decode(response.data);
        if (resultMap['code'] == 0 && resultMap['result'] is Map) {
          return resultMap['result'];
        }
      }
      return null;
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 分类搜索
  ///
  /// [searchType] 搜索类型 (video, live_room, bili_user, media_bangumi, article等)
  /// [keyword] 搜索关键词
  /// [page] 页码
  /// [order] 排序方式
  /// [duration] 时长筛选
  /// [tids] 分区ID
  /// [orderSort] 排序类型
  /// [userType] 用户类型
  /// [categoryId] 分类ID
  /// [pubBegin] 发布开始时间
  /// [pubEnd] 发布结束时间
  /// [gaiaVtoken] 验证token
  Future<Map<String, dynamic>> searchByType({
    required String searchType,
    required String keyword,
    required int page,
    String? order,
    int? duration,
    int? tids,
    int? orderSort,
    int? userType,
    int? categoryId,
    int? pubBegin,
    int? pubEnd,
    String? gaiaVtoken,
  }) async {
    try {
      final params = await WbiSign.makSign({
        'search_type': searchType,
        'keyword': keyword,
        'page': page,
        if (order != null && order.isNotEmpty) 'order': order,
        'duration': duration,
        'tids': tids,
        'order_sort': orderSort,
        'user_type': userType,
        'category_id': categoryId,
        'pubtime_begin_s': pubBegin,
        'pubtime_end_s': pubEnd,
        'page_size': 20,
        'platform': 'pc',
        'web_location': 1430654,
        'gaia_vtoken': gaiaVtoken,
      });

      final response = await _httpClient.get(
        SearchApiConstants.searchByType,
        queryParameters: params,
        options: Options(
          headers: {
            if (gaiaVtoken != null) 'cookie': 'x-bili-gaia-vtoken=$gaiaVtoken',
            'origin': 'https://search.bilibili.com',
            'referer':
                'https://search.bilibili.com/$searchType?keyword=${Uri.encodeFull(keyword)}',
          },
        ),
      );

      if (response.data is Map) {
        if (response.data['code'] == 0) {
          return response.data['data'];
        } else {
          throw ServerException(
            response.data['message'] ?? '搜索失败',
            code: response.data['code'],
          );
        }
      }
      throw ServerException('服务器错误');
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 综合搜索
  ///
  /// [keyword] 搜索关键词
  /// [page] 页码
  /// [order] 排序方式
  /// [duration] 时长筛选
  /// [tids] 分区ID
  /// [orderSort] 排序类型
  /// [userType] 用户类型
  /// [categoryId] 分类ID
  /// [pubBegin] 发布开始时间
  /// [pubEnd] 发布结束时间
  Future<Map<String, dynamic>> searchAll({
    required String keyword,
    required int page,
    String? order,
    int? duration,
    int? tids,
    int? orderSort,
    int? userType,
    int? categoryId,
    int? pubBegin,
    int? pubEnd,
  }) async {
    try {
      final params = await WbiSign.makSign({
        'keyword': keyword,
        'page': page,
        if (order != null && order.isNotEmpty) 'order': order,
        'duration': duration,
        'tids': tids,
        'order_sort': orderSort,
        'user_type': userType,
        'category_id': categoryId,
        'pubtime_begin_s': pubBegin,
        'pubtime_end_s': pubEnd,
      });

      final response = await _httpClient.get(
        SearchApiConstants.searchAll,
        queryParameters: params,
      );

      if (response.data is Map && response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '搜索失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// AV号/BV号转CID
  ///
  /// [aid] 视频AV号
  /// [bvid] 视频BV号
  /// [part] 分P序号（从1开始）
  Future<int?> ab2c({
    dynamic aid,
    dynamic bvid,
    int? part,
  }) async {
    try {
      final response = await _httpClient.get(
        SearchApiConstants.ab2c,
        queryParameters: {
          'aid': aid,
          'bvid': bvid,
        },
      );

      if (response.data['code'] == 0) {
        if (response.data['data'] case List list) {
          return part != null
              ? (list.elementAtOrNull(part - 1)?['cid'] ??
                    list.firstOrNull?['cid'])
              : list.firstOrNull?['cid'];
        }
      }
      return null;
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 番剧信息
  ///
  /// [seasonId] 季度ID
  /// [epId] 剧集ID
  Future<Map<String, dynamic>> pgcInfo({
    dynamic seasonId,
    dynamic epId,
  }) async {
    try {
      final response = await _httpClient.get(
        SearchApiConstants.pgcInfo,
        queryParameters: {
          'season_id': seasonId,
          'ep_id': epId,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['result'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取番剧信息失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 课程信息
  ///
  /// [seasonId] 季度ID
  /// [epId] 剧集ID
  Future<Map<String, dynamic>> pugvInfo({
    dynamic seasonId,
    dynamic epId,
  }) async {
    try {
      final response = await _httpClient.get(
        SearchApiConstants.pugvInfo,
        queryParameters: {
          'season_id': seasonId,
          'ep_id': epId,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取课程信息失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 搜索热搜榜
  ///
  /// [limit] 返回数量，默认30
  Future<Map<String, dynamic>> searchTrending({
    int limit = 30,
  }) async {
    try {
      final response = await _httpClient.get(
        SearchApiConstants.searchTrending,
        queryParameters: {
          'limit': limit,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取热搜榜失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 搜索推荐
  Future<Map<String, dynamic>> searchRecommend() async {
    try {
      final response = await _httpClient.get(
        SearchApiConstants.searchRecommend,
        queryParameters: {
          'build': 8430300,
          'channel': 'master',
          'version': '8.43.0',
          'c_locale': 'zh_CN',
          'mobi_app': 'android',
          'platform': 'android',
          's_locale': 'zh_CN',
          'from': 2,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取搜索推荐失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 话题发布搜索
  ///
  /// [keywords] 关键词
  /// [content] 内容
  /// [pageNum] 页码
  Future<Map<String, dynamic>> topicPubSearch({
    required String keywords,
    String content = '',
    required int pageNum,
  }) async {
    try {
      final queryParams = {
        'keywords': keywords,
        'content': content,
        if (pageNum == 1) ...{
          'page_size': 20,
          'page_num': 1,
        } else
          'offset': 20 * (pageNum - 1),
        'web_location': 333.1365,
      };

      final response = await _httpClient.get(
        SearchApiConstants.topicPubSearch,
        queryParameters: queryParams,
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '话题搜索失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}
