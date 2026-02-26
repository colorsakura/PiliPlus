/// 评论远程数据源
///
/// 负责所有评论相关的网络请求
library;

import 'package:PiliPlus/core/network/http_client.dart';
import 'package:PiliPlus/core/constants/reply_api_constants.dart';
import 'package:PiliPlus/core/constants/constants.dart';
import 'package:PiliPlus/core/errors/error_handler.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/reply/data.dart';
import 'package:PiliPlus/models/reply2reply/data.dart';
import 'package:PiliPlus/models/emote/data.dart';
import 'package:PiliPlus/models/emote/package.dart';
import 'package:PiliPlus/models/reply_interaction/data.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:PiliPlus/utils/accounts/account.dart';
import 'package:dio/dio.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

/// 评论远程数据源
class ReplyRemoteDataSource {
  final Dio _httpClient = HttpClientManager.instance;

  static final Options _options = Options(
    headers: {...Constants.baseHeaders, 'cookie': ''},
    extra: {'account': const NoAccount()},
  );

  /// 评论列表
  Future<LoadingState<ReplyData>> replyList({
    required bool isLogin,
    required int oid,
    required String nextOffset,
    required int type,
    required int page,
    int sort = 1,
  }) async {
    try {
      final response = await _httpClient.get(
        isLogin
            ? ReplyApiConstants.replyList
            : '${ReplyApiConstants.replyList}/main',
        queryParameters: isLogin
            ? {
                'oid': oid,
                'type': type,
                'sort': sort,
                'pn': page,
                'ps': 20,
              }
            : {
                'oid': oid,
                'type': type,
                'pagination_str':
                    '{"offset":"${nextOffset.replaceAll('"', '\\"')}"}',
                'mode': sort + 2, //2:按时间排序；3：按热度排序
              },
        options: !isLogin ? _options : null,
      );

      if (response.data['code'] == 0) {
        return Success(ReplyData.fromJson(response.data['data']));
      } else {
        return Error(response.data['message']);
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 楼中楼评论列表
  Future<LoadingState<ReplyReplyData>> replyReplyList({
    required bool isLogin,
    required int oid,
    required int root,
    required int pageNum,
    required int type,
    bool isCheck = false,
  }) async {
    try {
      final response = await _httpClient.get(
        ReplyApiConstants.replyReplyList,
        queryParameters: {
          'oid': oid,
          'root': root,
          'pn': pageNum,
          'type': type,
          'sort': 1,
          if (isLogin) 'csrf': Accounts.main.csrf,
        },
        options: !isLogin ? _options : null,
      );

      if (response.data['code'] == 0) {
        ReplyReplyData replyData = ReplyReplyData.fromJson(
          response.data['data'],
        );
        return Success(replyData);
      } else {
        return Error(
          isCheck
              ? '${response.data['code']}${response.data['message']}'
              : response.data['message'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 评论踩/取消踩
  Future<LoadingState<Null>> hateReply({
    required int type,
    required int action,
    required int oid,
    required int rpid,
  }) async {
    try {
      final response = await _httpClient.post(
        ReplyApiConstants.hateReply,
        data: {
          'type': type,
          'oid': oid,
          'rpid': rpid,
          'action': action,
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.data['code'] == 0) {
        return const Success(null);
      } else {
        return Error(response.data['message']);
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 评论点赞
  Future<LoadingState<Null>> likeReply({
    required int type,
    required int oid,
    required int rpid,
    required int action,
  }) async {
    try {
      final response = await _httpClient.post(
        ReplyApiConstants.likeReply,
        data: {
          'type': type,
          'oid': oid,
          'rpid': rpid,
          'action': action,
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.data['code'] == 0) {
        return const Success(null);
      } else {
        return Error(response.data['message']);
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 获取表情列表
  Future<LoadingState<List<Package>?>> getEmoteList({
    String? business,
  }) async {
    try {
      final response = await _httpClient.get(
        ReplyApiConstants.myEmote,
        queryParameters: {
          'business': business ?? 'reply',
          'web_location': '333.1245',
        },
      );

      if (response.data['code'] == 0) {
        return Success(EmoteModelData.fromJson(response.data['data']).packages);
      } else {
        return Error(response.data['message']);
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 设置评论置顶/取消置顶
  Future<LoadingState<Null>> replyTop({
    required Object oid,
    required Object type,
    required Object rpid,
    required bool isUpTop,
  }) async {
    try {
      final response = await _httpClient.post(
        ReplyApiConstants.replyTop,
        data: {
          'oid': oid,
          'type': type,
          'rpid': rpid,
          'action': isUpTop ? 0 : 1,
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.data['code'] == 0) {
        return const Success(null);
      } else {
        return Error(response.data['message']);
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 举报评论
  Future<LoadingState<Null>> report({
    required Object rpid,
    required Object oid,
    required int reasonType,
    bool banUid = true,
    String? reasonDesc,
  }) async {
    try {
      final response = await _httpClient.post(
        '/x/v2/reply/report',
        data: {
          'add_blacklist': banUid,
          'csrf': Accounts.main.csrf,
          'gaia_source': 'main_h5',
          'oid': oid,
          'platform': 'android',
          'reason': reasonType,
          'rpid': rpid,
          'scene': 'main',
          'type': 1,
          if (reasonType == 0) 'content': reasonDesc!,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.data['code'] == 0) {
        return const Success(null);
      } else {
        return Error(response.data['message']);
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 评论区互动信息
  Future<LoadingState<ReplyInteractData>> replyInteraction({
    required Object oid,
    required Object type,
  }) async {
    try {
      final response = await _httpClient.get(
        ReplyApiConstants.replyInteraction,
        queryParameters: {
          'oid': oid,
          'type': type,
          'web_location': 333.1369,
        },
      );

      if (response.data['code'] == 0) {
        try {
          return Success(ReplyInteractData.fromJson(response.data['data']));
        } catch (e) {
          return Error(e.toString());
        }
      } else {
        return Error(response.data['message']);
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 修改评论主体信息（关闭/开启评论）
  Future<LoadingState<Null>> replySubjectModify({
    required int oid,
    required int type,
    required int action,
  }) async {
    try {
      final response = await _httpClient.post(
        ReplyApiConstants.replySubjectModify,
        data: {
          'oid': oid,
          'type': type,
          'action': action,
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.data['code'] == 0) {
        if (response.data['data']?['action_toast'] case final String toast) {
          SmartDialog.showToast(toast);
        }
        return const Success(null);
      } else {
        SmartDialog.showToast(response.data['message'].toString());
        return const Error(null);
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}
