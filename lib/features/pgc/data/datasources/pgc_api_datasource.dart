/// PGC（专业生成内容）远程数据源
///
/// 负责所有 PGC 相关的网络请求
library;

// 忽略类型推断警告
// ignore_for_file: prefer_collection_literals, map_value_type_not_assignable

import 'package:PiliPlus/core/network/http_client.dart';
import 'package:PiliPlus/core/constants/pgc_api_constants.dart';
import 'package:PiliPlus/core/errors/error_handler.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:dio/dio.dart';

/// PGC 远程数据源
class PgcRemoteDataSource {
  final Dio _httpClient = HttpClientManager.instance;

  /// PGC 索引结果
  ///
  /// [page] 页码
  /// [params] 查询参数
  /// [seasonType] 季度类型
  /// [type] 类型
  /// [indexType] 索引类型
  Future<Map<String, dynamic>> pgcIndexResult({
    required int page,
    required Map<String, dynamic> params,
    dynamic seasonType,
    dynamic type,
    dynamic indexType,
  }) async {
    try {
      final response = await _httpClient.get(
        PgcApiConstants.pgcIndexResult,
        queryParameters: {
          ...params,
          'season_type': seasonType,
          'type': type,
          'index_type': indexType,
          'page': page,
          'pagesize': 21,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取PGC索引结果失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// PGC 索引条件
  ///
  /// [seasonType] 季度类型
  /// [type] 类型
  /// [indexType] 索引类型
  Future<Map<String, dynamic>> pgcIndexCondition({
    dynamic seasonType,
    required dynamic type,
    dynamic indexType,
  }) async {
    try {
      final response = await _httpClient.get(
        PgcApiConstants.pgcIndexCondition,
        queryParameters: {
          'season_type': seasonType,
          'type': type,
          'index_type': indexType,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取PGC索引条件失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// PGC 索引列表
  ///
  /// [page] 页码
  /// [indexType] 索引类型
  Future<List<dynamic>?> pgcIndex({
    int? page,
    int? indexType,
  }) async {
    try {
      final response = await _httpClient.get(
        PgcApiConstants.pgcIndexResult,
        queryParameters: {
          'st': 1,
          'order': 3,
          'season_version': -1,
          'spoken_language_type': -1,
          'area': -1,
          'is_finish': -1,
          'copyright': -1,
          'season_status': -1,
          'season_month': -1,
          'year': -1,
          'style_id': -1,
          'sort': 0,
          'season_type': 1,
          'pagesize': 20,
          'type': 1,
          'page': page,
          'index_type': indexType,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data']?['list'] as List<dynamic>?;
      } else {
        throw ServerException(
          response.data['message'] ?? '获取PGC索引失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// PGC 时间线
  ///
  /// [types] 类型：1-番剧，3-电影，4-国创
  /// [before] 时间戳（之前）
  /// [after] 时间戳（之后）
  Future<List<dynamic>?> pgcTimeline({
    int types = 1,
    required int before,
    required int after,
  }) async {
    try {
      final response = await _httpClient.get(
        PgcApiConstants.pgcTimeline,
        queryParameters: {
          'types': types,
          'before': before,
          'after': after,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['result'] as List<dynamic>?;
      } else {
        throw ServerException(
          response.data['message'] ?? '获取PGC时间线失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// PGC 评论列表
  ///
  /// [type] 评论类型（长评/短评）
  /// [mediaId] 媒体ID
  /// [sort] 排序方式
  /// [next] 下一页游标
  Future<Map<String, dynamic>> pgcReview({
    required String type,
    required dynamic mediaId,
    int sort = 0,
    String? next,
  }) async {
    try {
      final response = await _httpClient.get(
        type,
        queryParameters: {
          'media_id': mediaId,
          'ps': 20,
          'sort': sort,
          'cursor': next,
          'web_location': 666.19,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取PGC评论失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// PGC 评论点赞
  ///
  /// [mediaId] 媒体ID
  /// [reviewId] 评论ID
  Future<void> pgcReviewLike({
    required dynamic mediaId,
    required dynamic reviewId,
  }) async {
    try {
      final response = await _httpClient.post(
        PgcApiConstants.pgcReviewLike,
        data: {
          'media_id': mediaId,
          'review_type': 2,
          'review_id': reviewId,
          'csrf': '', // 需要从外部传入
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
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

  /// PGC 评论踩
  ///
  /// [mediaId] 媒体ID
  /// [reviewId] 评论ID
  Future<void> pgcReviewDislike({
    required dynamic mediaId,
    required dynamic reviewId,
  }) async {
    try {
      final response = await _httpClient.post(
        PgcApiConstants.pgcReviewDislike,
        data: {
          'media_id': mediaId,
          'review_type': 2,
          'review_id': reviewId,
          'csrf': '', // 需要从外部传入
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '踩失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// PGC 发布评论
  ///
  /// [mediaId] 媒体ID
  /// [score] 评分
  /// [content] 评论内容
  /// [shareFeed] 是否分享到动态
  Future<void> pgcReviewPost({
    required dynamic mediaId,
    required int score,
    required String content,
    bool shareFeed = false,
  }) async {
    try {
      final response = await _httpClient.post(
        PgcApiConstants.pgcReviewPost,
        data: {
          'media_id': mediaId,
          'score': score,
          'content': content,
          if (shareFeed) 'share_feed': 1,
          'csrf': '', // 需要从外部传入
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '发布评论失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// PGC 修改评论
  ///
  /// [mediaId] 媒体ID
  /// [score] 评分
  /// [content] 评论内容
  /// [reviewId] 评论ID
  Future<void> pgcReviewMod({
    required dynamic mediaId,
    required int score,
    required String content,
    required dynamic reviewId,
  }) async {
    try {
      final response = await _httpClient.post(
        PgcApiConstants.pgcReviewMod,
        data: {
          'media_id': mediaId,
          'score': score,
          'content': content,
          'review_id': reviewId,
          'csrf': '', // 需要从外部传入
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '修改评论失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// PGC 删除评论
  ///
  /// [mediaId] 媒体ID
  /// [reviewId] 评论ID
  Future<void> pgcReviewDel({
    required dynamic mediaId,
    required dynamic reviewId,
  }) async {
    try {
      final response = await _httpClient.post(
        PgcApiConstants.pgcReviewDel,
        data: {
          'media_id': mediaId,
          'review_id': reviewId,
          'csrf': '', // 需要从外部传入
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '删除评论失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 季度用户状态
  ///
  /// [seasonId] 季度ID
  Future<Map<String, dynamic>> seasonStatus({
    required dynamic seasonId,
  }) async {
    try {
      final response = await _httpClient.get(
        PgcApiConstants.seasonStatus,
        queryParameters: {
          'season_id': seasonId,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['result'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取季度状态失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}
