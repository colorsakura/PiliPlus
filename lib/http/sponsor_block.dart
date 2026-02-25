import 'dart:convert';

import 'package:PiliPlus/build_config.dart';
import 'package:PiliPlus/core/constants/constants.dart';
import 'package:PiliPlus/http/init.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/sponsor_block_api.dart';
import 'package:PiliPlus/models/common/sponsor_block/post_segment_model.dart';
import 'package:PiliPlus/models/common/sponsor_block/segment_type.dart';
import 'package:PiliPlus/models/sponsor_block/segment_item.dart';
import 'package:PiliPlus/models/sponsor_block/user_info.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/features/sponsor_block/data/datasources/sponsor_block_remote_datasource.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

/// https://github.com/hanydd/BilibiliSponsorBlock/wiki/API
/// Adapter class that delegates to SponsorBlockRemoteDataSource
abstract final class SponsorBlock {
  static final _dataSource = SponsorBlockRemoteDataSource();
  static String get blockServer => Pref.blockServer;

  static Error getErrMsg(Response res) {
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
    return Error(statusMessage, code: res.statusCode);
  }

  static Future<LoadingState<List<SegmentItemModel>>> getSkipSegments({
    required String bvid,
    required int cid,
  }) async {
    try {
      final result = await _dataSource.getSkipSegments(bvid: bvid, cid: cid);
      return Success(result);
    } catch (e) {
      return Error(e.toString());
    }
  }

  static Future<LoadingState<Null>> voteOnSponsorTime({
    required String uuid,
    int? type,
    SegmentType? category,
  }) async {
    try {
      await _dataSource.voteOnSponsorTime(
        uuid: uuid,
        type: type,
        category: category,
      );
      return const Success(null);
    } catch (e) {
      return Error(e.toString());
    }
  }

  static Future<LoadingState<Null>> viewedVideoSponsorTime(String uuid) async {
    try {
      await _dataSource.viewedVideoSponsorTime(uuid);
      return const Success(null);
    } catch (e) {
      return Error(e.toString());
    }
  }

  static Future<LoadingState<Null>> uptimeStatus() async {
    try {
      await _dataSource.uptimeStatus();
      return const Success(null);
    } catch (e) {
      return Error(e.toString());
    }
  }

  static Future<LoadingState<UserInfo>> userInfo(
    List<String> query, {
    String? userId,
  }) async {
    try {
      final result = await _dataSource.userInfo(query, userId: userId);
      return Success(result);
    } catch (e) {
      return Error(e.toString());
    }
  }

  static Future<LoadingState<List<SegmentItemModel>>> postSkipSegments({
    required String bvid,
    required int cid,
    required double videoDuration,
    required List<PostSegmentModel> segments,
  }) async {
    try {
      final result = await _dataSource.postSkipSegments(
        bvid: bvid,
        cid: cid,
        videoDuration: videoDuration,
        segments: segments,
      );
      return Success(result);
    } catch (e) {
      return Error(e.toString());
    }
  }

  /// {
  ///   "bvID": string,     // B站视频BVID
  ///   "cid": string,      // 视频CID
  ///   "ytbID": string,    // YouTube视频ID
  ///   "UUID": string,     // 绑定记录的UUID（不是视频中片段的UUID，是绑定记录本身的UUID）
  ///   "votes": int,       // 绑定记录的投票数
  ///   "locked": int,      // 绑定记录是否锁定
  /// }
  /// TODO: show port video info dialog
  static Future<LoadingState<String>> getPortVideo({
    required String bvid,
    required int cid,
  }) async {
    try {
      final result = await _dataSource.getPortVideo(bvid: bvid, cid: cid);
      return Success(result);
    } catch (e) {
      return Error(e.toString());
    }
  }

  static Future<LoadingState<String>> postPortVideo({
    required String bvid,
    required int cid,
    required String ytbId,
    required int videoDuration,
  }) async {
    try {
      final result = await _dataSource.postPortVideo(
        bvid: bvid,
        cid: cid,
        ytbId: ytbId,
        videoDuration: videoDuration,
      );
      return Success(result);
    } catch (e) {
      return Error(e.toString());
    }
  }
}
