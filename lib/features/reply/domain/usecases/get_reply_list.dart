import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/reply/data.dart';
import 'package:PiliPlus/features/reply/domain/repositories/reply_repository.dart';

/// Get reply list use case
class GetReplyList {
  final ReplyRepository repository;

  const GetReplyList(this.repository);

  Future<LoadingState<ReplyData>> call({
    required bool isLogin,
    required int oid,
    required String nextOffset,
    required int type,
    required int page,
    int sort = 1,
  }) {
    return repository.getReplyList(
      isLogin: isLogin,
      oid: oid,
      nextOffset: nextOffset,
      type: type,
      page: page,
      sort: sort,
    );
  }
}
