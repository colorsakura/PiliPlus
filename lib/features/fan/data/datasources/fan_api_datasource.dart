/// 粉丝远程数据源
///
/// 负责所有粉丝相关的网络请求
library;

// 忽略类型推断警告
// ignore_for_file: prefer_collection_literals, map_value_type_not_assignable

import 'package:PiliPlus/core/network/http_client.dart';
import 'package:PiliPlus/core/constants/fan_api_constants.dart';
import 'package:PiliPlus/core/errors/error_handler.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/models/follow/data.dart';
import 'package:dio/dio.dart';

/// 粉丝远程数据源
class FanRemoteDataSource {
  final Dio _httpClient = HttpClientManager.instance;

  /// 粉丝列表
  ///
  /// [vmid] 用户ID
  /// [pn] 页码
  /// [ps] 每页数量
  /// [orderType] 排序类型：空-按关注时间，attention-按最常访问
  Future<FollowData> fans({
    int? vmid,
    int? pn,
    int ps = 20,
    String? orderType,
  }) async {
    try {
      final response = await _httpClient.get(
        FanApiConstants.fans,
        queryParameters: {
          'vmid': vmid,
          'pn': pn,
          'ps': ps,
          'order': 'desc',
          'order_type': orderType,
        },
      );

      if (response.data['code'] == 0) {
        return FollowData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取粉丝列表失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}
