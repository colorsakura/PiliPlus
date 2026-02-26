import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/reply2reply/data.dart';
import 'package:PiliPlus/features/reply/domain/repositories/reply_repository.dart';

/// Get reply to reply list use case
class GetReplyReplyList {
  final ReplyRepository repository;

  const GetReplyReplyList(this.repository);

  Future<LoadingState<ReplyReplyData>> call({
    required bool isLogin,
    required int oid,
    required int root,
    required int pageNum,
    required int type,
    bool isCheck = false,
  }) {
    return repository.getReplyReplyList(
      isLogin: isLogin,
      oid: oid,
      root: root,
      pageNum: pageNum,
      type: type,
      isCheck: isCheck,
    );
  }
}
