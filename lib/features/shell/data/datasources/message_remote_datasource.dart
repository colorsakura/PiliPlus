import 'dart:async';

import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/msg.dart';
import 'package:PiliPlus/models/common/msg/msg_unread_type.dart';

/// 消息远程数据源
class MessageRemoteDataSource {
  /// 获取私信未读数
  Future<int> getMsgUnread(Set<MsgUnReadType> msgUnReadTypes) async {
    if (!msgUnReadTypes.contains(MsgUnReadType.pm)) {
      return 0;
    }

    final res = await MsgHttp.msgUnread();
    if (res case Success(:final response)) {
      return response.followUnread +
          response.unfollowUnread +
          response.bizMsgFollowUnread +
          response.bizMsgUnfollowUnread +
          response.unfollowPushMsg +
          response.customUnread;
    }
    return 0;
  }

  /// 获取 Feed 消息未读数
  Future<int> getMsgFeedUnread(Set<MsgUnReadType> msgUnReadTypes) async {
    int count = 0;
    final remainTypes = Set<MsgUnReadType>.from(msgUnReadTypes)
      ..remove(MsgUnReadType.pm);

    if (remainTypes.isEmpty) {
      return 0;
    }

    final res = await MsgHttp.msgFeedUnread();
    if (res case Success(:final response)) {
      for (final item in remainTypes) {
        switch (item) {
          case MsgUnReadType.pm:
            break;
          case MsgUnReadType.reply:
            count += response.reply;
            break;
          case MsgUnReadType.at:
            count += response.at;
            break;
          case MsgUnReadType.like:
            count += response.like;
            break;
          case MsgUnReadType.sysMsg:
            count += response.sysMsg;
            break;
        }
      }
    }
    return count;
  }

  /// 获取所有未读消息总数
  Future<int> getAllUnreadCount(Set<MsgUnReadType> msgUnReadTypes) async {
    final results = await Future.wait([
      getMsgUnread(msgUnReadTypes),
      getMsgFeedUnread(msgUnReadTypes),
    ]);

    return results.reduce((a, b) => a + b);
  }
}
