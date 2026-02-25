/// 黑名单远程数据源
///
/// 负责所有黑名单相关的网络请求
library;

// 忽略类型推断警告
// ignore_for_file: prefer_collection_literals, map_value_type_not_assignable

import 'package:PiliPlus/core/network/http_client.dart';
import 'package:PiliPlus/core/constants/blacklist_api_constants.dart';
import 'package:PiliPlus/core/errors/error_handler.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/models/blacklist/data.dart';
import 'package:dio/dio.dart';

/// 黑名单远程数据源
class BlacklistRemoteDataSource {
  final Dio _httpClient = HttpClientManager.instance;

  /// 获取黑名单列表
  ///
  /// [pn] 页码
  /// [ps] 每页数量，默认20
  Future<BlackListData> blackList({
    required int pn,
    int ps = 20,
  }) async {
    try {
      final response = await _httpClient.get(
        BlacklistApiConstants.blackList,
        queryParameters: {
          'pn': pn,
          'ps': ps,
          're_version': 0,
          'jsonp': 'jsonp',
        },
      );

      if (response.data['code'] == 0) {
        return BlackListData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取黑名单列表失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}
