/// 弹幕过滤远程数据源
///
/// 负责所有弹幕过滤相关的网络请求
library;

// 忽略类型推断警告
// ignore_for_file: prefer_collection_literals, map_value_type_not_assignable

import 'package:PiliPlus/core/network/http_client.dart';
import 'package:PiliPlus/core/constants/danmaku_filter_api_constants.dart';
import 'package:PiliPlus/core/errors/error_handler.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:dio/dio.dart';

/// 弹幕过滤远程数据源
class DanmakuFilterRemoteDataSource {
  final Dio _httpClient = HttpClientManager.instance;

  /// 获取弹幕过滤规则
  Future<Map<String, dynamic>> danmakuFilter() async {
    try {
      final response = await _httpClient.get(
        DanmakuFilterApiConstants.danmakuFilter,
        queryParameters: {
          if (Accounts.main.isLogin) 'csrf': Accounts.main.csrf,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取弹幕过滤规则失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 添加弹幕过滤规则
  Future<Map<String, dynamic>> danmakuFilterAdd({
    required String filter,
    required int type,
  }) async {
    try {
      final response = await _httpClient.post(
        DanmakuFilterApiConstants.danmakuFilterAdd,
        queryParameters: {
          if (Accounts.main.isLogin) 'csrf': Accounts.main.csrf,
        },
        data: {
          'type': type,
          'filter': filter,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '添加弹幕过滤规则失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 删除弹幕过滤规则
  Future<void> danmakuFilterDel({
    required int ids,
  }) async {
    try {
      final response = await _httpClient.post(
        DanmakuFilterApiConstants.danmakuFilterDel,
        queryParameters: {
          if (Accounts.main.isLogin) 'csrf': Accounts.main.csrf,
        },
        data: {
          'ids': ids,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '删除弹幕过滤规则失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}
