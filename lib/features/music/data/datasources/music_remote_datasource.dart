/// 音乐远程数据源
///
/// 负责所有音乐相关的网络请求
library;

// 忽略类型推断警告
// ignore_for_file: prefer_collection_literals, map_value_type_not_assignable

import 'package:PiliPlus/core/network/http_client.dart';
import 'package:PiliPlus/core/constants/music_api_constants.dart';
import 'package:PiliPlus/core/errors/error_handler.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/utils/wbi_sign.dart';
import 'package:dio/dio.dart';

/// 音乐远程数据源
class MusicRemoteDataSource {
  final Dio _httpClient = HttpClientManager.instance;

  /// BGM详情
  ///
  /// [musicId] 音乐ID
  Future<Map<String, dynamic>> bgmDetail(String musicId) async {
    try {
      final response = await _httpClient.get(
        MusicApiConstants.bgmDetail,
        queryParameters: await WbiSign.makSign({
          'music_id': musicId,
          'relation_from': 'bgm_page',
        }),
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取BGM详情失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 更新收藏状态
  ///
  /// [musicId] 音乐ID
  /// [hasLike] 是否已收藏（true:收藏，false:取消收藏）
  Future<void> wishUpdate({
    required String musicId,
    required bool hasLike,
  }) async {
    try {
      final response = await _httpClient.post(
        MusicApiConstants.wishUpdate,
        data: {
          'music_id': musicId,
          'state': hasLike ? 2 : 1,
          'csrf': '', // 需要从外部传入
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '更新收藏状态失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// BGM推荐列表
  ///
  /// [musicId] 音乐ID
  Future<List<dynamic>?> bgmRecommend(String musicId) async {
    try {
      final response = await _httpClient.get(
        MusicApiConstants.bgmRecommend,
        queryParameters: {
          'music_id': musicId,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data']?['list'] as List<dynamic>?;
      } else {
        throw ServerException(
          response.data['message'] ?? '获取BGM推荐失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}
