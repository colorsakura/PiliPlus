/// 评论远程数据源
///
/// 负责所有评论相关的网络请求
library;

// 忽略类型推断警告
// ignore_for_file: prefer_collection_literals, map_value_type_not_assignable

import 'package:PiliPlus/core/network/http_client.dart';
import 'package:PiliPlus/core/constants/reply_api_constants.dart';
import 'package:PiliPlus/core/errors/error_handler.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:dio/dio.dart';

/// 评论远程数据源
class ReplyRemoteDataSource {
  final Dio _httpClient = HttpClientManager.instance;

  /// 评论列表
  ///
  /// [isLogin] 是否登录
  /// [oid] 对象ID
  /// [nextOffset] 下一页偏移量（未登录时使用）
  /// [type] 评论类型
  /// [page] 页码（登录时使用）
  /// [sort] 排序方式: 1-按时间, 2-按热度
  Future<Map<String, dynamic>> replyList({
    required bool isLogin,
    required int oid,
    required String nextOffset,
    required int type,
    required int page,
    int sort = 1,
  }) async {
    try {
      final response = await _httpClient.get(
        isLogin ? ReplyApiConstants.replyList : '${ReplyApiConstants.replyList}/main',
        queryParameters: isLogin
            ? {
                'oid': oid,
                'type': type,
                'sort': sort,
                'pn': page,
                'ps': 20,
              }
            : {
                'oid': oid,
                'type': type,
                'pagination_str':
                    '{"offset":"${nextOffset.replaceAll('"', '\\"')}"}',
                'mode': sort + 2, // 2:按时间排序；3：按热度排序
              },
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取评论列表失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 楼中楼评论列表
  ///
  /// [isLogin] 是否登录
  /// [oid] 对象ID
  /// [root] 根评论ID
  /// [pageNum] 页码
  /// [type] 评论类型
  /// [isCheck] 是否仅检查
  Future<Map<String, dynamic>> replyReplyList({
    required bool isLogin,
    required int oid,
    required int root,
    required int pageNum,
    required int type,
    bool isCheck = false,
  }) async {
    try {
      final queryParams = {
        'oid': oid,
        'root': root,
        'pn': pageNum,
        'type': type,
        'sort': 1,
        if (isLogin) 'csrf': '', // 需要从外部传入
      };

      final response = await _httpClient.get(
        ReplyApiConstants.replyReplyList,
        queryParameters: queryParams,
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          isCheck
              ? '${response.data['code']}${response.data['message']}'
              : response.data['message'] ?? '获取楼中楼评论失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 评论踩/取消踩
  ///
  /// [type] 评论类型
  /// [action] 操作: 1-踩, 2-取消踩
  /// [oid] 对象ID
  /// [rpid] 评论ID
  Future<void> hateReply({
    required int type,
    required int action,
    required int oid,
    required int rpid,
  }) async {
    try {
      final response = await _httpClient.post(
        ReplyApiConstants.hateReply,
        data: {
          'type': type,
          'oid': oid,
          'rpid': rpid,
          'action': action,
          'csrf': '', // 需要从外部传入
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
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

  /// 评论点赞
  ///
  /// [type] 评论类型
  /// [oid] 对象ID
  /// [rpid] 评论ID
  /// [action] 操作: 1-点赞, 2-取消点赞
  Future<void> likeReply({
    required int type,
    required int oid,
    required int rpid,
    required int action,
  }) async {
    try {
      final response = await _httpClient.post(
        ReplyApiConstants.likeReply,
        data: {
          'type': type,
          'oid': oid,
          'rpid': rpid,
          'action': action,
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

  /// 获取表情列表
  ///
  /// [business] 业务场景，默认为 'reply'
  Future<Map<String, dynamic>> getEmoteList({
    String? business,
  }) async {
    try {
      final response = await _httpClient.get(
        ReplyApiConstants.myEmote,
        queryParameters: {
          'business': business ?? 'reply',
          'web_location': '333.1245',
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取表情列表失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 设置评论置顶/取消置顶
  ///
  /// [oid] 对象ID
  /// [type] 评论类型
  /// [rpid] 评论ID
  /// [isUpTop] 是否置顶
  Future<void> replyTop({
    required Object oid,
    required Object type,
    required Object rpid,
    required bool isUpTop,
  }) async {
    try {
      final response = await _httpClient.post(
        ReplyApiConstants.replyTop,
        data: {
          'oid': oid,
          'type': type,
          'rpid': rpid,
          'action': isUpTop ? 0 : 1,
          'csrf': '', // 需要从外部传入
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '设置置顶失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 举报评论
  ///
  /// [rpid] 评论ID
  /// [oid] 对象ID
  /// [reasonType] 举报原因类型
  /// [banUid] 是否拉黑用户
  /// [reasonDesc] 举报原因描述（当 reasonType 为 0 时必填）
  Future<void> report({
    required Object rpid,
    required Object oid,
    required int reasonType,
    bool banUid = true,
    String? reasonDesc,
  }) async {
    try {
      final response = await _httpClient.post(
        '/x/v2/reply/report',
        data: {
          'add_blacklist': banUid,
          'csrf': '', // 需要从外部传入
          'gaia_source': 'main_h5',
          'oid': oid,
          'platform': 'android',
          'reason': reasonType,
          'rpid': rpid,
          'scene': 'main',
          'type': 1,
          if (reasonType == 0) 'content': reasonDesc!,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '举报失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 评论区互动信息
  ///
  /// [oid] 对象ID
  /// [type] 评论类型
  Future<Map<String, dynamic>> replyInteraction({
    required Object oid,
    required Object type,
  }) async {
    try {
      final response = await _httpClient.get(
        ReplyApiConstants.replyInteraction,
        queryParameters: {
          'oid': oid,
          'type': type,
          'web_location': 333.1369,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取互动信息失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 修改评论主体信息（关闭/开启评论）
  ///
  /// [oid] 对象ID
  /// [type] 评论类型
  /// [action] 操作: 1-关闭评论, 2-开启评论
  Future<Map<String, dynamic>?> replySubjectModify({
    required int oid,
    required int type,
    required int action,
  }) async {
    try {
      final response = await _httpClient.post(
        ReplyApiConstants.replySubjectModify,
        data: {
          'oid': oid,
          'type': type,
          'action': action,
          'csrf': '', // 需要从外部传入
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '修改失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}
