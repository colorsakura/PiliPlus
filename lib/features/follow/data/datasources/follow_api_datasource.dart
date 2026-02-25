/// 关注远程数据源
///
/// 负责所有关注相关的网络请求
library;

// 忽略类型推断警告
// ignore_for_file: prefer_collection_literals, map_value_type_not_assignable

import 'package:PiliPlus/core/network/http_client.dart';
import 'package:PiliPlus/core/constants/follow_api_constants.dart';
import 'package:PiliPlus/core/errors/error_handler.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:dio/dio.dart';

/// 关注远程数据源
class FollowRemoteDataSource {
  final Dio _httpClient = HttpClientManager.instance;

  /// 关注列表
  ///
  /// [vmid] 用户ID
  /// [pn] 页码
  /// [ps] 每页数量
  /// [orderType] 排序类型：空-最近关注，attention-最常访问
  Future<Map<String, dynamic>> followings({
    int? vmid,
    int? pn,
    int ps = 20,
    String orderType = '',
  }) async {
    try {
      final response = await _httpClient.get(
        FollowApiConstants.followings,
        queryParameters: {
          'vmid': vmid,
          'pn': pn,
          'ps': ps,
          'order': 'desc',
          'order_type': orderType,
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
}
