import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/msg.dart';
import 'package:PiliPlus/models/msg/msg_at/data.dart';

/// Remote datasource for @Me notifications
class MsgAtMeRemoteDatasource {
  const MsgAtMeRemoteDatasource();

  /// Fetch @Me notifications from API
  Future<LoadingState<MsgAtData>> getMsgAtMeItems({
    int? cursor,
    int? cursorTime,
  }) =>
      MsgHttp.msgFeedAtMe(
        cursor: cursor,
        cursorTime: cursorTime,
      );

  /// Remove a notification item
  Future<LoadingState<void>> removeMsgItem({
    required Object id,
  }) =>
      MsgHttp.delMsgfeed(2, id);
}
