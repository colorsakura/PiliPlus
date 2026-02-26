import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/msg/msg_at/data.dart';
import 'package:PiliPlus/models/msg/msg_like/data.dart';
import 'package:PiliPlus/models/msg/msg_reply/data.dart';
import 'package:PiliPlus/models/msgfeed_unread/data.dart';
import 'package:PiliPlus/models/single_unread/data.dart';

/// Message repository interface
abstract class MsgRepository {
  /// Get reply messages
  Future<LoadingState<MsgReplyData>> getReplyMessages({
    int? cursor,
    int? cursorTime,
  });

  /// Get at messages
  Future<LoadingState<MsgAtData>> getAtMessages({
    int? cursor,
    int? cursorTime,
  });

  /// Get like messages
  Future<LoadingState<MsgLikeData>> getLikeMessages({
    int? cursor,
    int? cursorTime,
  });

  /// Get message feed unread count
  Future<LoadingState<MsgFeedUnreadData>> getMsgFeedUnread();

  /// Get single unread count
  Future<LoadingState<SingleUnreadData>> getSingleUnread();
}
