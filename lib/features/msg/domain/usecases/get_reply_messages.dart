import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/msg/msg_reply/data.dart';
import 'package:PiliPlus/features/msg/domain/repositories/msg_repository.dart';

/// Get reply messages use case
class GetReplyMessages {
  final MsgRepository repository;

  const GetReplyMessages(this.repository);

  Future<LoadingState<MsgReplyData>> call({
    int? cursor,
    int? cursorTime,
  }) {
    return repository.getReplyMessages(
      cursor: cursor,
      cursorTime: cursorTime,
    );
  }
}
