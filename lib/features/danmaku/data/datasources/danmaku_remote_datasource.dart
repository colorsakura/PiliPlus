/// 弹幕远程数据源
///
/// 负责所有弹幕相关的网络请求
library;

// 忽略类型推断警告
// ignore_for_file: prefer_collection_literals, map_value_type_not_assignable

import 'package:PiliPlus/core/network/http_client.dart';
import 'package:PiliPlus/core/constants/danmaku_api_constants.dart';
import 'package:PiliPlus/core/errors/error_handler.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:dio/dio.dart';

/// 弹幕远程数据源
class DanmakuRemoteDataSource {
  final Dio _httpClient = HttpClientManager.instance;

  /// 发送弹幕
  ///
  /// [type] 弹幕类型：1-视频弹幕，2-漫画弹幕
  /// [oid] 视频cid
  /// [msg] 弹幕文本（长度小于100字符）
  /// [mode] 弹幕类型：1-滚动，4-底端，5-顶端，7-高级
  /// [bvid] 视频BV号
  /// [progress] 弹幕出现时间（毫秒，默认0）
  /// [color] 弹幕颜色（默认白色16777215）
  /// [fontSize] 弹幕字号（默认25）
  /// [pool] 弹幕池：0-普通，1-字幕，2-特殊
  /// [colorful] 是否彩色（需要会员）
  /// [checkboxType] UP身份标识：0-普通，4-带标识
  Future<Map<String, dynamic>> shootDanmaku({
    int type = 1,
    required int oid,
    required String msg,
    int mode = 1,
    required String bvid,
    int? progress,
    int? color,
    int? fontSize,
    int? pool,
    bool colorful = false,
    int? checkboxType,
  }) async {
    try {
      final data = {
        'type': type,
        'oid': oid,
        'msg': msg,
        'mode': mode,
        'bvid': bvid,
        'progress': progress,
        'color': colorful ? 16777215 : color,
        'fontsize': fontSize,
        'pool': pool,
        'rnd': DateTime.now().microsecondsSinceEpoch,
        'colorful': colorful ? 60001 : null,
        'checkbox_type': checkboxType,
        'csrf': '', // 需要从外部传入
      };

      final response = await _httpClient.post(
        DanmakuApiConstants.shootDanmaku,
        data: data,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '发送弹幕失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}
