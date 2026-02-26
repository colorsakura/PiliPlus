import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/reply/domain/repositories/reply_repository.dart';

/// Like reply use case
class LikeReply {
  final ReplyRepository repository;

  const LikeReply(this.repository);

  Future<LoadingState<Null>> call({
    required int type,
    required int oid,
    required int rpid,
    required int action,
  }) {
    return repository.likeReply(
      type: type,
      oid: oid,
      rpid: rpid,
      action: action,
    );
  }
}
