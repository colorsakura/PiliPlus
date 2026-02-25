/// SponsorBlock 远程数据源
///
/// 负责所有 SponsorBlock 相关的网络请求
library;

// 忽略类型推断警告
// ignore_for_file: prefer_collection_literals, map_value_type_not_assignable

import 'dart:convert';

import 'package:PiliPlus/build_config.dart';
import 'package:PiliPlus/core/network/http_client.dart';
import 'package:PiliPlus/core/constants/sponsor_block_api_constants.dart';
import 'package:PiliPlus/core/constants/constants.dart';
import 'package:PiliPlus/core/errors/error_handler.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/models/common/sponsor_block/post_segment_model.dart';
import 'package:PiliPlus/models/common/sponsor_block/segment_type.dart';
import 'package:PiliPlus/models/sponsor_block/segment_item.dart';
import 'package:PiliPlus/models/sponsor_block/user_info.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

/// SponsorBlock 远程数据源
class SponsorBlockRemoteDataSource {
  final Dio _httpClient = HttpClientManager.instance;

  /// 获取 SponsorBlock 服务器地址
  String get _blockServer => Pref.blockServer;

  /// 构建完整 API URL
  String _api(String url) => '$_blockServer/api/$url';

  /// 获取请求选项
  Options get _options => Options(
    followRedirects: true,
    headers: kDebugMode
        ? null
        : {
            'origin': Constants.appName,
            'x-ext-version': BuildConfig.versionName,
          },
    validateStatus: (status) => true,
  );

  /// 获取错误消息
  Exception _getErrMsg(Response res) {
    String statusMessage = switch (res.statusCode) {
      200 => '意料之外的响应',
      400 => '参数错误',
      403 => '被自动审核机制拒绝',
      404 => '未找到数据',
      409 => '重复提交',
      429 => '提交太快（触发速率控制）',
      500 => '服务器无法获取信息',
      -1 => res.data['message'].toString(), // DioException
      _ => res.statusMessage ?? res.statusCode.toString(),
    };
    if (res.statusCode != null && res.statusCode != -1) {
      final data = res.data;
      if (res.statusCode == 200 ||
          (data is String && data.isNotEmpty && data.length < 200)) {
        statusMessage = '$statusMessage：$data';
      }
    }
    return ServerException(statusMessage, code: res.statusCode);
  }

  /// 获取视频跳过片段
  ///
  /// [bvid] B站视频BVID
  /// [cid] 视频CID
  Future<List<SegmentItemModel>> getSkipSegments({
    required String bvid,
    required int cid,
  }) async {
    try {
      final response = await _httpClient.get(
        _api(SponsorBlockApiConstants.skipSegments),
        queryParameters: {
          'videoID': bvid,
          'cid': cid,
        },
        options: _options,
      );

      if (response.statusCode == 200) {
        if (response.data case final List list) {
          return list.map((i) => SegmentItemModel.fromJson(i)).toList();
        }
      }
      throw _getErrMsg(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 对片段投票
  ///
  /// [uuid] 片段UUID
  /// [type] 投票类型：0-普通投票，1-取消投票，20-downvote
  /// [category] 片段分类
  Future<void> voteOnSponsorTime({
    required String uuid,
    int? type,
    SegmentType? category,
  }) async {
    try {
      assert((type == null) == (category == null));

      final response = await _httpClient.post(
        _api(SponsorBlockApiConstants.voteOnSponsorTime),
        queryParameters: {
          'UUID': uuid,
          'type': type,
          'category': category?.name,
          'userID': Pref.blockUserID,
        },
        options: _options,
      );

      if (response.statusCode != 200) {
        throw _getErrMsg(response);
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 标记片段已查看
  ///
  /// [uuid] 片段UUID
  Future<void> viewedVideoSponsorTime(String uuid) async {
    try {
      final response = await _httpClient.post(
        _api(SponsorBlockApiConstants.viewedVideoSponsorTime),
        data: {'UUID': uuid},
        options: _options,
      );

      if (response.statusCode != 200) {
        throw _getErrMsg(response);
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 检查服务状态
  Future<void> uptimeStatus() async {
    try {
      final response = await _httpClient.get(
        _api(SponsorBlockApiConstants.uptimeStatus),
        options: _options,
      );

      if (!(response.statusCode == 200 &&
          response.data is String &&
          Utils.isStringNumeric(response.data))) {
        throw _getErrMsg(response);
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 获取用户信息
  ///
  /// [query] 查询值列表
  /// [userId] 用户ID，默认使用设置中的ID
  Future<UserInfo> userInfo(
    List<String> query, {
    String? userId,
  }) async {
    try {
      final response = await _httpClient.get(
        _api(SponsorBlockApiConstants.userInfo),
        queryParameters: {
          'userID': userId ?? Pref.blockUserID,
          'values': jsonEncode(query),
        },
        options: _options,
      );

      if (response.statusCode == 200) {
        return UserInfo.fromJson(response.data);
      }
      throw _getErrMsg(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 提交跳过片段
  ///
  /// [bvid] B站视频BVID
  /// [cid] 视频CID
  /// [videoDuration] 视频时长（秒）
  /// [segments] 片段列表
  Future<List<SegmentItemModel>> postSkipSegments({
    required String bvid,
    required int cid,
    required double videoDuration,
    required List<PostSegmentModel> segments,
  }) async {
    try {
      final response = await _httpClient.post(
        _api(SponsorBlockApiConstants.skipSegments),
        data: {
          'videoID': bvid,
          'cid': cid.toString(),
          'userID': Pref.blockUserID,
          'userAgent': kDebugMode
              ? Constants.userAgent
              : '${Constants.appName}/${BuildConfig.versionName}',
          'videoDuration': videoDuration,
          'segments': segments
              .map(
                (item) => {
                  'segment': [item.segment.first, item.segment.second],
                  'category': item.category.name,
                  'actionType': item.actionType.name,
                },
              )
              .toList(),
        },
        options: _options,
      );

      if (response.statusCode == 200) {
        if (response.data case final List list) {
          return list.map((i) => SegmentItemModel.fromJson(i)).toList();
        }
      }
      throw _getErrMsg(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 获取端口绑定视频信息
  ///
  /// [bvid] B站视频BVID
  /// [cid] 视频CID
  /// 返回 YouTube 视频 ID
  Future<String> getPortVideo({
    required String bvid,
    required int cid,
  }) async {
    try {
      final response = await _httpClient.get(
        _api(SponsorBlockApiConstants.portVideo),
        queryParameters: {
          'videoID': bvid,
          'cid': cid.toString(),
        },
        options: _options,
      );

      if (response.statusCode == 200) {
        if (response.data case final Map<String, dynamic> data) {
          if (data['ytbID'] case String ytbId) {
            return ytbId;
          }
        }
      }
      throw _getErrMsg(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 提交端口绑定视频
  ///
  /// [bvid] B站视频BVID
  /// [cid] 视频CID
  /// [ytbId] YouTube 视频 ID
  /// [videoDuration] 视频时长（秒）
  /// 返回绑定记录的 UUID
  Future<String> postPortVideo({
    required String bvid,
    required int cid,
    required String ytbId,
    required int videoDuration,
  }) async {
    try {
      final response = await _httpClient.post(
        _api(SponsorBlockApiConstants.portVideo),
        data: {
          'bvID': bvid,
          'cid': cid.toString(),
          'ytbID': ytbId,
          'userID': Pref.blockUserID,
          'biliDuration': videoDuration,
        },
        options: _options,
      );

      if (response.statusCode == 200) {
        if (response.data case final Map<String, dynamic> data) {
          if (data['UUID'] case String uuid) {
            return uuid;
          }
        }
      }
      throw _getErrMsg(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}
