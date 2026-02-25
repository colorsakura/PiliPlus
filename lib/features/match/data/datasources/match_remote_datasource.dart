/// 赛事远程数据源
///
/// 负责所有赛事相关的网络请求
library;

// 忽略类型推断警告
// ignore_for_file: prefer_collection_literals, map_value_type_not_assignable

import 'package:PiliPlus/core/network/http_client.dart';
import 'package:PiliPlus/core/constants/match_api_constants.dart';
import 'package:PiliPlus/core/errors/error_handler.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/models/match/match_info/contest.dart';
import 'package:PiliPlus/models/match/match_info/data.dart';
import 'package:dio/dio.dart';

/// 赛事远程数据源
class MatchRemoteDataSource {
  final Dio _httpClient = HttpClientManager.instance;

  /// 获取赛事信息
  ///
  /// [cid] 赛事ID
  /// [platform] 平台：2-Web
  Future<MatchContest?> matchInfo(
    Object cid, {
    int platform = 2,
  }) async {
    try {
      final response = await _httpClient.get(
        MatchApiConstants.matchInfo,
        queryParameters: {
          'cid': cid,
          'platform': platform,
        },
      );

      if (response.data['code'] == 0) {
        return MatchInfoData.fromJson(response.data['data']).contest;
      } else {
        throw ServerException(
          response.data['message'] ?? '获取赛事信息失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}
