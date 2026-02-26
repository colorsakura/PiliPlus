/// 消息远程数据源
///
/// 负责所有消息相关的网络请求
library;

// 忽略类型推断警告
// ignore_for_file: prefer_collection_literals, map_value_type_not_assignable

import 'dart:convert';

import 'package:PiliPlus/core/network/http_client.dart';
import 'package:PiliPlus/core/constants/msg_api_constants.dart';
import 'package:PiliPlus/core/errors/error_handler.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/models/msg/msg_at/data.dart';
import 'package:PiliPlus/models/msg/msg_like/data.dart';
import 'package:PiliPlus/models/msg/msg_like_detail/data.dart';
import 'package:PiliPlus/models/msg/msg_reply/data.dart';
import 'package:PiliPlus/models/msgfeed_unread/data.dart';
import 'package:PiliPlus/models/single_unread/data.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:dio/dio.dart';
import 'package:uuid/v4.dart';

/// 消息远程数据源
class MsgRemoteDataSource {
  final Dio _httpClient = HttpClientManager.instance;

  /// 回复我的
  Future<MsgReplyData> msgFeedReplyMe({
    int? cursor,
    int? cursorTime,
  }) async {
    try {
      final response = await _httpClient.get(
        MsgApiConstants.msgFeedReply,
        queryParameters: {
          'id': cursor,
          'reply_time': cursorTime,
          'platform': 'web',
          'mobi_app': 'web',
          'build': 0,
          'web_location': 333.40164,
        },
      );
      if (response.data['code'] == 0) {
        return MsgReplyData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取回复消息失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// @我的
  Future<MsgAtData> msgFeedAtMe({
    int? cursor,
    int? cursorTime,
  }) async {
    try {
      final response = await _httpClient.get(
        MsgApiConstants.msgFeedAt,
        queryParameters: {
          'id': cursor,
          'at_time': cursorTime,
          'platform': 'web',
          'mobi_app': 'web',
          'build': 0,
          'web_location': 333.40164,
        },
      );
      if (response.data['code'] == 0) {
        return MsgAtData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取@消息失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 收到的赞
  Future<MsgLikeData> msgFeedLikeMe({
    int? cursor,
    int? cursorTime,
  }) async {
    try {
      final response = await _httpClient.get(
        MsgApiConstants.msgFeedLike,
        queryParameters: {
          'id': cursor,
          'like_time': cursorTime,
          'platform': 'web',
          'mobi_app': 'web',
          'build': 0,
          'web_location': 333.40164,
        },
      );
      if (response.data['code'] == 0) {
        return MsgLikeData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取点赞消息失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 赞详情
  Future<MsgLikeDetailData> msgLikeDetail({
    required Object cardId,
    required int pn,
    Object lastMid = 0,
  }) async {
    try {
      final response = await _httpClient.get(
        MsgApiConstants.msgLikeDetail,
        queryParameters: {
          'card_id': cardId,
          'pn': pn,
          'last_mid': lastMid,
        },
      );
      if (response.data['code'] == 0) {
        return MsgLikeDetailData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取点赞详情失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 上传图片
  Future<Map<String, dynamic>> uploadImage({
    required dynamic file,
    String? contentType,
  }) async {
    try {
      final response = await _httpClient.post(
        MsgApiConstants.uploadImage,
        data: FormData.fromMap({
          'file': file,
          'csrf': Accounts.main.csrf,
        }),
      );
      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '上传图片失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 创建文本动态
  Future<void> createTextDynamic({
    required String content,
    List<List<int>>? atUidLists,
  }) async {
    try {
      final response = await _httpClient.post(
        MsgApiConstants.createDynamic,
        data: {
          'dynamic_id': 0,
          'content': content,
          'csrf': Accounts.main.csrf,
          if (atUidLists != null) 'at_uid_lists': jsonEncode(atUidLists),
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '创建动态失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 删除动态
  Future<void> removeDynamic({
    required String dynId,
  }) async {
    try {
      final response = await _httpClient.post(
        MsgApiConstants.removeDynamic,
        data: {
          'dynamic_id': dynId,
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '删除动态失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 移除会话
  Future<void> removeMsg({
    required int talkerId,
    int talkerType = 1,
  }) async {
    try {
      final response = await _httpClient.post(
        MsgApiConstants.removeMsg,
        queryParameters: {
          'talker_id': talkerId,
          'talker_type': talkerType,
          'csrf': Accounts.main.csrf,
        },
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '移除会话失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 删除消息
  Future<void> delMsgfeed(List<int> ids) async {
    try {
      final response = await _httpClient.post(
        MsgApiConstants.delMsgfeed,
        data: {
          'ids': ids.join(','),
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '删除消息失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 设置置顶
  Future<void> setTop({
    required int talkerId,
    required bool isTop,
  }) async {
    try {
      final response = await _httpClient.post(
        MsgApiConstants.setTop,
        data: {
          'talker_id': talkerId,
          'is_top': isTop ? 1 : 0,
          'csrf': Accounts.main.csrf,
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

  /// 确认会话消息已读
  Future<void> ackSessionMsg({
    required int talkerId,
    int sessionType = 1,
  }) async {
    try {
      final response = await _httpClient.post(
        MsgApiConstants.ackSessionMsg,
        data: {
          'talker_id': talkerId,
          'session_type': sessionType,
          'ack_seqno': DateTime.now().millisecondsSinceEpoch,
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '确认消息失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 发送消息
  Future<void> sendMsg({
    required int receiverId,
    int receiverType = 1,
    required String content,
    int contentType = 1,
    int msgType = 1,
    String? msgKey,
  }) async {
    try {
      final response = await _httpClient.post(
        MsgApiConstants.sendMsg,
        data: {
          'receiver_id': receiverId,
          'receiver_type': receiverType,
          'msg': {
            'content': content,
            'content_type': contentType,
            'msg_type': msgType,
            'msg_key': msgKey ?? const UuidV4().generate(),
            'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          },
          'csrf': Accounts.main.csrf,
        },
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '发送消息失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 消息未读数
  Future<SingleUnreadData> msgUnread() async {
    try {
      final response = await _httpClient.get(MsgApiConstants.msgUnread);
      if (response.data['code'] == 0) {
        return SingleUnreadData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取未读数失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 消息中心未读信息
  Future<MsgFeedUnreadData> msgFeedUnread() async {
    try {
      final response = await _httpClient.get(MsgApiConstants.msgFeedUnread);
      if (response.data['code'] == 0) {
        return MsgFeedUnreadData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取未读信息失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 设置推送设置
  Future<void> setPushSs({
    required bool pushSwitch,
    Map<String, dynamic>? pushDetail,
  }) async {
    try {
      final response = await _httpClient.post(
        MsgApiConstants.setPushSs,
        data: {
          'push_switch': pushSwitch ? 1 : 0,
          if (pushDetail != null) 'push_detail': jsonEncode(pushDetail),
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '设置推送失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}
