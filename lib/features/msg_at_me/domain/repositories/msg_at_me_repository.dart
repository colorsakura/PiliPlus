import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/msg/msg_at/data.dart';

/// Repository for @Me notifications
abstract class MsgAtMeRepository {
  /// Fetch @Me notifications with cursor-based pagination
  Future<LoadingState<MsgAtData>> getMsgAtMeItems({
    int? cursor,
    int? cursorTime,
  });

  /// Remove a notification item
  Future<LoadingState<void>> removeMsgItem({
    required Object id,
  });
}
