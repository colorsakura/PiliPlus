import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/grpc/bilibili/main/community/reply/v1.pb.dart'
    show SearchItemReply, SearchItemType;
import 'package:PiliPlus/grpc/reply.dart';
import 'package:PiliPlus/models/common/reply/reply_search_type.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/features/reply_search/domain/entities/reply_search_params_entity.dart';
import 'package:PiliPlus/features/reply_search/domain/repositories/reply_search_repository.dart';

/// Reply search repository implementation
class ReplySearchRepositoryImpl implements ReplySearchRepository {
  @override
  Future<LoadingState<dynamic>> searchReplies(ReplySearchParamsEntity params) async {
    try {
      final result = await ReplyGrpc.searchItem(
        page: params.page,
        itemType: params.searchType == ReplySearchType.video
            ? SearchItemType.VIDEO
            : SearchItemType.ARTICLE,
        oid: params.oid,
        type: params.type,
        keyword: params.keyword,
      );
      return Success(result);
    } on ServerException catch (e) {
      return Error(e.message ?? '搜索评论失败');
    } on Exception catch (e) {
      return Error(e.toString());
    }
  }
}
