import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/msgfeed_unread/data.dart';
import 'package:PiliPlus/features/msg/domain/repositories/msg_repository.dart';

/// Get message feed unread count use case
class GetMsgFeedUnread {
  final MsgRepository repository;

  const GetMsgFeedUnread(this.repository);

  Future<LoadingState<MsgFeedUnreadData>> call() {
    return repository.getMsgFeedUnread();
  }
}
